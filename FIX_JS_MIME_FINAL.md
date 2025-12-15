# Финальное исправление проблемы MIME для JS файлов

## Проблема

JS файлы возвращаются как `text/html` вместо `application/javascript`. Favicon работает, но JS нет.

## Причина

Запросы к `/build/assets/app-*.js` попадают в `index.php` вместо обслуживания как статические файлы.

## Решение

### Вариант 1: Исправленный .htaccess (РЕКОМЕНДУЕТСЯ)

Добавьте специальное правило для `/build/` пути ПЕРЕД правилом для `index.php`:

```apache
# Специальное правило для build/ (Vite assets)
RewriteCond %{REQUEST_URI} ^/build/
RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI} -f
RewriteRule ^ - [L]
```

### Вариант 2: Проверка путей

Убедитесь, что файлы находятся по правильному пути:

```bash
# На сервере
cd ~/public_html

# Проверьте, где находятся файлы
ls -la build/assets/app-*.js | head -1
# Должен показать реальный файл

# Проверьте доступность напрямую
curl -I https://kitrouble-app.ru/build/assets/app-D8W0Dedn.js
# Должен вернуть: Content-Type: application/javascript
# НЕ должен вернуть: Content-Type: text/html
```

### Вариант 3: Если файлы в public/build/

Если вы используете симлинк `public/build -> ../build`, проверьте:

```bash
# Проверьте симлинк
ls -la public/build/assets/app-*.js | head -1

# Если не работает, пересоздайте
rm public/build
ln -s ../build public/build
```

## Быстрое исправление

```bash
# На сервере через SSH
cd ~/public_html

# Обновите .htaccess с правильным порядком правил
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
    # Сначала проверяем реальные файлы
    RewriteCond %{REQUEST_FILENAME} -f [OR]
    RewriteCond %{REQUEST_FILENAME} -d
    RewriteRule ^ - [L]
    
    # Специальное правило для build/ (Vite assets)
    RewriteCond %{REQUEST_URI} ^/build/
    RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI} -f
    RewriteRule ^ - [L]
    
    # Send Requests To Front Controller...
    RewriteRule ^ index.php [L]
</IfModule>

# MIME типы
<IfModule mod_mime.c>
    AddType application/javascript js mjs
    AddType application/json json
    AddType text/css css
    AddType image/svg+xml svg svgz
    AddType image/x-icon ico
    AddType image/png png
    AddType image/jpeg jpg jpeg
    AddType image/gif gif
    AddType image/webp webp
    AddType font/woff woff
    AddType font/woff2 woff2
</IfModule>

# Защита .env
<Files .env>
    Order allow,deny
    Deny from all
</Files>
EOF

chmod 644 .htaccess
```

## Диагностика

Проверьте, что происходит:

```bash
# 1. Проверьте наличие файлов
cd ~/public_html
find . -name "app-*.js" -type f | head -3

# 2. Проверьте доступность через curl
curl -I https://kitrouble-app.ru/build/assets/app-D8W0Dedn.js 2>&1 | grep -i "content-type"

# Должно быть: Content-Type: application/javascript
# НЕ должно быть: Content-Type: text/html

# 3. Проверьте, что файл действительно существует
ls -la build/assets/app-D8W0Dedn.js
# Или
ls -la public/build/assets/app-D8W0Dedn.js
```

## Если проблема сохраняется

Возможно, проблема в том, что Laravel Vite генерирует пути относительно `public/`, но файлы находятся в корне `public_html/`.

Проверьте `manifest.json`:

```bash
cat public/build/manifest.json | grep -A 5 "app.js"
# Посмотрите, какие пути там указаны
```

Если пути неправильные, возможно нужно настроить `APP_URL` в `.env` или использовать другой подход.
