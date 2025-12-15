# Быстрый деплой через Git (только фронтенд)

## Идея

Собрать production версию фронтенда локально (`build/`), закоммитить в git, на сервере сделать `git pull` + установить `vendor/` через Composer.

## На локальной машине

```bash
# 1. Подготовьте production версию фронтенда
./prepare_production.sh

# 2. Проверьте изменения (должен быть только public/build/)
git status

# 3. Закоммитьте
git commit -m "Production build (frontend)"

# 4. Запушьте
git push origin main
```

## На сервере (первый раз)

```bash
# 1. Клонируйте репозиторий
cd ~
git clone https://github.com/your-username/your-repo.git olikonzp
cd olikonzp

# 2. Установите PHP зависимости через Composer
composer install --no-dev --optimize-autoloader

# 3. Настройте .env
cp .env.example .env
nano .env  # настройте данные БД

# 4. Настройте Laravel
php artisan key:generate
php artisan migrate --force
php artisan db:seed --force

# 5. Настройте структуру для Timeweb (если весь проект в public_html/)
./setup_all_in_public_html.sh

# 6. Права доступа
chmod -R 775 storage bootstrap/cache
chmod 600 .env
```

## На сервере (обновление)

```bash
cd ~/olikonzp  # или ~/public_html
git pull origin main
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

Готово! 🚀

## Если проект в public_html/

После `git pull` выполните:

```bash
cd ~/public_html
./setup_all_in_public_html.sh
```

Или вручную:

```bash
mkdir -p public
ln -s ../build public/build
cp public/.htaccess .htaccess
cp public_html_all_in_one_index.php index.php
```
