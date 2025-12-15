#!/bin/bash

# Скрипт для настройки Laravel на Timeweb
# Использование: ./setup_timeweb.sh [имя_директории_проекта]
# По умолчанию: olikonzp

PROJECT_NAME=${1:-olikonzp}
PUBLIC_HTML_DIR="$HOME/public_html"
PROJECT_DIR="$HOME/$PROJECT_NAME"

echo "🚀 Настройка Laravel на Timeweb"
echo "Проект: $PROJECT_NAME"
echo "Директория проекта: $PROJECT_DIR"
echo "Public HTML: $PUBLIC_HTML_DIR"
echo ""

# Проверка существования директорий
if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ Ошибка: Директория проекта $PROJECT_DIR не найдена!"
    echo "Создайте её и загрузите туда Laravel проект."
    exit 1
fi

if [ ! -d "$PUBLIC_HTML_DIR" ]; then
    echo "❌ Ошибка: Директория $PUBLIC_HTML_DIR не найдена!"
    exit 1
fi

# Проверка наличия vendor/
if [ ! -d "$PROJECT_DIR/vendor" ]; then
    echo "⚠️  Предупреждение: Папка vendor/ не найдена в проекте!"
    echo "Убедитесь, что зависимости установлены или загружены."
fi

# 1. Копирование .htaccess
echo "📋 Копирование .htaccess..."
if [ -f "$PROJECT_DIR/public/.htaccess" ]; then
    cp "$PROJECT_DIR/public/.htaccess" "$PUBLIC_HTML_DIR/.htaccess"
    echo "✅ .htaccess скопирован"
else
    echo "⚠️  Файл .htaccess не найден в public/"
fi

# 2. Создание index.php
echo "📋 Создание index.php в public_html..."
cat > "$PUBLIC_HTML_DIR/index.php" << EOF
<?php

use Illuminate\Foundation\Application;
use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

// Путь к Laravel проекту (на уровень выше public_html)
\$laravelPath = __DIR__ . '/../$PROJECT_NAME';

// Determine if the application is in maintenance mode...
if (file_exists(\$maintenance = \$laravelPath . '/storage/framework/maintenance.php')) {
    require \$maintenance;
}

// Register the Composer autoloader...
require \$laravelPath . '/vendor/autoload.php';

// Bootstrap Laravel and handle the request...
/** @var Application \$app */
\$app = require_once \$laravelPath . '/bootstrap/app.php';

\$app->handleRequest(Request::capture());
EOF
echo "✅ index.php создан"

# 3. Копирование build/
echo "📋 Копирование build/..."
if [ -d "$PROJECT_DIR/public/build" ]; then
    cp -r "$PROJECT_DIR/public/build" "$PUBLIC_HTML_DIR/build"
    echo "✅ build/ скопирован"
else
    echo "⚠️  Папка build/ не найдена в public/"
    echo "Выполните 'npm run build' на локальной машине и загрузите build/"
fi

# 4. Создание симлинка для storage (если возможно)
echo "📋 Настройка storage..."
if [ -d "$PROJECT_DIR/storage/app/public" ]; then
    # Пробуем создать симлинк
    if ln -sf "../$PROJECT_NAME/storage/app/public" "$PUBLIC_HTML_DIR/storage" 2>/dev/null; then
        echo "✅ Симлинк storage создан"
    else
        echo "⚠️  Не удалось создать симлинк. Создайте storage вручную или скопируйте файлы."
        echo "   Команда: ln -s ../$PROJECT_NAME/storage/app/public $PUBLIC_HTML_DIR/storage"
    fi
else
    echo "⚠️  storage/app/public не найден"
fi

# 5. Настройка прав доступа
echo "📋 Настройка прав доступа..."
chmod -R 775 "$PROJECT_DIR/storage" 2>/dev/null || echo "⚠️  Не удалось установить права на storage"
chmod -R 775 "$PROJECT_DIR/bootstrap/cache" 2>/dev/null || echo "⚠️  Не удалось установить права на bootstrap/cache"
chmod 644 "$PUBLIC_HTML_DIR/index.php" 2>/dev/null || echo "⚠️  Не удалось установить права на index.php"
chmod 644 "$PUBLIC_HTML_DIR/.htaccess" 2>/dev/null || echo "⚠️  Не удалось установить права на .htaccess"
echo "✅ Права доступа настроены"

echo ""
echo "✅ Настройка завершена!"
echo ""
echo "📝 Проверьте:"
echo "1. Структура директорий правильная?"
echo "2. Файл $PUBLIC_HTML_DIR/index.php создан?"
echo "3. Папка $PUBLIC_HTML_DIR/build/ существует?"
echo "4. Права доступа настроены?"
echo ""
echo "🌐 Откройте сайт в браузере для проверки"
