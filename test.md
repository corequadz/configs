# ==== ДАННЫЕ БОТА ==== #
BOT_TOKEN=8749047329:AAFVc0Tfo3WfYdhGHNz2YloCT8hrXRJ0yL4 # токен бота
ADMIN_IDS=7248569541 # id админов
SUPPORT_USERNAME=@S0VAsbot # ссылка на поддержку


# ==== НАСТРОЙКИ РАЗРАБОТКИ ==== #
DEBUG=false
MAIN_MENU_MODE=cabinet
TEST_EMAIL=regspace7@gmail.com
TEST_EMAIL_PASSWORD=Das59386
BOT_RUN_MODE=webhook
MENU_LAYOUT_ENABLED=true
# URL SOCKS5 прокси-сервера для маршрутизации трафика бота к Telegram API
# Формат: socks5://user:password@host:port или socks5://host:port
# PROXY_URL=socks5://127.0.0.1:1080
CABINET_BUTTON_STYLE=
# Включить управление меню через API (позволяет динамически менять структуру кнопок)
MENU_LAYOUT_ENABLED=true
# Режим работы кнопки "Подключиться"
# guide - открывает гайд подключения (режим 1)
# miniapp_subscription - открывает ссылку подписки в мини-приложении (режим 2)
# miniapp_custom - открывает заданную ссылку в мини-приложении (режим 3)
# link - Открывает ссылку напрямую в браузере (режим 4)
# happ_cryptolink - Вывод cryptoLink ссылки на подписку Happ (режим 5)
CONNECT_BUTTON_MODE=miniapp_subscription


# ===== НАСТРОЙКИ БАЗЫ ДАННЫХ =====
# Режим базы данных: "auto", "postgresql", "sqlite"
DATABASE_MODE=auto
# Основной URL (можно оставить пустым для автоматического выбора)
DATABASE_URL=
# PostgreSQL настройки (для Docker и кастомных установок)
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=remnawave_bot
POSTGRES_USER=remnawave_user
POSTGRES_PASSWORD=8GrLKdxtHngigAWfD836N4Udt4DofN7XYC03eLOeIbpfYFcunLmHV+GZeXtD+Ee9WAgQqnyjjfq09ITqUgoZNQ==

# SQLite настройки (для локального запуска)
SQLITE_PATH=./data/bot.db
LOCALES_PATH=./locales

# Redis
REDIS_URL=redis://redis:6379/0
# Время жизни корзины пользователя в Redis (секунды, по умолчанию 1 час)
CART_TTL_SECONDS=3600


# ===== REMNAWAVE =====
REMNAWAVE_API_URL=https://corequad.store
REMNAWAVE_API_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1dWlkIjoiMTc0MzA4YzYtOWQyYy00MGRlLTkwYjctNjkxMGZhZTBmMzQwIiwidXNlcm5hbWUiOm51bGwsInJvbGUiOiJBUEkiLCJpYXQiOjE3NzUzMjAxMzcsImV4cCI6MTA0MTUyMzM3Mzd9.kZj7stTXuMz8uvUPxoKI7cZI471paSOIcvCCaEzV2oI
# Тип авторизации: "api_key", "basic_auth", "caddy"
REMNAWAVE_AUTH_TYPE=api_key
REMNAWAVE_CADDY_TOKEN=
# Для панелей с Basic Auth (опционально)
REMNAWAVE_USERNAME=
REMNAWAVE_PASSWORD=
# Для панелей установленных скриптом eGames прописывать ключ в формате XXXXXXX:DDDDDDDD
REMNAWAVE_SECRET_KEY=


# ==== ВЕБ-СЕРВЕР ==== #
WEB_API_ENABLED=true
WEB_API_HOST=0.0.0.0
WEB_API_PORT=8080
# Количество воркеров (для продакшена рекомендуется 2-4)
WEB_API_WORKERS=4
WEB_API_ALLOWED_ORIGINS=https://miniapp.corequad.store
WEB_API_DOCS_ENABLED=false
# Название и версия API (для документации)
WEB_API_TITLE=Remnawave Bot Admin API
WEB_API_VERSION=1.0.0
# Токен по умолчанию для начальной настройки
WEB_API_DEFAULT_TOKEN=cc2ce24d4977e40f72849e2f605b8ccf725c5c47334fd44d8ce8fa6f7fae2105
WEB_API_DEFAULT_TOKEN_NAME=Bootstrap Token
# Алгоритм хеширования токенов
WEB_API_TOKEN_HASH_ALGORITHM=sha256
# Логирование запросов
WEB_API_REQUEST_LOGGING=true
# Внешний админ-токен (для интеграции с другими ботами/системами)
# Токен для доступа через API другого бота
# EXTERNAL_ADMIN_TOKEN=
# ID бота, от которого принимается токен
# EXTERNAL_ADMIN_TOKEN_BOT_ID=
MINIAPP_STATIC_PATH=miniapp


# ==== ВЕБХУКИ ==== #
# Включить приём вебхуков от панели Remnawave (real-time события)
REMNAWAVE_WEBHOOK_ENABLED=true 
# Путь для приёма вебхуков (должен совпадать с настройкой в панели)
REMNAWAVE_WEBHOOK_PATH=/remnawave-webhook
# Общий секрет для подписи HMAC-SHA256 (минимум 32 символа)
# Сгенерируйте: openssl rand -hex 32
# ВАЖНО: этот же секрет указывается в панели Remnawave при создании вебхука
REMNAWAVE_WEBHOOK_SECRET=21bd70038a361685f801350cb92c32082ac10fde0ba857eaef59eb8b3d88626ad6f98aeb5e24c287b267db44ab68f563884faa2b1e8924c01a7b8155f81f0b40
WEBHOOK_URL=https://webhook.corequad.store
WEBHOOK_PATH=/webhook
WEBHOOK_SECRET_TOKEN=a345086e28beed88785d906434b491f429b4be3e848542c17ba081d7e9d6f148


# ==== MINIAPP ==== #
# URL для режима miniapp_custom (обязателен при CONNECT_BUTTON_MODE=miniapp_custom)
MINIAPP_CUSTOM_URL=https://cabinet.corequad.store
MINIAPP_STATIC_PATH=miniapp
# URL для редиректа на страницу покупки в мини-приложении (опционально)
# MINIAPP_PURCHASE_URL=
MINIAPP_SERVICE_NAME_EN=SoVa VPN
MINIAPP_SERVICE_NAME_RU=SoVa VPN
MINIAPP_SERVICE_DESCRIPTION_EN=Secure & Fast Connection
MINIAPP_SERVICE_DESCRIPTION_RU=Безопасное и быстрое подключение


# ===== CABINET =====
# Включить личный кабинет пользователя (веб-интерфейс для управления подпиской)
CABINET_ENABLED=true
# URL кабинета для ссылок в email (например: https://cabinet.example.com)
CABINET_URL=https://cabinet.corequad.store
# Секретный ключ для JWT токенов (если не указан, используется BOT_TOKEN)
CABINET_JWT_SECRET=272ea3bc78216758d5516c4682a76539645390ea1a4826caa3779615178ea955
# Время жизни access token в минутах (по умолчанию 15)
CABINET_ACCESS_TOKEN_EXPIRE_MINUTES=15
# Время жизни refresh token в днях (по умолчанию 7)
CABINET_REFRESH_TOKEN_EXPIRE_DAYS=7
# Разрешенные origins для CORS (через запятую, например: https://cabinet.example.com)
CABINET_ALLOWED_ORIGINS=https://cabinet.corequad.store
# Включить верификацию email (требует настройки SMTP)
CABINET_EMAIL_VERIFICATION_ENABLED=true
# Включить регистрацию/вход по email (если false - только Telegram)
CABINET_EMAIL_AUTH_ENABLED=true
CABINET_EMAIL_CHANGE_CODE_EXPIRE_MINUTES=15
CABINET_EMAIL_VERIFICATION_EXPIRE_HOURS=24
CABINET_PASSWORD_RESET_EXPIRE_HOURS=1
# Включить OIDC авторизацию
TELEGRAM_OIDC_ENABLED=true
# Client ID (числовой ID бота)
TELEGRAM_OIDC_CLIENT_ID=8749047329
# Client Secret от BotFather
TELEGRAM_OIDC_CLIENT_SECRET=n_j9fuJdNo61gC41GPNxWJWdAyabg_7QWZ5tLQDnjuW3SE7Tu79srw


# ===== SMTP НАСТРОЙКИ (для email в личном кабинете) =====
# SMTP сервер (например: smtp.gmail.com, smtp.yandex.ru)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=agbg8607@gmail.com
SMTP_PASSWORD=vxktsqyinoukwvna
# Email отправителя (если не указан, используется SMTP_USER)
SMTP_FROM_EMAIL=agbg8607@gmail.com
SMTP_FROM_NAME=SoVa VPN
# Использовать TLS шифрование
SMTP_USE_TLS=true


# === TELEGRAM WIDGET (кастомизация) ===
TELEGRAM_WIDGET_SIZE=large
TELEGRAM_WIDGET_RADIUS=8
TELEGRAM_WIDGET_USERPIC=true
TELEGRAM_WIDGET_REQUEST_ACCESS=true