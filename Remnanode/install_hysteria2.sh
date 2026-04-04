#!/usr/bin/env bash
set -Eeuo pipefail

echo "=== Hysteria2 node preparation ==="

read -r -p "Домен для сертификата (например hy.sovacorequad.shop): " DOMAIN

if [[ -z "${DOMAIN}" ]]; then
  echo "Домен не указан"
  exit 1
fi

REMNANODE_DIR="/opt/remnanode"
SSL_DIR="/opt/remnawave/nginx"
COMPOSE_FILE="${REMNANODE_DIR}/docker-compose.yml"

if [[ $EUID -ne 0 ]]; then
  echo "Запусти скрипт от root"
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "docker не найден"
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "docker compose не найден"
  exit 1
fi

if [[ ! -f "${COMPOSE_FILE}" ]]; then
  echo "Не найден ${COMPOSE_FILE}"
  exit 1
fi

echo
echo "[1/8] Останавливаю Caddy..."
docker stop caddy-remnawave || true

echo
echo "[2/8] Устанавливаю certbot..."
apt update
apt install -y certbot

echo
echo "[3/8] Получаю сертификат для ${DOMAIN}..."
certbot certonly --standalone -d "${DOMAIN}"

echo
echo "[4/8] Создаю папку для сертификатов..."
mkdir -p "${SSL_DIR}"

LIVE_DIR="/etc/letsencrypt/live/${DOMAIN}"

if [[ ! -d "${LIVE_DIR}" ]]; then
  echo "Папка ${LIVE_DIR} не найдена."
  echo "Возможно, certbot создал папку с суффиксом вроде -0001."
  echo "Доступные папки:"
  ls -1 /etc/letsencrypt/live/
  exit 1
fi

echo
echo "[5/8] Копирую сертификаты..."
cp -L "${LIVE_DIR}/fullchain.pem" "${SSL_DIR}/fullchain.pem"
cp -L "${LIVE_DIR}/privkey.pem" "${SSL_DIR}/privkey.key"

echo
echo "[6/8] Проверяю файлы..."
ls -l "${SSL_DIR}"

if [[ ! -f "${SSL_DIR}/fullchain.pem" ]]; then
  echo "Не найден ${SSL_DIR}/fullchain.pem"
  exit 1
fi

if [[ ! -f "${SSL_DIR}/privkey.key" ]]; then
  echo "Не найден ${SSL_DIR}/privkey.key"
  exit 1
fi

echo
echo "[7/8] Проверяю volume в docker-compose..."
if grep -Fq "/opt/remnawave/nginx:/var/lib/remnawave/configs/xray/ssl" "${COMPOSE_FILE}"; then
  echo "Volume уже есть, пропускаю"
else
  echo "Добавляю volume в ${COMPOSE_FILE} ..."
  cat <<EOF >> "${COMPOSE_FILE}"

    volumes:
      - /opt/remnawave/nginx:/var/lib/remnawave/configs/xray/ssl
EOF
fi

echo
echo "[8/8] Перезапускаю ноду..."
cd "${REMNANODE_DIR}"
docker compose down
docker compose up -d

echo
echo "Последние логи remnanode:"
docker compose logs --tail=50

echo
echo "Запускаю Caddy обратно..."
docker start caddy-remnawave || true

echo
echo "=== Готово ==="
echo "Сертификаты лежат в: ${SSL_DIR}"
echo "Домен: ${DOMAIN}"
echo
echo "Проверь, что в Hysteria inbound указано:"
echo '  /var/lib/remnawave/configs/xray/ssl/privkey.key'
echo '  /var/lib/remnawave/configs/xray/ssl/fullchain.pem'
