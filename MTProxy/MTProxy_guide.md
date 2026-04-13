# Подниманием MTProxy на своем сервер


---
Для установки можно воспользоваться скриптом, повторяет описанные далее действия

```
curl -fsSL https://raw.githubusercontent.com/corequadz/configs/main/MTProxy/install.sh -o install.sh && sudo bash install.sh
```

---

1. Установливаем Docker
```
sudo curl -fsSL https://get.docker.com | sh
```

2. Создаем секрет
```
openssl rand -hex 16
```
Сохраняем его

3. Создает рабочую папку и файл конфигурации

```
mkdir -p /root/mtproxy-telemt && cd /root/mtproxy-telemt && nano telemt.toml
```

> telemt.toml:
```
# telemt.toml
show_link = ["user1"]

[general]
prefer_ipv6 = false
fast_mode = true
use_middle_proxy = true
ad_tag = "тег из бота"

[general.modes]
classic = false
secure = true
tls = true

[server]
port = 443
listen_addr_ipv4 = "0.0.0.0"
listen_addr_ipv6 = "::"

[censorship]
tls_domain = ""   # домен для SNI
mask = true
mask_port = 443
fake_cert_len = 2048

[access.users]
user1 = "секрет из шага 2"

[[upstreams]]
type = "direct"
enabled = true
weight = 10
```

4. Создаем докер-файл
```
nano docker-compose.yml
```

> docker-compose.yml

```
services:
  telemt:
    image: whn0thacked/telemt-docker:latest
    container_name: telemt
    restart: unless-stopped
    environment:
      RUST_LOG: "info"
    volumes:
      - ./telemt.toml:/etc/telemt.toml:ro
    ports:
      - "443:443/tcp"
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
    read_only: true
    tmpfs:
      - /tmp:rw,nosuid,nodev,noexec,size=16m
    deploy:
      resources:
        limits:
          cpus: "0.50"
          memory: 256M
```

5. Поднимаем контейнер
```
docker compose up -d && docker compose logs -f
```
