#!/usr/bin/env bash
set -Eeuo pipefail

APP_DIR="/opt/mtproxy-telemt"
CONFIG_FILE="$APP_DIR/telemt.toml"
COMPOSE_FILE="$APP_DIR/docker-compose.yml"
CONTAINER_NAME="telemt"

red()    { printf '\033[31m%s\033[0m\n' "$*"; }
green()  { printf '\033[32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[33m%s\033[0m\n' "$*"; }
blue()   { printf '\033[36m%s\033[0m\n' "$*"; }

need_root() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    red "Запусти скрипт от root: sudo bash $0"
    exit 1
  fi
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

ask() {
  local prompt="$1"
  local var_name="$2"
  local default="${3:-}"
  local value

  if [[ -n "$default" ]]; then
    read -r -p "$prompt [$default]: " value
    value="${value:-$default}"
  else
    read -r -p "$prompt: " value
  fi

  printf -v "$var_name" '%s' "$value"
}

ask_optional() {
  local prompt="$1"
  local var_name="$2"
  local value
  read -r -p "$prompt: " value
  printf -v "$var_name" '%s' "$value"
}

require_nonempty() {
  local value="$1"
  local label="$2"
  if [[ -z "$value" ]]; then
    red "Поле \"$label\" не может быть пустым."
    exit 1
  fi
}

validate_port() {
  local port="$1"
  [[ "$port" =~ ^[0-9]+$ ]] || return 1
  (( port >= 1 && port <= 65535 ))
}

install_docker() {
  if command_exists docker; then
    green "Docker уже установлен."
    return
  fi

  yellow "Docker не найден. Устанавливаю..."
  curl -fsSL https://get.docker.com | sh

  if ! command_exists docker; then
    red "Не удалось установить Docker."
    exit 1
  fi

  if command_exists systemctl; then
    systemctl enable docker >/dev/null 2>&1 || true
    systemctl restart docker >/dev/null 2>&1 || true
  fi

  green "Docker установлен."
}

install_compose_plugin() {
  if docker compose version >/dev/null 2>&1; then
    green "Docker Compose plugin уже доступен."
    return
  fi

  yellow "Плагин docker compose не найден. Пытаюсь установить..."
  if command_exists apt-get; then
    apt-get update
    apt-get install -y docker-compose-plugin
  elif command_exists dnf; then
    dnf install -y docker-compose-plugin
  elif command_exists yum; then
    yum install -y docker-compose-plugin
  elif command_exists apk; then
    apk add docker-cli-compose
  else
    red "Не смог автоматически установить docker compose plugin."
    red "Установи его вручную и запусти скрипт снова."
    exit 1
  fi

  docker compose version >/dev/null 2>&1 || {
    red "docker compose все еще недоступен."
    exit 1
  }

  green "Docker Compose plugin установлен."
}

install_helpers() {
  local packages=()

  command_exists curl || packages+=("curl")
  command_exists openssl || packages+=("openssl")
  command_exists jq || packages+=("jq")
  command_exists xxd || packages+=("xxd")

  if [[ ${#packages[@]} -eq 0 ]]; then
    return
  fi

  yellow "Устанавливаю недостающие утилиты: ${packages[*]}"

  if command_exists apt-get; then
    apt-get update
    apt-get install -y "${packages[@]}"
  elif command_exists dnf; then
    dnf install -y "${packages[@]}"
  elif command_exists yum; then
    yum install -y "${packages[@]}"
  elif command_exists apk; then
    apk add "${packages[@]}"
  else
    red "Не смог автоматически установить: ${packages[*]}"
    exit 1
  fi
}

generate_secret() {
  openssl rand -hex 16
}

write_config() {
  mkdir -p "$APP_DIR"

  {
    echo 'show_link = ["user1"]'
    echo
    echo '[general]'
    echo 'prefer_ipv6 = false'
    echo 'fast_mode = true'
    echo 'use_middle_proxy = true'
    if [[ -n "$ADTAG" ]]; then
      echo "ad_tag = \"$ADTAG\""
    fi
    echo
    echo '[general.modes]'
    echo 'classic = false'
    echo 'secure = true'
    echo 'tls = true'
    echo
    echo '[general.links]'
    echo 'show = ["user1"]'
    echo "public_host = \"$PUBLIC_HOST\""
    echo "public_port = $PUBLIC_PORT"
    echo
    echo '[server]'
    echo "port = $LISTEN_PORT"
    echo 'listen_addr_ipv4 = "0.0.0.0"'
    echo 'listen_addr_ipv6 = "::"'
    echo
    echo '[server.api]'
    echo 'enabled = true'
    echo 'listen = "0.0.0.0:9091"'
    echo 'whitelist = ["0.0.0.0/0", "::/0"]'
    echo 'minimal_runtime_enabled = false'
    echo 'minimal_runtime_cache_ttl_ms = 1000'
    echo
    echo '[censorship]'
    echo "tls_domain = \"$TLS_DOMAIN\""
    echo 'mask = true'
    echo 'mask_port = 443'
    echo 'fake_cert_len = 2048'
    echo
    echo '[access.users]'
    echo "user1 = \"$SECRET\""
    echo
    echo '[[upstreams]]'
    echo 'type = "direct"'
    echo 'enabled = true'
    echo 'weight = 10'
  } > "$CONFIG_FILE"
}

write_compose() {
  cat > "$COMPOSE_FILE" <<EOF
services:
  telemt:
    image: whn0thacked/telemt-docker:latest
    container_name: $CONTAINER_NAME
    restart: unless-stopped
    environment:
      RUST_LOG: "info"
    volumes:
      - ./telemt.toml:/etc/telemt.toml:ro
    ports:
      - "$LISTEN_PORT:$LISTEN_PORT/tcp"
      - "127.0.0.1:9091:9091/tcp"
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
    read_only: true
    tmpfs:
      - /tmp:rw,nosuid,nodev,noexec,size=16m
EOF
}

start_container() {
  cd "$APP_DIR"
  docker compose down >/dev/null 2>&1 || true
  docker compose pull
  docker compose up -d
}

wait_for_api() {
  local tries=30
  local i

  for ((i=1; i<=tries; i++)); do
    if curl -fsS "http://127.0.0.1:9091/v1/users" >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done

  return 1
}

build_manual_tls_link_ee() {
  local sni_hex
  sni_hex="$(printf '%s' "$TLS_DOMAIN" | xxd -p -c 9999 | tr -d '\n')"
  printf 'tg://proxy?server=%s&port=%s&secret=ee%s%s\n' \
    "$PUBLIC_HOST" "$PUBLIC_PORT" "$SECRET" "$sni_hex"
}

build_manual_secure_link_dd() {
  printf 'tg://proxy?server=%s&port=%s&secret=dd%s\n' \
    "$PUBLIC_HOST" "$PUBLIC_PORT" "$SECRET"
}

get_links_from_api() {
  local json
  json="$(curl -fsS "http://127.0.0.1:9091/v1/users")"

  EE_LINK="$(printf '%s' "$json" | jq -r '.data[] | select(.username=="user1") | .links.tls[0] // empty')"
  DD_LINK="$(printf '%s' "$json" | jq -r '.data[] | select(.username=="user1") | .links.secure[0] // empty')"
}

show_summary() {
  echo
  blue "===== ГОТОВО ====="
  echo "Папка:        $APP_DIR"
  echo "Конфиг:       $CONFIG_FILE"
  echo "Compose:      $COMPOSE_FILE"
  echo "Порт сервера: $LISTEN_PORT"
  echo "Public host:  $PUBLIC_HOST"
  echo "Public port:  $PUBLIC_PORT"
  echo "SNI domain:   $TLS_DOMAIN"
  echo "AdTag:        ${ADTAG:-<не задан>}"
  echo "Secret:       $SECRET"
  echo
}

main() {
  need_root
  install_docker
  install_compose_plugin
  install_helpers

  blue "Настройка MTProxy (Telemt Docker)"
  echo
  SECRET="$(generate_secret)"

  blue "Сгенерирован secret для прокси:"
  echo "$SECRET"
  echo

  yellow "Добавь этот secret в @MTProxybot и получи adtag"
  echo

  ask_optional "Введите adtag (или оставь пустым)" ADTAG

  ask "Введите домен или IP сервера" PUBLIC_HOST
  require_nonempty "$PUBLIC_HOST" "публичный домен или IP"

  ask "Порт MTProxy" LISTEN_PORT "443"
  if ! validate_port "$LISTEN_PORT"; then
    red "Некорректный порт: $LISTEN_PORT"
    exit 1
  fi

  ask "Порт, указанный в боте (если отличается)" PUBLIC_PORT "$LISTEN_PORT"
  if ! validate_port "$PUBLIC_PORT"; then
    red "Некорректный порт: $PUBLIC_PORT"
    exit 1
  fi

  write_config
  write_compose
  start_container

  show_summary

  EE_LINK=""
  DD_LINK=""

  yellow "Жду запуск API Telemt..."
  if wait_for_api; then
    get_links_from_api || true
  fi

  if [[ -z "${DD_LINK:-}" ]]; then
    DD_LINK="$(build_manual_secure_link_dd)"
  fi

  if [[ -z "${EE_LINK:-}" ]]; then
    EE_LINK="$(build_manual_tls_link_ee)"
  fi

  green "Proxy:"
  echo "$EE_LINK"
  echo "$DD_LINK"
  echo

  blue "Логи контейнера:"
  echo "cd $APP_DIR && docker compose logs -f"
}

main "$@"
