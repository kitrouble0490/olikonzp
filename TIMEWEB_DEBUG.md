# Отладка ошибки 500 на Timeweb

## Проблема

Ошибка 500 при обращении к сайту. Стек вызовов показывает, что ошибка происходит в `index.php` на строке 20.

## Типичные причины и решения

### 1. Проверка полного текста ошибки

**Важно:** Покажите **НАЧАЛО** ошибки из логов, не только стек вызовов. Обычно это что-то вроде:

```
SQLSTATE[HY000] [2002] Connection refused
или
Class '...' not found
или
Permission denied
```

**Команда для просмотра полного лога:**
```bash
tail -n 100 ~/public_html/storage/logs/laravel.log
```

### 2. Проблема с базой данных

**Симптомы:** Ошибка типа `SQLSTATE[HY000]`, `Connection refused`, `Access denied`

**Решение:**
```bash
# Проверьте .env файл
cat ~/public_html/.env | grep DB_

# Должно быть что-то вроде:
# DB_CONNECTION=mysql
# DB_HOST=localhost  (или IP от Timeweb)
# DB_DATABASE=your_db_name
# DB_USERNAME=your_db_user
# DB_PASSWORD=your_db_password

# Проверьте подключение к БД
php -r "
\$pdo = new PDO('mysql:host=localhost;dbname=your_db_name', 'your_db_user', 'your_db_password');
echo 'Connected!';
"
```

### 3. Проблема с правами доступа

**Симптомы:** `Permission denied`, `failed to open stream`

**Решение:**
```bash
cd ~/public_html

# Установите правильные права
chmod -R 775 storage
chmod -R 775 bootstrap/cache
chmod 644 index.php .htaccess
chmod 600 .env

# Проверьте владельца файлов
ls -la storage/
# Должен быть ваш пользователь или www-data
```

### 4. Проблема с путями в index.php

**Симптомы:** `No such file or directory`, `failed to open stream`

**Проверьте:**
```bash
cd ~/public_html

# Проверьте, что файлы существуют
php -r "
echo 'vendor: ' . (file_exists(__DIR__ . '/vendor/autoload.php') ? 'OK' : 'NOT FOUND') . PHP_EOL;
echo 'bootstrap: ' . (file_exists(__DIR__ . '/bootstrap/app.php') ? 'OK' : 'NOT FOUND') . PHP_EOL;
echo 'storage: ' . (is_dir(__DIR__ . '/storage') ? 'OK' : 'NOT FOUND') . PHP_EOL;
"
```

### 5. Проблема с APP_KEY

**Симптомы:** Ошибки шифрования, проблемы с сессиями

**Решение:**
```bash
cd ~/public_html
php artisan key:generate
```

### 6. Проблема с кешем

**Симптомы:** Старые конфигурации, неправильные пути

**Решение:**
```bash
cd ~/public_html

# Очистите весь кеш
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan cache:clear

# Пересоздайте кеш
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### 7. Включение отладки (временно)

**Для диагностики включите отладку:**

```bash
cd ~/public_html
nano .env

# Измените:
APP_DEBUG=true
APP_ENV=local

# Сохраните и попробуйте снова
```

**ВАЖНО:** После отладки верните обратно:
```env
APP_DEBUG=false
APP_ENV=production
```

### 8. Проверка версии PHP

**Laravel 12 требует PHP 8.2+**

```bash
php -v
# Должно быть PHP 8.2 или выше
```

### 9. Проверка расширений PHP

**Laravel требует определенные расширения:**

```bash
php -m | grep -E "(pdo_mysql|mbstring|openssl|tokenizer|json|ctype|fileinfo)"
```

Должны быть все перечисленные расширения.

### 10. Проверка структуры файлов

```bash
cd ~/public_html

# Проверьте наличие ключевых файлов
ls -la | grep -E "(index.php|vendor|bootstrap|storage|.env)"

# Проверьте структуру
ls -la vendor/ | head -5
ls -la bootstrap/ | head -5
ls -la storage/ | head -5
```

## Пошаговая диагностика

### Шаг 1: Получите полный текст ошибки

```bash
tail -n 200 ~/public_html/storage/logs/laravel.log | head -50
```

Покажите **первые строки** ошибки (до стека вызовов).

### Шаг 2: Проверьте базовую работоспособность

```bash
cd ~/public_html

# Простой тест загрузки Laravel
php -r "
require __DIR__ . '/vendor/autoload.php';
\$app = require_once __DIR__ . '/bootstrap/app.php';
echo 'Laravel loaded successfully!';
"
```

### Шаг 3: Проверьте подключение к БД

```bash
php artisan tinker
# В tinker выполните:
DB::connection()->getPdo();
# Если ошибка - проблема с БД
```

### Шаг 4: Проверьте маршруты

```bash
php artisan route:list
# Должны показаться все маршруты
```

## Быстрое решение

Попробуйте выполнить все команды подряд:

```bash
cd ~/public_html

# 1. Очистка кеша
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan cache:clear

# 2. Регенерация ключа
php artisan key:generate

# 3. Права доступа
chmod -R 775 storage bootstrap/cache
chmod 644 index.php .htaccess
chmod 600 .env

# 4. Проверка структуры
ls -la vendor/ | head -3
ls -la bootstrap/ | head -3

# 5. Включите отладку временно
sed -i 's/APP_DEBUG=false/APP_DEBUG=true/' .env

# 6. Попробуйте снова открыть сайт
# Если работает - верните APP_DEBUG=false
sed -i 's/APP_DEBUG=true/APP_DEBUG=false/' .env
```

## Что показать для диагностики

Пришлите:

1. **Первые 20-30 строк** ошибки из `laravel.log` (до стека вызовов)
2. Результат команды:
   ```bash
   php -v
   ```
3. Результат команды:
   ```bash
   cd ~/public_html && ls -la | head -20
   ```
4. Содержимое `.env` (скройте пароли):
   ```bash
   cat ~/public_html/.env | grep -E "(APP_|DB_)"
   ```
