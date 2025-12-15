#!/bin/bash

# Скрипт для исправления путей к build/ на сервере
# Использование: ./fix_build_paths.sh

PUBLIC_HTML_DIR="$HOME/public_html"

echo "🔧 Исправление путей к build/ на сервере"
echo ""

if [ ! -d "$PUBLIC_HTML_DIR" ]; then
    echo "❌ Ошибка: Директория $PUBLIC_HTML_DIR не найдена!"
    exit 1
fi

cd "$PUBLIC_HTML_DIR"

# Проверка структуры
echo "📋 Проверка текущей структуры..."
if [ -d "public/build/assets" ]; then
    echo "✅ Файлы находятся в: public/build/assets/"
    JS_COUNT=$(find public/build/assets -name "*.js" 2>/dev/null | wc -l)
    CSS_COUNT=$(find public/build/assets -name "*.css" 2>/dev/null | wc -l)
    echo "   JS файлов: $JS_COUNT"
    echo "   CSS файлов: $CSS_COUNT"
    
    # Создаем симлинк build -> public/build
    echo ""
    echo "📋 Создание симлинка build -> public/build..."
    if [ -L "build" ]; then
        echo "⚠️  Симлинк build уже существует, пересоздаю..."
        rm build
    elif [ -d "build" ]; then
        echo "⚠️  Директория build существует, перемещаю в build.old..."
        mv build build.old
    fi
    
    ln -s public/build build
    echo "✅ Симлинк build -> public/build создан"
    
elif [ -d "build/assets" ]; then
    echo "✅ Файлы находятся в: build/assets/"
    echo "   Структура правильная, ничего не нужно менять"
else
    echo "❌ Ошибка: Не найдены файлы ни в build/assets/, ни в public/build/assets/"
    echo "Загрузите build/ на сервер!"
    exit 1
fi

# Обновление .htaccess
echo ""
echo "📋 Обновление .htaccess..."
cat > .htaccess << 'EOF'
<IfModule mod_rewrite.c>
    <IfModule mod_negotiation.c>
        Options -MultiViews -Indexes
    </IfModule>

    RewriteEngine On

    # Handle Authorization Header
    RewriteCond %{HTTP:Authorization} .
    RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]

    # Handle X-XSRF-Token Header
    RewriteCond %{HTTP:x-xsrf-token} .
    RewriteRule .* - [E=HTTP_X_XSRF_TOKEN:%{HTTP:X-XSRF-Token}]

    # Redirect Trailing Slashes If Not A Folder...
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_URI} (.+)/$
    RewriteRule ^ %1 [L,R=301]

    # ВАЖНО: Обслуживание статических файлов ДО index.php
    # Правило 1: Если файл существует физически - обслуживаем его напрямую
    RewriteCond %{REQUEST_FILENAME} -f
    RewriteRule ^ - [L]
    
    # Правило 2: Если директория существует - обслуживаем её напрямую
    RewriteCond %{REQUEST_FILENAME} -d
    RewriteRule ^ - [L]
    
    # Send Requests To Front Controller (только если файл/директория не существует)...
    RewriteRule ^ index.php [L]
</IfModule>

# MIME типы для статических файлов
<IfModule mod_mime.c>
    # JavaScript
    AddType application/javascript js mjs
    AddType application/json json
    
    # CSS
    AddType text/css css
    
    # Images
    AddType image/svg+xml svg svgz
    AddType image/x-icon ico
    AddType image/png png
    AddType image/jpeg jpg jpeg
    AddType image/gif gif
    AddType image/webp webp
    
    # Fonts
    AddType font/woff woff
    AddType font/woff2 woff2
    AddType application/font-woff woff
    AddType application/font-woff2 woff2
    AddType application/vnd.ms-fontobject eot
    AddType font/ttf ttf
    AddType font/otf otf
    
    # Other
    AddType application/xml xml
    AddType text/plain txt
</IfModule>

# Кеширование статических файлов
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType image/gif "access plus 1 year"
    ExpiresByType image/webp "access plus 1 year"
    ExpiresByType image/svg+xml "access plus 1 year"
    ExpiresByType image/x-icon "access plus 1 year"
    ExpiresByType application/javascript "access plus 1 year"
    ExpiresByType text/css "access plus 1 year"
    ExpiresByType font/woff "access plus 1 year"
    ExpiresByType font/woff2 "access plus 1 year"
</IfModule>

# Защита .env файла
<Files .env>
    Order allow,deny
    Deny from all
</Files>
EOF

echo "✅ .htaccess обновлен"

# Проверка
echo ""
echo "📋 Финальная проверка..."
if [ -L "build" ]; then
    TARGET=$(readlink -f build)
    if [ -d "$TARGET/assets" ]; then
        echo "✅ Симлинк build -> $TARGET работает"
        echo "✅ Файлы доступны по пути: build/assets/"
        ls -la build/assets/*.js 2>/dev/null | head -1 | awk '{print "   Пример: " $9 " (" $5 " байт)"}'
    else
        echo "❌ Целевая директория не содержит assets/"
    fi
fi

# Установка прав
chmod 644 .htaccess
chmod -R 755 build 2>/dev/null || chmod -R 755 public/build 2>/dev/null
find build/assets -type f -exec chmod 644 {} \; 2>/dev/null || find public/build/assets -type f -exec chmod 644 {} \; 2>/dev/null

echo ""
echo "✅ Исправление завершено!"
echo ""
echo "📝 Проверьте:"
echo "1. ls -la build/assets/app-*.js (должен показать файлы)"
echo "2. Очистите кеш браузера (Ctrl+Shift+R)"
echo "3. Проверьте консоль браузера (F12) - не должно быть ошибок MIME"
