# Деплой для Timeweb с Composer 1.9.0

## ⚠️ ВАЖНО

На Timeweb установлена **Composer 1.9.0** (2019 год), которая **НЕ МОЖЕТ** установить Laravel 12.

**Решение:** Установите зависимости **ЛОКАЛЬНО** и загрузите папку `vendor/` на сервер.

## Пошаговая инструкция

### Шаг 1: Локальная подготовка (ОБЯЗАТЕЛЬНО)

```bash
# 1. Перейдите в директорию проекта
cd /home/kit/web/olikonzp

# 2. Убедитесь, что локально Composer 2.x
composer --version
# Должно быть: Composer version 2.x.x

# 3. Установите зависимости
composer install --no-dev --optimize-autoloader

# 4. Проверьте создание vendor/
ls -la vendor/ | head -10
# Должны быть папки: symfony, laravel, monolog, и т.д.

# 5. Соберите фронтенд
npm run build

# 6. Проверьте создание build/
ls -la public/build/
# Должны быть: .vite, assets/
```

### Шаг 2: Создание архива (опционально)

```bash
# Создайте архив со ВСЕМИ файлами, включая vendor/
tar --exclude='.git' \
    --exclude='node_modules' \
    --exclude='.env' \
    --exclude='storage/logs/*' \
    --exclude='storage/framework/cache/*' \
    --exclude='storage/framework/sessions/*' \
    --exclude='storage/framework/views/*' \
    -czf olikonzp-full.tar.gz .

# Размер архива будет около 50-100 МБ (из-за vendor/)
```

### Шаг 3: Загрузка на сервер

**Через FTP/SFTP:**
1. Подключитесь к серверу Timeweb
2. Загрузите **ВСЕ** файлы проекта
3. **КРИТИЧНО:** Убедитесь, что папка `vendor/` загружена (она большая, ~50 МБ)
4. **КРИТИЧНО:** Убедитесь, что папка `public/build/` загружена

**Через архив:**
1. Загрузите `olikonzp-full.tar.gz` на сервер
2. Распакуйте: `tar -xzf olikonzp-full.tar.gz`

### Шаг 4: Проверка на сервере

```bash
# 1. Проверьте наличие vendor/
ls -la vendor/ | head -5
# Должны быть папки: symfony, laravel, и т.д.

# Если vendor/ отсутствует - ЗАГРУЗИТЕ ЕГО С ЛОКАЛЬНОЙ МАШИНЫ!

# 2. Проверьте наличие build/
ls -la public/build/
# Должны быть файлы: .vite, assets/
```

### Шаг 5: Настройка на сервере

```bash
# ВАЖНО: НЕ выполняйте composer install на сервере!
# vendor/ уже должен быть загружен

# 1. Создайте .env
cp .env.example .env
nano .env

# 2. Настройте .env:
# APP_ENV=production
# APP_DEBUG=false
# APP_URL=https://your-domain.com
# DB_CONNECTION=mysql
# DB_HOST=localhost (или IP от Timeweb)
# DB_DATABASE=your_db_name
# DB_USERNAME=your_db_user
# DB_PASSWORD=your_db_password

# 3. Сгенерируйте ключ
php artisan key:generate

# 4. Запустите миграции
php artisan migrate --force

# 5. Заполните БД
php artisan db:seed --force

# 6. Настройте права
chmod -R 775 storage bootstrap/cache

# 7. Оптимизируйте
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### Шаг 6: Проверка работы

1. Откройте сайт: `https://your-domain.com`
2. Должна открыться страница авторизации
3. Войдите: `olikon` / `11592309`
4. Проверьте работу приложения

## Частые ошибки

### Ошибка: Class '...' not found

**Причина:** Папка `vendor/` не загружена или неполная.

**Решение:**
```bash
# Проверьте наличие vendor/
ls -la vendor/

# Если нет - загрузите с локальной машины
# Убедитесь, что загрузили ВСЮ папку vendor/ (она большая!)
```

### Ошибка: Composer требует composer-runtime-api ^2.2

**Причина:** Пытаетесь выполнить `composer install` на сервере.

**Решение:** НЕ выполняйте `composer install` на сервере! Используйте уже загруженную папку `vendor/`.

### Ошибка: CSS/JS не загружаются

**Причина:** Папка `public/build/` не загружена.

**Решение:**
```bash
# Проверьте наличие build/
ls -la public/build/

# Если нет - выполните локально npm run build и загрузите
```

## Обновление проекта

При обновлении кода:

```bash
# На локальной машине
git pull  # или загрузите новые файлы
composer install --no-dev --optimize-autoloader  # если composer.json изменился
npm run build  # если изменился фронтенд

# Загрузите обновленные файлы на сервер
# Если composer.json изменился - загрузите обновленную vendor/
```

## Итоговая структура на сервере

```
public_html/
├── .env
├── app/
├── bootstrap/
├── config/
├── database/
├── public/
│   ├── build/          ← ОБЯЗАТЕЛЬНО (собранный фронтенд)
│   ├── index.php
│   └── ...
├── resources/
├── routes/
├── storage/
├── vendor/              ← ОБЯЗАТЕЛЬНО (загружен с локальной машины)
└── ...
```

## Контакты

Если возникли проблемы:
- Проверьте логи: `storage/logs/laravel.log`
- Убедитесь, что `vendor/` загружен полностью
- Убедитесь, что `public/build/` загружен
- Проверьте права доступа: `chmod -R 775 storage bootstrap/cache`
