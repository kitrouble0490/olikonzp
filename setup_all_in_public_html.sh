#!/bin/bash

# Скрипт для настройки Laravel когда весь проект в public_html/
# Использование: ./setup_all_in_public_html.sh

PUBLIC_HTML_DIR="$HOME/public_html"

echo "🚀 Настройка Laravel в public_html/"
echo "Директория: $PUBLIC_HTML_DIR"
echo ""

# Проверка существования директории
if [ ! -d "$PUBLIC_HTML_DIR" ]; then
    echo "❌ Ошибка: Директория $PUBLIC_HTML_DIR не найдена!"
    exit 1
fi

cd "$PUBLIC_HTML_DIR"

# Проверка наличия vendor/
if [ ! -d "vendor" ]; then
    echo "⚠️  Предупреждение: Папка vendor/ не найдена!"
    echo "Убедитесь, что зависимости установлены или загружены."
fi

# 1. Копирование .htaccess
echo "📋 Копирование .htaccess..."
if [ -f "public/.htaccess" ]; then
    cp public/.htaccess .htaccess
    echo "✅ .htaccess скопирован"
elif [ -f ".htaccess" ]; then
    echo "✅ .htaccess уже существует"
else
    echo "⚠️  Файл .htaccess не найден. Создайте его вручную."
fi

# 2. Настройка build/ для Vite
echo "📋 Настройка build/ для Vite..."
if [ -d "public/build" ]; then
    # Если build/ уже в public/, оставляем как есть
    echo "✅ build/ уже в public/"
elif [ -d "build" ]; then
    # Если build/ в корне, создаем public/ и симлинк
    mkdir -p public
    if ln -s ../build public/build 2>/dev/null; then
        echo "✅ Симлинк public/build -> build создан"
    else
        # Если симлинк не работает, перемещаем build/
        mv build public/build
        echo "✅ build/ перемещен в public/build/"
    fi
else
    echo "⚠️  Папка build/ не найдена. Выполните 'npm run build' и загрузите build/"
fi

# Проверка наличия manifest.json
if [ -f "public/build/manifest.json" ] || [ -f "build/manifest.json" ]; then
    echo "✅ manifest.json найден"
else
    echo "⚠️  manifest.json не найден! Vite может не работать."
fi

# 3. Создание правильного index.php
echo "📋 Создание index.php..."
cat > index.php << 'EOF'
<?php

use Illuminate\Foundation\Application;
use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

// Все файлы Laravel находятся в той же директории (public_html/)
if (file_exists($maintenance = __DIR__ . '/storage/framework/maintenance.php')) {
    require $maintenance;
}

// Register the Composer autoloader...
require __DIR__ . '/vendor/autoload.php';

// Bootstrap Laravel and handle the request...
/** @var Application $app */
$app = require_once __DIR__ . '/bootstrap/app.php';

$app->handleRequest(Request::capture());
EOF
echo "✅ index.php создан"

# 4. Защита .env файла в .htaccess
echo "📋 Настройка защиты .env..."
if [ -f ".htaccess" ]; then
    if ! grep -q "<Files .env>" .htaccess; then
        cat >> .htaccess << 'EOF'

# Защита .env файла
<Files .env>
    Order allow,deny
    Deny from all
</Files>
EOF
        echo "✅ Защита .env добавлена в .htaccess"
    else
        echo "✅ Защита .env уже настроена"
    fi
fi

# 5. Настройка прав доступа
echo "📋 Настройка прав доступа..."
chmod -R 775 storage 2>/dev/null || echo "⚠️  Не удалось установить права на storage"
chmod -R 775 bootstrap/cache 2>/dev/null || echo "⚠️  Не удалось установить права на bootstrap/cache"
chmod 644 index.php 2>/dev/null || echo "⚠️  Не удалось установить права на index.php"
chmod 644 .htaccess 2>/dev/null || echo "⚠️  Не удалось установить права на .htaccess"
chmod 600 .env 2>/dev/null || echo "⚠️  Не удалось установить права на .env"
echo "✅ Права доступа настроены"

echo ""
echo "✅ Настройка завершена!"
echo ""
echo "📝 Проверьте структуру:"
echo "   ls -la | grep -E '(index.php|vendor|build|.htaccess)'"
echo ""
echo "🌐 Откройте сайт в браузере для проверки"
