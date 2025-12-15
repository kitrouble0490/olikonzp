#!/bin/bash

# Скрипт для исправления проблемы MIME типов
# Использование: ./fix_mime_types.sh

PUBLIC_HTML_DIR="$HOME/public_html"

echo "🔧 Исправление проблемы MIME типов"
echo ""

if [ ! -d "$PUBLIC_HTML_DIR" ]; then
    echo "❌ Ошибка: Директория $PUBLIC_HTML_DIR не найдена!"
    exit 1
fi

cd "$PUBLIC_HTML_DIR"

# Создание исправленного .htaccess
echo "📋 Создание исправленного .htaccess..."
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
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
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

# Проверка наличия файлов
echo ""
echo "📋 Проверка наличия файлов..."
if [ -d "build/assets" ]; then
    JS_COUNT=$(find build/assets -name "*.js" 2>/dev/null | wc -l)
    CSS_COUNT=$(find build/assets -name "*.css" 2>/dev/null | wc -l)
    echo "✅ Найдено JS файлов: $JS_COUNT"
    echo "✅ Найдено CSS файлов: $CSS_COUNT"
    
    if [ "$JS_COUNT" -gt 0 ]; then
        echo "Пример JS файла:"
        find build/assets -name "*.js" | head -1
    fi
else
    echo "⚠️  Папка build/assets/ не найдена!"
fi

# Проверка favicon
if [ -f "favicon.ico" ]; then
    echo "✅ favicon.ico найден"
elif [ -f "public/favicon.ico" ]; then
    echo "✅ public/favicon.ico найден"
else
    echo "⚠️  favicon.ico не найден"
fi

# Установка прав
chmod 644 .htaccess
echo "✅ Права на .htaccess установлены"

echo ""
echo "✅ Исправление завершено!"
echo ""
echo "📝 Следующие шаги:"
echo "1. Очистите кеш браузера (Ctrl+Shift+R)"
echo "2. Проверьте консоль браузера (F12) - не должно быть ошибок MIME"
echo "3. Проверьте Network tab - файлы должны иметь правильные Content-Type"
echo ""
echo "Проверьте доступность:"
echo "curl -I https://kitrouble-app.ru/build/assets/app-*.js"
echo "curl -I https://kitrouble-app.ru/favicon.ico"
