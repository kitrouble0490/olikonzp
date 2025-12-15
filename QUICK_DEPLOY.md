# Быстрый деплой на Timeweb

## Шаг 1: Подготовка на локальной машине

```bash
# Соберите проект
npm run build

# Или используйте скрипт
./deploy.sh
```

## Шаг 2: Загрузка на сервер

### Через FTP/SFTP:
1. Загрузите все файлы в `public_html/` (или указанную директорию)
2. **Важно:** Содержимое папки `public/` должно быть в корне `public_html/`
3. Остальные файлы Laravel - на уровень выше или в подпапке

### Через SSH (если доступен):
```bash
# Клонируйте репозиторий или загрузите файлы
cd ~/public_html
git clone https://github.com/your-repo.git .
```

## Шаг 3: Настройка на сервере

### Вариант A: Если Composer на сервере работает

```bash
# 1. Установите зависимости
composer install --no-dev --optimize-autoloader
```

### Вариант B: Если Composer на сервере старая версия (РЕКОМЕНДУЕТСЯ)

**На локальной машине:**
```bash
composer install --no-dev --optimize-autoloader
```

**Загрузите папку `vendor/` на сервер через FTP/SFTP**

### Продолжение настройки:

```bash
# 2. Создайте .env файл
cp .env.example .env
nano .env  # отредактируйте настройки

# 3. Настройте .env:
# - APP_ENV=production
# - APP_DEBUG=false
# - APP_URL=https://your-domain.com
# - Данные БД от Timeweb

# 4. Сгенерируйте ключ
php artisan key:generate

# 5. Запустите миграции
php artisan migrate --force

# 6. Заполните БД
php artisan db:seed --force

# 7. Настройте права
chmod -R 775 storage bootstrap/cache

# 8. Оптимизируйте
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

## Шаг 4: Проверка

1. Откройте сайт: `https://your-domain.com`
2. Войдите: `olikon` / `11592309`
3. Проверьте работу приложения

## Важные моменты

- ✅ Убедитесь, что `npm run build` выполнен (файлы в `public/build/`)
- ✅ Настройте правильный `APP_URL` в `.env`
- ✅ Проверьте права доступа к `storage/` и `bootstrap/cache/`
- ✅ Убедитесь, что БД создана и доступна

## Проблемы?

### Ошибка: composer-runtime-api ^2.2

Если видите ошибку:
```
laravel/framework v12.42.0 requires composer-runtime-api ^2.2 -> no matching package found
```

**Решение:** Установите зависимости локально и загрузите `vendor/` на сервер.

```bash
# На локальной машине
composer install --no-dev --optimize-autoloader

# Загрузите папку vendor/ на сервер через FTP/SFTP
```

Подробнее: `DEPLOY_TIMEWEB_FIX.md`

---

Смотрите подробную инструкцию: `DEPLOY_TIMEWEB.md`  
Используйте чек-лист: `DEPLOY_CHECKLIST.md`

