# Быстрое решение ошибки 500

## Шаг 1: Получите полный текст ошибки

```bash
# На сервере через SSH
tail -n 100 ~/public_html/storage/logs/laravel.log | head -30
```

**Покажите ПЕРВЫЕ строки ошибки** (до стека вызовов). Обычно это что-то вроде:
- `SQLSTATE[HY000] [2002] Connection refused` - проблема с БД
- `Class '...' not found` - проблема с путями или vendor/
- `Permission denied` - проблема с правами
- `failed to open stream` - проблема с путями

## Шаг 2: Быстрая диагностика

Выполните эти команды на сервере:

```bash
cd ~/public_html

# 1. Проверьте версию PHP
php -v
# Должно быть PHP 8.2+

# 2. Проверьте наличие ключевых файлов
ls -la vendor/ | head -3
ls -la bootstrap/ | head -3
ls -la storage/ | head -3

# 3. Проверьте права доступа
ls -la storage/ bootstrap/cache/

# 4. Проверьте .env
cat .env | grep -E "(APP_|DB_)"

# 5. Проверьте подключение к БД (замените данные)
php -r "
try {
    \$pdo = new PDO('mysql:host=localhost;dbname=your_db', 'your_user', 'your_pass');
    echo 'DB Connection: OK';
} catch (Exception \$e) {
    echo 'DB Connection: FAILED - ' . \$e->getMessage();
}
"
```

## Шаг 3: Быстрое исправление

Попробуйте выполнить все команды подряд:

```bash
cd ~/public_html

# 1. Очистка всего кеша
php artisan config:clear 2>/dev/null || echo "config:clear failed"
php artisan route:clear 2>/dev/null || echo "route:clear failed"
php artisan view:clear 2>/dev/null || echo "view:clear failed"
php artisan cache:clear 2>/dev/null || echo "cache:clear failed"

# 2. Регенерация ключа приложения
php artisan key:generate

# 3. Установка прав доступа
chmod -R 775 storage bootstrap/cache
chmod 644 index.php .htaccess
chmod 600 .env

# 4. Включите отладку временно (чтобы увидеть ошибку)
sed -i 's/APP_DEBUG=false/APP_DEBUG=true/' .env 2>/dev/null
sed -i 's/APP_DEBUG=0/APP_DEBUG=1/' .env 2>/dev/null

# 5. Попробуйте открыть сайт снова
# Если видите ошибку - скопируйте её полностью

# 6. После отладки верните APP_DEBUG=false
sed -i 's/APP_DEBUG=true/APP_DEBUG=false/' .env 2>/dev/null
sed -i 's/APP_DEBUG=1/APP_DEBUG=0/' .env 2>/dev/null
```

## Шаг 4: Проверка путей

Если проект полностью в `public_html/`, проверьте `index.php`:

```bash
cd ~/public_html
cat index.php | head -25
```

Должно быть:
```php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
```

**НЕ должно быть:**
```php
require __DIR__ . '/../vendor/autoload.php';  // ❌ Неправильно для проекта в public_html/
```

## Типичные проблемы

### Проблема 1: База данных

**Ошибка:** `SQLSTATE[HY000]`, `Connection refused`, `Access denied`

**Решение:**
1. Проверьте данные БД в `.env`
2. Убедитесь, что БД создана в панели Timeweb
3. Проверьте хост БД (может быть не `localhost`, а IP или другое имя)

### Проблема 2: Права доступа

**Ошибка:** `Permission denied`, `failed to open stream`

**Решение:**
```bash
chmod -R 775 storage bootstrap/cache
chown -R ваш_пользователь:ваша_группа storage bootstrap/cache
```

### Проблема 3: Пути в index.php

**Ошибка:** `No such file or directory`

**Решение:** Используйте правильный `index.php`:
- Если проект в `public_html/` → используйте `public_html_all_in_one_index.php`
- Если проект на уровень выше → используйте `public_html_index.php`

### Проблема 4: vendor/ не загружен

**Ошибка:** `Class '...' not found`

**Решение:** Загрузите папку `vendor/` с локальной машины (она должна быть ~50 МБ)

### Проблема 5: APP_KEY не сгенерирован

**Ошибка:** Ошибки шифрования, проблемы с сессиями

**Решение:**
```bash
php artisan key:generate
```

## Что показать для помощи

Пришлите:

1. **Первые 10-15 строк** ошибки из `laravel.log`:
   ```bash
   head -15 ~/public_html/storage/logs/laravel.log | tail -10
   ```

2. Результат:
   ```bash
   php -v
   ```

3. Результат:
   ```bash
   cd ~/public_html && ls -la | head -15
   ```

4. Содержимое `.env` (скройте пароли):
   ```bash
   cat ~/public_html/.env | grep -E "(APP_|DB_)"
   ```
