#!/bin/bash

# Скрипт для исправления проблемы с Vite assets (404 ошибки)
# Использование: ./fix_vite_assets.sh

PUBLIC_HTML_DIR="$HOME/public_html"

echo "🔧 Исправление проблемы с Vite assets"
echo ""

if [ ! -d "$PUBLIC_HTML_DIR" ]; then
    echo "❌ Ошибка: Директория $PUBLIC_HTML_DIR не найдена!"
    exit 1
fi

cd "$PUBLIC_HTML_DIR"

# Проверка наличия build/
echo "📋 Проверка структуры..."
if [ -d "build/assets" ]; then
    echo "✅ build/assets/ найден"
    ASSETS_PATH="build/assets"
elif [ -d "public/build/assets" ]; then
    echo "✅ public/build/assets/ найден"
    ASSETS_PATH="public/build/assets"
else
    echo "❌ Ошибка: Папка assets не найдена!"
    echo "Загрузите build/ с локальной машины (должна содержать assets/)"
    exit 1
fi

# Проверка наличия файлов
echo ""
echo "📋 Проверка файлов..."
CSS_COUNT=$(find "$ASSETS_PATH" -name "*.css" 2>/dev/null | wc -l)
JS_COUNT=$(find "$ASSETS_PATH" -name "*.js" 2>/dev/null | wc -l)

if [ "$CSS_COUNT" -gt 0 ]; then
    echo "✅ Найдено CSS файлов: $CSS_COUNT"
    find "$ASSETS_PATH" -name "*.css" | head -3
else
    echo "⚠️  CSS файлы не найдены!"
fi

if [ "$JS_COUNT" -gt 0 ]; then
    echo "✅ Найдено JS файлов: $JS_COUNT"
    find "$ASSETS_PATH" -name "*.js" | head -3
else
    echo "⚠️  JS файлы не найдены!"
fi

# Установка прав доступа
echo ""
echo "📋 Настройка прав доступа..."
if [ -d "build" ]; then
    chmod -R 755 build 2>/dev/null
    find build/assets -type f -exec chmod 644 {} \; 2>/dev/null
    echo "✅ Права на build/ установлены"
fi

if [ -d "public/build" ]; then
    chmod -R 755 public/build 2>/dev/null
    find public/build/assets -type f -exec chmod 644 {} \; 2>/dev/null
    echo "✅ Права на public/build/ установлены"
fi

# Проверка .htaccess
echo ""
echo "📋 Проверка .htaccess..."
if [ -f ".htaccess" ]; then
    if grep -q "RewriteCond %{REQUEST_FILENAME} !-f" .htaccess; then
        echo "✅ .htaccess настроен правильно для обслуживания статических файлов"
    else
        echo "⚠️  .htaccess может не обслуживать статические файлы правильно"
    fi
else
    echo "⚠️  Файл .htaccess не найден!"
fi

# Проверка симлинка (если используется)
echo ""
echo "📋 Проверка симлинка public/build..."
if [ -L "public/build" ]; then
    TARGET=$(readlink public/build)
    if [ -d "$TARGET" ]; then
        echo "✅ Симлинк public/build -> $TARGET работает"
    else
        echo "⚠️  Симлинк указывает на несуществующую директорию: $TARGET"
        echo "Пересоздаю симлинк..."
        rm public/build
        ln -s ../build public/build
        echo "✅ Симлинк пересоздан"
    fi
elif [ -d "public/build" ] && [ ! -L "public/build" ]; then
    echo "✅ public/build/ существует как директория (не симлинк)"
fi

echo ""
echo "✅ Проверка завершена!"
echo ""
echo "📝 Следующие шаги:"
echo "1. Проверьте доступность файла в браузере:"
echo "   https://kitrouble-app.ru/build/assets/app-*.css"
echo "2. Если 404 - проверьте, что файлы действительно загружены"
echo "3. Если 403 - проверьте права доступа: chmod -R 755 build"
echo "4. Проверьте консоль браузера (F12) на наличие ошибок"
