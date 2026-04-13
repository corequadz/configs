# Установка Remnanode + selfsteal

## Шаг 1. Установка Remnanode

1. Устанавливаем Docker
```bash
sudo curl -fsSL https://get.docker.com | sh
```

2. Создаем рабочую директорию и открываем docker-compose файл
```bash
mkdir /opt/remnanode && cd /opt/remnanode && nano docker-compose.yml
```

3. Переходим в панель: **Ноды -> Управление**. Нажимаем **+**, вводим данные ноды, после чего нажимаем **Копировать docker-compose.yml**.

4. Вставляем конфигурацию в `docker-compose.yml`, сохраняем.

5. Запускаем ноду:
```bash
docker compose up -d && docker compose logs -f
```

После завершения загрузки в панели нажимаем **Далее**, выбираем любой хост и подключаем ноду.

## Шаг 2. Настраиваем selfsteal

```bash
bash <(curl -s https://raw.githubusercontent.com/corequadz/configs/main/Remnanode/install_selfsteal.sh)
```

## Шаг 3. Настройка конфига

Используй общий конфиг (тот же, что и для Hysteria2).

## Дальше

Переходи к Hysteria2: [guide_hysteria2.md](./guide_hysteria2.md)
