# Полное исправление проблемы MIME для JS файлов

## Проблема

JS файлы возвращаются как `text/html` вместо `application/javascript`. Favicon работает.

## Причина

1. Файлы находятся в `public/build/assets/`, но Laravel Vite генерирует пути `/build/assets/...`
2. `.htaccess` не содержит правил для статических файлов и MIME типов

## Решение

### Шаг 1: Создайте симлинк build -> public/build

```bash
# На сервере через SSH
cd ~/public_html

# Создайте симлинк (если его нет)
if [ -L "build" ]; then
    rm build
elif [ -d "build" ]; then
    mv build build.old
fi

ln -s public/build build

# Проверьте
ls -la build/assets/app-*.js | head -1
```

### Шаг 2: Обновите .htaccess

Используйте скрипт:

```bash
cd ~/public_html
./fix_build_paths.sh
```

Или вручную скопируйте исправленный `.htaccess` из `public/.htaccess` в `~/public_html/.htaccess`

### Шаг 3: Проверьте права доступа

```bash
chmod -R 755 build
find build/assets -type f -exec chmod 644 {} \;
chmod 644 .htaccess
```

## Быстрое исправление (одна команда)

```bash
# На сервере через SSH
cd ~/public_html

# Используйте автоматический скрипт
./fix_build_paths.sh
```

Скрипт автоматически:
- ✅ Создаст симлинк `build -> public/build`
- ✅ Обновит `.htaccess` с правильными правилами
- ✅ Настроит MIME типы
- ✅ Установит права доступа

## Проверка

После исправления:

```bash
# 1. Проверьте симлинк
ls -la build
# Должно быть: build -> public/build

# 2. Проверьте наличие файлов
ls -la build/assets/app-*.js | head -1

# 3. Проверьте .htaccess
grep -E "(RewriteCond.*REQUEST_FILENAME.*-f|AddType.*application/javascript)" .htaccess
# Должны быть оба правила

# 4. Очистите кеш браузера и проверьте сайт
```

## Если проблема сохраняется

Проверьте, что файлы действительно доступны:

```bash
# Проверьте реальный путь к файлам
find . -name "app-*.js" -type f | head -1

# Проверьте доступность через curl
curl -I https://kitrouble-app.ru/build/assets/app-D8W0Dedn.js
# Должен вернуть: Content-Type: application/javascript
# НЕ должен вернуть: Content-Type: text/html
```

## Структура должна быть:

```
public_html/
├── .htaccess          ← Исправленный (с правилами для статических файлов)
├── index.php
├── build -> public/build  ← Симлинк
└── public/
    └── build/
        ├── manifest.json
        └── assets/
            ├── app-*.js
            └── app-*.css
```
