#!/usr/bin/env bash
set -Eeuo pipefail

echo "=== Hysteria2 node preparation ==="

read -r -p "Домен: " DOMAIN

if [[ -z "${DOMAIN}" ]]; then
  echo "Домен не указан"
  exit 1
fi

REMNANODE_DIR="/opt/remnanode"
SSL_DIR="/opt/remnawave/nginx"
COMPOSE_FILE="${REMNANODE_DIR}/docker-compose.yml"

# Hysteria settings
FAST_PORT="443"
STEALTH_PORT="444"
HOP_RANGE="20000:50000"

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
echo "[1/10] Останавливаю Caddy..."
docker stop caddy-remnawave || true

echo
echo "[2/10] Устанавливаю certbot..."
apt update
apt install -y certbot

echo
echo "[3/10] Получаю сертификат для ${DOMAIN}..."
certbot certonly --standalone -d "${DOMAIN}"

echo
echo "[4/10] Создаю папку для сертификатов..."
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
echo "[5/10] Копирую сертификаты..."
cp -L "${LIVE_DIR}/fullchain.pem" "${SSL_DIR}/fullchain.pem"
cp -L "${LIVE_DIR}/privkey.pem" "${SSL_DIR}/privkey.key"

echo
echo "[6/10] Проверяю файлы..."
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
echo "[7/10] Проверяю volume в docker-compose..."
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
echo "[8/10] Открываю UDP-порты..."
if command -v ufw >/dev/null 2>&1; then
  ufw allow ${FAST_PORT}/udp || true
  ufw allow ${STEALTH_PORT}/udp || true
  ufw allow ${HOP_RANGE}/udp || true
else
  echo "ufw не найден, пропускаю открытие портов через ufw"
fi

echo
echo "[9/10] Добавляю правило ротации портов Hysteria..."
RULE_EXISTS=0
if iptables -t nat -C PREROUTING -p udp --dport ${HOP_RANGE} -j REDIRECT --to-ports ${STEALTH_PORT} 2>/dev/null; then
  RULE_EXISTS=1
fi

if [[ "${RULE_EXISTS}" -eq 1 ]]; then
  echo "Правило iptables уже существует, пропускаю"
else
  iptables -t nat -A PREROUTING -p udp --dport ${HOP_RANGE} -j REDIRECT --to-ports ${STEALTH_PORT}
  echo "Правило добавлено: ${HOP_RANGE}/udp -> ${STEALTH_PORT}/udp"
fi

if ! command -v netfilter-persistent >/dev/null 2>&1; then
  apt install -y iptables-persistent
fi

netfilter-persistent save || true

echo
echo "[10/10] Перезапускаю ноду..."
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
echo "Проверить:"
echo "1) Hysteria FAST:    ${FAST_PORT}/udp"
echo "2) Hysteria STEALTH: ${STEALTH_PORT}/udp"
echo "3) Port hopping:     ${HOP_RANGE}/udp -> ${STEALTH_PORT}/udp"
echo
echo "Посмотреть правило:"
echo "iptables -t nat -L -n -v"
