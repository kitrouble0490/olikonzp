# Инструкция по деплою на Timeweb.com

## Подготовка проекта к деплою

### 1. Сборка production версии

Перед загрузкой на сервер необходимо собрать фронтенд:

```bash
# Установить зависимости (если еще не установлены)
npm install

# Собрать production версию
npm run build
```

После выполнения команды `npm run build` будут созданы файлы в `public/build/` директории.

### 2. Проверка файлов для загрузки

Убедитесь, что следующие файлы/директории НЕ будут загружены на сервер (они в .gitignore):
- `.env` (будет создан на сервере)
- `node_modules/` (не нужен на production)
- `vendor/` (будет установлен через composer на сервере)
- `.git/` (опционально)

## Загрузка на Timeweb

### Вариант 1: Через FTP/SFTP

1. **Подключитесь к серверу Timeweb через FTP/SFTP**
   - Используйте данные из панели управления Timeweb
   - Обычно это папка `public_html` или `www`

2. **Структура на сервере:**
   ```
   public_html/
   ├── .htaccess (из public/.htaccess)
   ├── index.php (из public/index.php)
   ├── app/
   ├── bootstrap/
   ├── config/
   ├── database/
   ├── resources/
   ├── routes/
   ├── storage/
   ├── vendor/ (будет создан после composer install)
   └── public/
       └── build/ (собранные файлы фронтенда)
   ```

3. **Важно для Timeweb:**
   - На Timeweb обычно корневая директория сайта - это `public_html`
   - Нужно переместить содержимое папки `public/` в корень `public_html/`
   - Остальные файлы Laravel должны быть на уровень выше или в подпапке

### Вариант 2: Через SSH (рекомендуется)

Если у вас есть доступ к SSH на Timeweb:

```bash
# 1. Подключитесь к серверу через SSH
ssh username@your-domain.com

# 2. Перейдите в директорию проекта
cd ~/public_html  # или путь к вашему сайту

# 3. Клонируйте репозиторий (если используете Git)
git clone https://github.com/your-username/your-repo.git .

# 4. Установите зависимости
# ВАЖНО: Если на сервере старая версия Composer (ошибка composer-runtime-api ^2.2),
# установите зависимости ЛОКАЛЬНО и загрузите папку vendor/ на сервер
composer install --no-dev --optimize-autoloader
# Если composer не работает, см. DEPLOY_TIMEWEB_FIX.md

npm install
npm run build

# 5. Настройте .env файл
cp .env.example .env
nano .env  # отредактируйте настройки

# 6. Сгенерируйте ключ приложения
php artisan key:generate

# 7. Запустите миграции
php artisan migrate --force

# 8. Запустите сидер (создаст пользователя)
php artisan db:seed --force

# 9. Настройте права доступа
chmod -R 755 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
```

## Настройка .env файла на сервере

Создайте файл `.env` на сервере со следующими настройками:

```env
APP_NAME="OLIKON-ЗП"
APP_ENV=production
APP_KEY=base64:... (будет сгенерирован через php artisan key:generate)
APP_DEBUG=false
APP_URL=https://your-domain.com

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=localhost  # или IP адрес БД от Timeweb
DB_PORT=3306
DB_DATABASE=your_database_name
DB_USERNAME=your_database_user
DB_PASSWORD=your_database_password

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

MEMCACHED_HOST=127.0.0.1

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="${APP_NAME}"
```

**Важно:** Получите данные для подключения к БД из панели управления Timeweb.

## Настройка базы данных на Timeweb

1. **Создайте базу данных:**
   - Зайдите в панель управления Timeweb
   - Создайте новую MySQL базу данных
   - Запишите: имя БД, пользователь, пароль, хост

2. **Импортируйте структуру:**
   ```bash
   php artisan migrate --force
   ```

3. **Заполните начальными данными:**
   ```bash
   php artisan db:seed --force
   ```
   Это создаст пользователя:
   - Логин: `olikon`
   - Пароль: `11592309`

## Настройка .htaccess для Timeweb

Если корневая директория - это `public_html`, создайте файл `.htaccess` в корне:

```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteRule ^(.*)$ public/$1 [L]
</IfModule>
```

Или если Laravel установлен в подпапке, настройте пути соответственно.

## Настройка прав доступа

```bash
# Права на запись для storage и cache
chmod -R 775 storage
chmod -R 775 bootstrap/cache

# Владелец (замените на вашего пользователя)
chown -R your_user:your_group storage bootstrap/cache
```

## Оптимизация для production

После деплоя выполните команды оптимизации:

```bash
# Очистка кеша
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Оптимизация автозагрузки
composer install --optimize-autoloader --no-dev
```

## Проверка работы

1. Откройте сайт в браузере
2. Проверьте, что загружается страница авторизации
3. Войдите с учетными данными: `olikon` / `11592309`
4. Проверьте работу API запросов в консоли браузера (F12)

## Возможные проблемы и решения

### Проблема: Composer требует composer-runtime-api ^2.2

**Симптомы:**
```
Your requirements could not be resolved to an installable set of packages.
laravel/framework v12.42.0 requires composer-runtime-api ^2.2 -> no matching package found.
```

**Решение:**
Установите зависимости локально и загрузите `vendor/` на сервер. Подробнее: [DEPLOY_TIMEWEB_FIX.md](DEPLOY_TIMEWEB_FIX.md)

```bash
# На локальной машине
composer install --no-dev --optimize-autoloader

# Загрузите папку vendor/ на сервер через FTP/SFTP
```

### Проблема: 500 Internal Server Error
- Проверьте права доступа к `storage/` и `bootstrap/cache/`
- Проверьте логи: `storage/logs/laravel.log`
- Убедитесь, что `.env` файл создан и настроен правильно

### Проблема: Страница не загружается, белый экран
- Проверьте `APP_DEBUG=true` временно в `.env` для отладки
- Проверьте логи Laravel
- Убедитесь, что `APP_KEY` сгенерирован

### Проблема: CSS/JS не загружаются
- Убедитесь, что выполнили `npm run build`
- Проверьте, что файлы в `public/build/` существуют
- Проверьте права доступа к `public/build/`

### Проблема: Ошибки подключения к БД
- Проверьте данные подключения в `.env`
- Убедитесь, что БД создана и пользователь имеет права
- Проверьте, что хост БД правильный (может быть `localhost` или IP)

### Проблема: Сессии не работают
- Проверьте права на `storage/framework/sessions/`
- Убедитесь, что `SESSION_DRIVER=file` в `.env`

## Обновление проекта

При обновлении кода на сервере:

```bash
# 1. Получите обновления (если используете Git)
git pull origin main

# 2. Установите новые зависимости
composer install --no-dev --optimize-autoloader
npm install
npm run build

# 3. Запустите миграции (если есть новые)
php artisan migrate --force

# 4. Очистите кеш
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan cache:clear

# 5. Пересоздайте кеш
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

## Контакты поддержки Timeweb

Если возникнут проблемы с хостингом, обратитесь в поддержку Timeweb:
- Телефон: указан в панели управления
- Email: support@timeweb.com
- Чат в панели управления

