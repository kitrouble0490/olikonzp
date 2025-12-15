# Исправление ошибки 404 для Vite assets

## Проблема

```
404 Not Found: https://kitrouble-app.ru/build/assets/app-DBL8Syq1.css
```

Vite генерирует пути к assets как `/build/assets/...`, но файлы не доступны по этому пути.

## Причина

Когда весь проект находится в `public_html/`, структура должна быть:
- `public_html/build/assets/...` - файлы должны быть здесь
- Или `public_html/public/build/assets/...` - если используется симлинк

## Решение

### Шаг 1: Проверьте структуру на сервере

```bash
# На сервере через SSH
cd ~/public_html

# Проверьте, где находятся assets
ls -la build/assets/ | head -5
# или
ls -la public/build/assets/ | head -5
```

### Шаг 2: Убедитесь, что assets загружены

Файлы должны быть в одном из мест:
- `~/public_html/build/assets/` (если build/ в корне)
- `~/public_html/public/build/assets/` (если используется симлинк)

### Шаг 3: Проверьте .htaccess

Убедитесь, что `.htaccess` правильно настроен для обслуживания статических файлов:

```apache
# В .htaccess должна быть строка:
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^ index.php [L]
```

Это позволяет Apache обслуживать реальные файлы (включая assets) напрямую.

### Шаг 4: Проверьте права доступа

```bash
# Убедитесь, что файлы доступны для чтения
chmod -R 644 build/assets/*
chmod 755 build/assets
```

### Шаг 5: Если используете симлинк public/build

Если вы создали симлинк `public/build -> ../build`, убедитесь, что он работает:

```bash
cd ~/public_html
ls -la public/build/assets/ | head -5

# Если симлинк не работает, пересоздайте его:
rm public/build 2>/dev/null
ln -s ../build public/build
```

## Быстрое решение

Выполните все команды подряд:

```bash
cd ~/public_html

# 1. Проверьте наличие assets
if [ -d "build/assets" ]; then
    echo "✅ build/assets/ существует"
    ls -la build/assets/ | head -3
elif [ -d "public/build/assets" ]; then
    echo "✅ public/build/assets/ существует"
    ls -la public/build/assets/ | head -3
else
    echo "❌ assets не найдены! Загрузите build/ с локальной машины."
    exit 1
fi

# 2. Установите права доступа
chmod -R 755 build 2>/dev/null
chmod -R 644 build/assets/* 2>/dev/null

# 3. Проверьте .htaccess
if grep -q "RewriteCond %{REQUEST_FILENAME} !-f" .htaccess; then
    echo "✅ .htaccess настроен правильно"
else
    echo "⚠️  Проверьте .htaccess"
fi

# 4. Проверьте доступность файла напрямую
echo "Проверьте доступность:"
echo "https://kitrouble-app.ru/build/assets/app-DBL8Syq1.css"
```

## Альтернативное решение: Пересборка с правильным base

Если проблема сохраняется, можно пересобрать проект с правильным base URL:

**На локальной машине:**

```bash
# Отредактируйте vite.config.js и добавьте base:
export default defineConfig({
    base: '/',  // или '/build/' если нужно
    // ... остальная конфигурация
})

# Пересоберите
npm run build

# Загрузите обновленный build/ на сервер
```

Но обычно это не требуется - проблема в структуре файлов на сервере.

## Проверка работы

После исправления:

1. Откройте в браузере: `https://kitrouble-app.ru/build/assets/app-DBL8Syq1.css`
2. Должен загрузиться CSS файл (не 404)
3. Проверьте в консоли браузера (F12) - не должно быть ошибок 404 для assets

## Частые проблемы

### Проблема 1: Файлы не загружены

**Симптом:** `ls -la build/assets/` показывает пустую директорию

**Решение:** Загрузите папку `build/` полностью с локальной машины. Она должна содержать:
- `manifest.json`
- `assets/` (с CSS и JS файлами)
- `.vite/` (опционально)

### Проблема 2: Неправильные права доступа

**Симптом:** 403 Forbidden вместо 404

**Решение:**
```bash
chmod -R 755 build
chmod -R 644 build/assets/*
```

### Проблема 3: Симлинк не работает

**Симптом:** `public/build/assets/` не существует или не работает

**Решение:**
```bash
cd ~/public_html
rm -rf public/build
mkdir -p public
ln -s ../build public/build
ls -la public/build/assets/ | head -3
```

## Итоговая проверка

```bash
cd ~/public_html

# Должны существовать:
[ -f "build/manifest.json" ] && echo "✅ manifest.json" || echo "❌ manifest.json"
[ -d "build/assets" ] && echo "✅ build/assets/" || echo "❌ build/assets/"
[ -f "build/assets/app-*.css" ] && echo "✅ CSS файлы" || echo "❌ CSS файлы"
[ -f "build/assets/app-*.js" ] && echo "✅ JS файлы" || echo "❌ JS файлы"
```
