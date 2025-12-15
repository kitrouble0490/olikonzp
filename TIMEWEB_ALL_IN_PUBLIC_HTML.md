# Настройка Laravel когда весь проект в public_html/

## Структура проекта

Если весь проект находится в `public_html/`:

```
public_html/
├── .htaccess          ← Из public/.htaccess
├── index.php          ← Используйте public_html_all_in_one_index.php
├── app/
├── bootstrap/
├── config/
├── database/
├── resources/
├── routes/
├── storage/
├── vendor/
├── .env
└── build/             ← Из public/build/ (или public/build/)
```

## Быстрая настройка

### Шаг 1: Загрузите все файлы Laravel в `public_html/`

Включая:
- `app/`, `bootstrap/`, `config/`, `database/`, `resources/`, `routes/`, `storage/`, `vendor/`
- Все файлы из корня проекта (`.env`, `composer.json`, и т.д.)

### Шаг 2: Скопируйте содержимое `public/` в корень `public_html/`

```bash
# На сервере через SSH
cd ~/public_html

# Скопируйте .htaccess (используйте версию с защитой .env)
cp public/.htaccess .htaccess
# Или используйте готовый файл: public/.htaccess.with-env-protection

# Добавьте защиту .env в .htaccess (если еще нет)
cat >> .htaccess << 'EOF'

# Защита .env файла
<Files .env>
    Order allow,deny
    Deny from all
</Files>
EOF

# Скопируйте build/
cp -r public/build .  # или cp -r public/build build

# Используйте правильный index.php
cp public_html_all_in_one_index.php index.php
# Или создайте вручную (см. ниже)
```

### Шаг 3: Создайте правильный `index.php`

**Вариант A: Используйте готовый файл**

```bash
# Загрузите public_html_all_in_one_index.php на сервер
# Скопируйте его в public_html/index.php
cp public_html_all_in_one_index.php index.php
```

**Вариант B: Создайте вручную**

Создайте файл `public_html/index.php`:

```php
<?php

use Illuminate\Foundation\Application;
use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

// Все файлы Laravel находятся в той же директории (public_html/)
if (file_exists($maintenance = __DIR__ . '/storage/framework/maintenance.php')) {
    require $maintenance;
}

require __DIR__ . '/vendor/autoload.php';

/** @var Application $app */
$app = require_once __DIR__ . '/bootstrap/app.php';

$app->handleRequest(Request::capture());
```

### Шаг 4: Настройте права доступа

```bash
chmod -R 775 storage bootstrap/cache
chmod 644 index.php .htaccess
```

### Шаг 5: Настройте `.env`

Убедитесь, что в `public_html/.env`:

```env
APP_URL=https://your-domain.com
APP_ENV=production
APP_DEBUG=false
```

## Автоматический скрипт

Создайте файл `setup_all_in_public_html.sh`:

```bash
#!/bin/bash

cd ~/public_html

# 1. Копирование .htaccess
if [ -f "public/.htaccess" ]; then
    cp public/.htaccess .htaccess
    echo "✅ .htaccess скопирован"
fi

# 2. Копирование build/
if [ -d "public/build" ]; then
    cp -r public/build build
    echo "✅ build/ скопирован"
fi

# 3. Создание правильного index.php
cat > index.php << 'EOF'
<?php
use Illuminate\Foundation\Application;
use Illuminate\Http\Request;
define('LARAVEL_START', microtime(true));
if (file_exists($maintenance = __DIR__ . '/storage/framework/maintenance.php')) {
    require $maintenance;
}
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->handleRequest(Request::capture());
EOF
echo "✅ index.php создан"

# 4. Настройка прав
chmod -R 775 storage bootstrap/cache
chmod 644 index.php .htaccess
echo "✅ Права доступа настроены"

echo ""
echo "✅ Настройка завершена!"
```

Запустите:
```bash
chmod +x setup_all_in_public_html.sh
./setup_all_in_public_html.sh
```

## Важные моменты

### ⚠️ Безопасность

Когда весь проект в `public_html/`, файлы конфигурации могут быть доступны через браузер. Убедитесь, что:

1. `.env` файл защищен (должен быть в `.htaccess`):
   ```apache
   <Files .env>
       Order allow,deny
       Deny from all
   </Files>
   ```

2. `.htaccess` правильно настроен (из `public/.htaccess`)

3. Чувствительные файлы не доступны напрямую

### Проверка структуры

```bash
# На сервере
cd ~/public_html
ls -la

# Должны быть:
# - index.php (правильный, с путями __DIR__)
# - .htaccess
# - app/, bootstrap/, config/, vendor/, storage/
# - build/
```

## Отладка

### 500 Internal Server Error

**Проверьте:**
1. Пути в `index.php` правильные? (должны быть `__DIR__ . '/...'`, не `__DIR__ . '/../...'`)
2. Существует ли `vendor/`?
3. Права доступа настроены?

```bash
# Проверьте пути
cd ~/public_html
php -r "echo __DIR__ . '/vendor/autoload.php';"  # Должен показать правильный путь

# Проверьте vendor/
ls -la vendor/ | head -5

# Проверьте логи
tail -f storage/logs/laravel.log
```

### 403 Forbidden

**Причина:** Неправильные права доступа или `.htaccess` блокирует доступ.

**Решение:**
```bash
chmod 644 index.php .htaccess
chmod -R 755 app bootstrap config routes
chmod -R 775 storage bootstrap/cache
```

### Class '...' not found

**Причина:** `vendor/` не загружен или путь неправильный.

**Решение:**
```bash
# Проверьте наличие vendor/
ls -la vendor/

# Если нет - загрузите с локальной машины
# Убедитесь, что vendor/ находится в public_html/
```

## Сравнение вариантов

| Вариант | Безопасность | Сложность | Рекомендуется |
|---------|-------------|-----------|---------------|
| Проект на уровень выше | ✅ Высокая | Средняя | ✅ Да |
| Все в public_html/ | ⚠️ Ниже | Простая | Если нет другого выхода |

## Итоговая команда для быстрой настройки

```bash
# На сервере через SSH
cd ~/public_html

# 1. Скопируйте .htaccess
cp public/.htaccess .htaccess

# 2. Скопируйте build/
cp -r public/build build

# 3. Создайте index.php
cat > index.php << 'EOF'
<?php
use Illuminate\Foundation\Application;
use Illuminate\Http\Request;
define('LARAVEL_START', microtime(true));
if (file_exists($maintenance = __DIR__ . '/storage/framework/maintenance.php')) {
    require $maintenance;
}
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->handleRequest(Request::capture());
EOF

# 4. Настройте права
chmod -R 775 storage bootstrap/cache
chmod 644 index.php .htaccess

# 5. Проверьте
ls -la | grep -E "(index.php|vendor|build)"
```

## Проверка работы

После настройки:

1. Откройте сайт: `https://your-domain.com`
2. Должна открыться страница авторизации
3. Если ошибка - проверьте логи: `tail -f storage/logs/laravel.log`
