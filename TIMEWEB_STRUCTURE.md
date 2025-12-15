# Правильная структура для Timeweb

## Проблема

На Timeweb корневая директория сайта - это `public_html/`, но Laravel требует, чтобы файлы приложения были на уровень выше для безопасности.

## Решение: Правильная структура

### Вариант 1: Laravel на уровень выше (РЕКОМЕНДУЕТСЯ)

```
/home/username/
├── olikonzp/              ← Laravel проект (на уровень выше public_html)
│   ├── app/
│   ├── bootstrap/
│   ├── config/
│   ├── database/
│   ├── resources/
│   ├── routes/
│   ├── storage/
│   ├── vendor/
│   └── public/            ← Содержимое будет скопировано в public_html
│       ├── .htaccess
│       ├── index.php
│       ├── build/
│       └── ...
└── public_html/           ← Корневая директория сайта (Timeweb)
    ├── .htaccess          ← Из public/.htaccess
    ├── index.php          ← Из public/index.php (с исправленными путями)
    ├── build/             ← Из public/build/
    └── ...                ← Остальное содержимое public/
```

### Шаги настройки:

1. **Загрузите Laravel проект** в `~/olikonzp/` (на уровень выше `public_html/`)

2. **Создайте специальный `index.php` для `public_html/`:**

Создайте файл `public_html/index.php` со следующим содержимым:

```php
<?php

use Illuminate\Foundation\Application;
use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

// Путь к Laravel проекту (на уровень выше)
$laravelPath = __DIR__ . '/../olikonzp';

// Determine if the application is in maintenance mode...
if (file_exists($maintenance = $laravelPath . '/storage/framework/maintenance.php')) {
    require $maintenance;
}

// Register the Composer autoloader...
require $laravelPath . '/vendor/autoload.php';

// Bootstrap Laravel and handle the request...
/** @var Application $app */
$app = require_once $laravelPath . '/bootstrap/app.php';

$app->handleRequest(Request::capture());
```

3. **Скопируйте `.htaccess`** из `public/.htaccess` в `public_html/.htaccess`

4. **Скопируйте содержимое `public/build/`** в `public_html/build/`

5. **Создайте симлинк для storage** (если поддерживается) или скопируйте:

```bash
# На сервере через SSH
cd ~/public_html
ln -s ../olikonzp/storage/app/public storage
```

Или создайте `public_html/storage` и скопируйте файлы.

### Вариант 2: Все в public_html (менее безопасно, но проще)

Если нет доступа к уровню выше `public_html/`, можно разместить все в `public_html/`:

```
public_html/
├── .htaccess
├── index.php          ← Из public/index.php (пути остаются как есть)
├── app/
├── bootstrap/
├── config/
├── database/
├── resources/
├── routes/
├── storage/
├── vendor/
└── build/             ← Из public/build/
```

В этом случае `index.php` остается как есть, но это менее безопасно.

## Исправление путей в index.php

Если используете Вариант 1, создайте файл `public_html/index.php` с правильными путями.

## Проверка структуры

После настройки проверьте:

```bash
# На сервере
cd ~/public_html
ls -la
# Должны быть: .htaccess, index.php, build/

cd ~/olikonzp
ls -la
# Должны быть: app/, bootstrap/, config/, vendor/, и т.д.
```

## Настройка .env

В `.env` файле (который должен быть в `~/olikonzp/.env`):

```env
APP_URL=https://your-domain.com
```

## Права доступа

```bash
# Права на storage и cache
chmod -R 775 ~/olikonzp/storage
chmod -R 775 ~/olikonzp/bootstrap/cache

# Права на public_html
chmod 755 ~/public_html
chmod 644 ~/public_html/index.php
chmod 644 ~/public_html/.htaccess
```
