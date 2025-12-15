# Деплой через Git (только фронтенд)

## Идея

Собрать production версию фронтенда локально (`build/`), закоммитить в git, и на сервере сделать `git pull` + установить `vendor/` через Composer.

## Преимущества

- ✅ Простота деплоя фронтенда (один `git pull`)
- ✅ Не нужно собирать фронтенд на сервере (нет Node.js/npm)
- ✅ Версионирование production версий фронтенда
- ✅ `vendor/` устанавливается через Composer на сервере (стандартная практика)

## Что коммитится

- ✅ `public/build/` (~5-10 МБ) - собранный фронтенд
- ❌ `vendor/` - НЕ коммитится, устанавливается через Composer на сервере

## Подготовка на локальной машине

### Шаг 1: Соберите production версию фронтенда

```bash
# Используйте автоматический скрипт
./prepare_production.sh

# Или вручную:
npm install
npm run build
```

**ВАЖНО:** `vendor/` НЕ нужен - он будет установлен через Composer на сервере.

### Шаг 2: Настройка .gitignore

Скрипт `prepare_production.sh` автоматически обновит `.gitignore` для `public/build/`.

**ВАЖНО:** `vendor/` остается в `.gitignore` - он НЕ коммитится.

Или создайте `.gitignore.production`:

```gitignore
# Для production коммита - включить vendor/ и build/
# Остальные правила остаются
*.log
.DS_Store
.env
.env.backup
.env.production
# ... остальное
```

### Шаг 3: Добавьте файлы в git

```bash
# Добавьте только build/ (vendor/ НЕ добавляем)
git add public/build/ .gitignore

# Проверьте изменения
git status

# Закоммитьте
git commit -m "Add production build (frontend)"

# Запушьте
git push origin main
```

## Деплой на сервере

### Шаг 1: Клонируйте репозиторий (первый раз)

```bash
# На сервере через SSH
cd ~
git clone https://github.com/your-username/your-repo.git olikonzp
cd olikonzp
```

### Шаг 2: Установите зависимости и настройте проект

```bash
# Установите PHP зависимости через Composer
composer install --no-dev --optimize-autoloader

# Создайте .env
cp .env.example .env
nano .env  # настройте данные БД

# Сгенерируйте ключ
php artisan key:generate

# Запустите миграции
php artisan migrate --force

# Заполните БД
php artisan db:seed --force

# Настройте права
chmod -R 775 storage bootstrap/cache
chmod 644 .env
```

### Шаг 3: Настройте структуру для Timeweb

Если весь проект в `public_html/`:

```bash
# Используйте скрипт
./setup_all_in_public_html.sh

# Или вручную:
mkdir -p public
ln -s ../build public/build
cp public/.htaccess .htaccess
cp public_html_all_in_one_index.php index.php
```

### Шаг 4: Обновление проекта (после изменений)

```bash
# На сервере
cd ~/olikonzp  # или ~/public_html

# Получите обновления
git pull origin main

# Если были новые миграции
php artisan migrate --force

# Очистите кеш
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Пересоздайте кеш
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

## Альтернатива: Отдельная ветка для production

Можно использовать отдельную ветку только для production:

```bash
# На локальной машине
git checkout -b production

# Соберите production версию
./prepare_production.sh

# Закоммитьте
git add vendor/ public/build/
git commit -m "Production build"
git push origin production

# На сервере
git checkout production
git pull origin production
```

## Структура .gitignore для production

Можно использовать условное включение через `.gitattributes`:

**`.gitattributes`:**
```
/vendor export-ignore
/public/build export-ignore
```

Но проще просто закомментировать в `.gitignore` для production коммита.

## Автоматизация через GitHub Actions (опционально)

Можно настроить автоматическую сборку при push в main:

```yaml
# .github/workflows/deploy.yml
name: Build Production

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: php-actions/composer@v6
      - uses: actions/setup-node@v3
      - run: composer install --no-dev --optimize-autoloader
      - run: npm install
      - run: npm run build
      - run: git config user.name "GitHub Actions"
      - run: git config user.email "actions@github.com"
      - run: git add vendor/ public/build/
      - run: git commit -m "Auto-build production" || exit 0
      - run: git push
```

## Рекомендации

1. **Для начала:** Используйте простой способ - коммитьте `vendor/` и `build/` в main
2. **Для продакшена:** Рассмотрите отдельную ветку `production`
3. **Для CI/CD:** Настройте GitHub Actions для автоматической сборки

## Откат изменений .gitignore

Если нужно вернуть `.gitignore` к исходному состоянию:

```bash
# Восстановите backup
mv .gitignore.backup .gitignore

# Или вручную раскомментируйте строки:
# /vendor
# /public/build
```

## Итоговая команда для быстрого деплоя

```bash
# На локальной машине
./prepare_production.sh
git add vendor/ public/build/ .gitignore
git commit -m "Production build"
git push origin main

# На сервере
cd ~/olikonzp  # или ~/public_html
git pull origin main
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

Готово! 🚀
