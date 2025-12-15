# Решение проблемы с Composer на Timeweb

## Проблема

Laravel 12 требует `composer-runtime-api ^2.2`, но на хостинге Timeweb установлена **Composer 1.9.0** (2019 год), которая не поддерживает эту версию API.

**Ошибка:**
```
laravel/framework v12.42.0 requires composer-runtime-api ^2.2 -> no matching package found.
```

## ⚠️ ВАЖНО: Для Composer 1.9.0

**Обязательно устанавливайте зависимости ЛОКАЛЬНО** и загружайте папку `vendor/` на сервер. Composer 1.9.0 не может установить Laravel 12.

## Решения

### Решение 1: Установка зависимостей локально (ОБЯЗАТЕЛЬНО для Composer 1.9.0)

**Это единственный рабочий способ для Composer 1.9.0!**

Соберите `vendor/` директорию локально и загрузите на сервер:

```bash
# На локальной машине (где Composer версии 2.x)
cd /home/kit/web/olikonzp

# Установите зависимости
composer install --no-dev --optimize-autoloader

# Проверьте, что vendor/ создан
ls -la vendor/ | head -5

# Соберите фронтенд
npm run build
```

**Загрузка на сервер:**
1. Загрузите все файлы проекта через FTP/SFTP
2. **ОБЯЗАТЕЛЬНО включите папку `vendor/`** в загрузку
3. Также загрузите папку `public/build/` (собранный фронтенд)

**Преимущества:**
- ✅ Работает с любой версией Composer на сервере
- ✅ Не требует обновления Composer на сервере
- ✅ Быстрее, чем установка на сервере
- ✅ Единственный способ для Composer 1.9.0

### Решение 2: Установка свежего Composer локально (если есть SSH)

Если у вас есть доступ к SSH, можно установить свежий Composer локально в проект:

```bash
# На сервере через SSH
cd ~/public_html  # или путь к вашему проекту

# Скачайте и установите Composer 2.x локально
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php --install-dir=. --filename=composer.phar
php -r "unlink('composer-setup.php');"

# Используйте локальный Composer 2.x
php composer.phar install --no-dev --optimize-autoloader

# После установки можно удалить composer.phar (vendor/ уже установлен)
# rm composer.phar
```

**Примечание:** Этот способ требует PHP 7.2+ на сервере и может не работать, если есть ограничения на выполнение скриптов.

### Решение 3: Обновление системного Composer (обычно НЕВОЗМОЖНО на shared хостинге)

На shared хостинге Timeweb обычно **нет прав** для обновления системного Composer.

Если у вас VPS или выделенный сервер с root доступом:

```bash
# Обновите Composer до последней версии
composer self-update

# Или установите через официальный установщик
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
php -r "unlink('composer-setup.php');"
```

**Для shared хостинга:** Используйте **Решение 1** (установка локально).

### Решение 4: Использование готового архива с vendor/

Создайте архив проекта с уже установленными зависимостями:

```bash
# На локальной машине
composer install --no-dev --optimize-autoloader
npm run build

# Создайте архив (исключая .git, node_modules, но включая vendor/)
tar --exclude='.git' \
    --exclude='node_modules' \
    --exclude='.env' \
    --exclude='storage/logs/*' \
    --exclude='storage/framework/cache/*' \
    --exclude='storage/framework/sessions/*' \
    --exclude='storage/framework/views/*' \
    -czf olikonzp-full.tar.gz .

# Загрузите архив на сервер и распакуйте
```

## Рекомендуемый процесс деплоя (для Composer 1.9.0)

### Шаг 1: Подготовка на локальной машине (ОБЯЗАТЕЛЬНО)

```bash
# 1. Убедитесь, что у вас Composer 2.x локально
composer --version
# Должно быть что-то вроде: Composer version 2.x.x

# 2. Установите зависимости
composer install --no-dev --optimize-autoloader

# 3. Проверьте, что vendor/ создан
ls -la vendor/ | head -5
# Должны быть папки: symfony, laravel, и т.д.

# 4. Соберите фронтенд
npm run build

# 5. Проверьте, что build/ создан
ls -la public/build/
# Должны быть файлы: .vite, assets/
```

### Шаг 2: Загрузка на сервер

**Вариант A: Через FTP/SFTP (рекомендуется)**
1. Загрузите все файлы проекта
2. **ОБЯЗАТЕЛЬНО включите папку `vendor/`** в загрузку (это критично!)
3. **ОБЯЗАТЕЛЬНО включите папку `public/build/`** в загрузку
4. Убедитесь, что структура правильная

**Вариант B: Через архив**
```bash
# На локальной машине создайте архив с vendor/
tar --exclude='.git' \
    --exclude='node_modules' \
    --exclude='.env' \
    --exclude='storage/logs/*' \
    --exclude='storage/framework/cache/*' \
    --exclude='storage/framework/sessions/*' \
    --exclude='storage/framework/views/*' \
    -czf olikonzp-full.tar.gz .

# Загрузите архив на сервер и распакуйте
```

**Проверка после загрузки:**
```bash
# На сервере проверьте наличие vendor/
ls -la vendor/ | head -5
# Должны быть папки: symfony, laravel, и т.д.
```

### Шаг 3: Настройка на сервере

```bash
# 1. Создайте .env
cp .env.example .env
nano .env  # настройте

# 2. Сгенерируйте ключ (vendor/ уже должен быть загружен)
php artisan key:generate

# 3. Запустите миграции
php artisan migrate --force

# 4. Заполните БД
php artisan db:seed --force

# 5. Настройте права
chmod -R 775 storage bootstrap/cache

# 6. Оптимизируйте (vendor/ уже установлен)
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

## Проверка версии Composer на сервере

Проверьте версию Composer на сервере:

```bash
composer --version
```

**Если версия 1.9.0 или ниже 2.2:**
- ✅ Используйте **Решение 1** (установка локально) - это ОБЯЗАТЕЛЬНО
- ❌ НЕ пытайтесь использовать системный Composer для установки Laravel 12

**Если версия 2.2+:**
- Можно использовать системный Composer на сервере
- Но установка локально всё равно быстрее и надежнее

## Обновление проекта

При обновлении кода:

```bash
# На локальной машине
git pull  # или загрузите новые файлы
composer install --no-dev --optimize-autoloader
npm run build

# Загрузите обновленные файлы на сервер
# ВАЖНО: Загрузите обновленную папку vendor/ если composer.json изменился
```

## Альтернатива: Понижение версии Laravel (НЕ РЕКОМЕНДУЕТСЯ)

Если ничего не помогает, можно понизить версию Laravel до 11.x, но это потребует изменений в коде и не рекомендуется.

## Подавление Deprecation Warnings

Если видите много deprecation warnings (но Composer работает), можно подавить их:

```bash
# В .env добавьте
COMPOSER_DISABLE_XDEBUG_WARN=1

# Или при запуске composer
COMPOSER_DISABLE_XDEBUG_WARN=1 composer install --no-dev
```

Но это не решает основную проблему с версией Composer.

