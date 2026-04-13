# Установка Hysteria2

> Требуется установленный Remnanode

## Быстрая установка

```bash
bash <(curl -s https://raw.githubusercontent.com/corequadz/configs/main/Remnanode/install_hysteria2.sh)
```

## Основные шаги

1. Остановить Caddy
```bash
docker stop caddy-remnawave
```

2. Получить сертификаты
```bash
apt install certbot -y
certbot certonly --standalone -d ваш_домен
```

3. Перенести сертификаты
```bash
mkdir -p /opt/remnawave/nginx
cp -L /etc/letsencrypt/live/ваш_домен/fullchain.pem /opt/remnawave/nginx/fullchain.pem
cp -L /etc/letsencrypt/live/ваш_домен/privkey.pem /opt/remnawave/nginx/privkey.key
```

4. Добавить volume в docker-compose
```yaml
- /opt/remnawave/nginx:/var/lib/remnawave/configs/xray/ssl
```

5. Перезапустить ноду
```bash
cd /opt/remnanode && docker compose down && docker compose up -d
```

6. Запустить Caddy
```bash
docker start caddy-remnawave
```

## Конфиг

Используется тот же конфиг, что и в selfsteal гайде.
