#!/usr/bin/env bash
set -Eeuo pipefail

echo "=== Selfsteal setup ==="

read -r -p "Домен: " DOMAIN
read -r -p "Порт (дефолт 9443): " PORT

if [[ -z "$DOMAIN" ]]; then
  echo "Домен не указан"
  exit 1
fi

if [[ -z "$PORT" ]]; then
  echo "Порт не указан"
  exit 1
fi

BASE_DIR="/opt/selfsteal"
HTML_DIR="/opt/html"

mkdir -p "$BASE_DIR"
mkdir -p "$HTML_DIR"
mkdir -p "$BASE_DIR/logs"

cd "$BASE_DIR"

cat > .env <<EOF
SELF_STEAL_DOMAIN=$DOMAIN
SELF_STEAL_PORT=$PORT
EOF

cat > Caddyfile <<'EOF'
{
    https_port {$SELF_STEAL_PORT}
    default_bind 127.0.0.1

    servers {
        listener_wrappers {
            proxy_protocol {
                allow 127.0.0.1/32
            }
            tls
        }
    }

    auto_https disable_redirects
}

http://{$SELF_STEAL_DOMAIN} {
    bind 0.0.0.0
    redir https://{$SELF_STEAL_DOMAIN}{uri} permanent
}

https://{$SELF_STEAL_DOMAIN} {
    root * /var/www/html
    try_files {path} /index.html
    file_server
}

:{$SELF_STEAL_PORT} {
    tls internal
    respond 204
}

:80 {
    bind 0.0.0.0
    respond 204
}
EOF

cat > docker-compose.yml <<EOF
services:
  caddy:
    image: caddy:latest
    container_name: caddy-remnawave
    restart: unless-stopped
    network_mode: host
    env_file:
      - .env
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - ${HTML_DIR}:/var/www/html
      - ./logs:/var/log/caddy
      - caddy_data_selfsteal:/data
      - caddy_config_selfsteal:/config

volumes:
  caddy_data_selfsteal:
  caddy_config_selfsteal:
EOF

cat > "$HTML_DIR/index.html" <<EOF
<!doctype html>
<html lang="ru">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>$DOMAIN</title>
</head>
<body>
  <h1>It works</h1>
</body>
</html>
EOF

docker compose up -d

echo
echo "=== Готово ==="
echo "Папка: $BASE_DIR"
echo "Домен: $DOMAIN"
echo "Порт для realitySettings.dest: $PORT"
echo
echo "Проверь:"
echo "  docker compose -f $BASE_DIR/docker-compose.yml ps"
echo "  docker logs caddy-remnawave --tail 100"