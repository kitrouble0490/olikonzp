# Исправление проблемы MIME типов (text/html вместо application/javascript)

## Проблема

```
Загрузка модуля по адресу «https://kitrouble-app.ru/build/assets/app-D8W0Dedn.js» 
была заблокирована из-за неразрешенного MIME-типа («text/html»).
```

Файлы JS, CSS и favicon возвращаются как `text/html` вместо правильных MIME типов.

## Причина

1. **Статические файлы попадают в `index.php`** - `.htaccess` не обслуживает их напрямую
2. **Неправильные пути** - файлы не найдены, сервер возвращает `index.php` (который HTML)
3. **Отсутствие MIME типов** - не настроены правильные типы для статических файлов

## Решение

### Шаг 1: Обновите .htaccess

Используйте исправленный `.htaccess`:

```bash
# На сервере
cd ~/public_html
cp public/.htaccess.fixed .htaccess
# Или скопируйте содержимое файла .htaccess.fixed в .htaccess
```

**Ключевые изменения:**

1. **Правильный порядок правил** - статические файлы обслуживаются ДО index.php:
   ```apache
   RewriteCond %{REQUEST_FILENAME} !-f
   RewriteCond %{REQUEST_FILENAME} !-d
   RewriteRule ^ index.php [L]
   ```

2. **MIME типы** - добавлены правильные типы для JS, CSS, изображений:
   ```apache
   AddType application/javascript js mjs
   AddType text/css css
   AddType image/x-icon ico
   ```

### Шаг 2: Проверьте пути к файлам

Убедитесь, что файлы существуют:

```bash
# На сервере
cd ~/public_html

# Проверьте наличие файлов
ls -la build/assets/app-*.js
ls -la build/assets/app-*.css
ls -la favicon.ico  # или public/favicon.ico

# Если используете симлинк public/build
ls -la public/build/assets/app-*.js
```

### Шаг 3: Проверьте структуру

Если весь проект в `public_html/`, структура должна быть:

```
public_html/
├── .htaccess          ← Исправленный
├── index.php
├── build/
│   └── assets/
│       ├── app-*.js
│       └── app-*.css
└── favicon.ico        ← или public/favicon.ico
```

### Шаг 4: Проверьте доступность файлов

```bash
# Проверьте доступность напрямую
curl -I https://kitrouble-app.ru/build/assets/app-D8W0Dedn.js
# Должен вернуть: Content-Type: application/javascript

curl -I https://kitrouble-app.ru/favicon.ico
# Должен вернуть: Content-Type: image/x-icon
```

## Быстрое исправление

```bash
# На сервере через SSH
cd ~/public_html

# 1. Создайте исправленный .htaccess
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

# 2. Проверьте права
chmod 644 .htaccess

# 3. Проверьте наличие файлов
ls -la build/assets/app-*.js | head -1
ls -la build/assets/app-*.css | head -1
```

## Проверка работы

После исправления:

1. **Очистите кеш браузера** (Ctrl+Shift+R или Cmd+Shift+R)
2. **Откройте консоль браузера** (F12)
3. **Проверьте Network tab** - файлы должны загружаться с правильными MIME типами:
   - `app-*.js` → `application/javascript`
   - `app-*.css` → `text/css`
   - `favicon.ico` → `image/x-icon`

## Дополнительная диагностика

Если проблема сохраняется:

```bash
# Проверьте, что файлы действительно существуют
cd ~/public_html
find . -name "app-*.js" -type f
find . -name "favicon.ico" -type f

# Проверьте логи Apache (если доступны)
tail -f /var/log/apache2/error.log
# или
tail -f ~/logs/error.log
```

## Альтернативное решение: Настройка через routes/web.php

Если `.htaccess` не работает, можно добавить маршрут для статических файлов:

```php
// routes/web.php
Route::get('/build/{path}', function ($path) {
    $filePath = public_path("build/{$path}");
    if (file_exists($filePath)) {
        return response()->file($filePath);
    }
    abort(404);
})->where('path', '.*');
```

Но лучше исправить `.htaccess` - это правильнее и быстрее.
