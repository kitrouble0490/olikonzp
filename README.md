# OLIKON-ЗП

Система управления расчетом заработной платы на основе планов и фактов выполнения работ.

## Технологии

- **Backend:** Laravel 12 (PHP 8.2+)
- **Frontend:** Vue 3 + Pinia + Element Plus
- **Build Tool:** Vite 7
- **Database:** MySQL

## Функциональность

- ✅ Управление страницами (годами)
- ✅ Управление периодами (месяцами)
- ✅ Управление отделами
- ✅ Управление сотрудниками
- ✅ Расчет заработной платы на основе плана и факта
- ✅ Автоматический расчет процентов и зарплаты
- ✅ Система авторизации
- ✅ Дебаунсинг сохранения данных
- ✅ Визуализация выполнения плана (эмодзи)

## Установка и настройка

Подробная инструкция по установке: [SETUP.md](SETUP.md)

### Быстрый старт

```bash
# Установка зависимостей
composer install
npm install

# Настройка .env файла
cp .env.example .env
php artisan key:generate

# Настройка базы данных в .env
# DB_CONNECTION=mysql
# DB_HOST=127.0.0.1
# DB_PORT=3306
# DB_DATABASE=olikonzp
# DB_USERNAME=your_username
# DB_PASSWORD=your_password

# Запуск миграций
php artisan migrate

# Заполнение начальными данными
php artisan db:seed

# Сборка фронтенда
npm run build

# Запуск сервера разработки
php artisan serve
npm run dev
```

## Деплой на Timeweb

Подробная инструкция по деплою: [DEPLOY_TIMEWEB.md](DEPLOY_TIMEWEB.md)

### Быстрый деплой

1. Соберите проект: `npm run build`
2. Загрузите файлы на сервер
3. Настройте `.env` файл на сервере
4. Выполните на сервере:
   ```bash
   composer install --no-dev --optimize-autoloader
   php artisan key:generate
   php artisan migrate --force
   php artisan db:seed --force
   php artisan config:cache
   php artisan route:cache
   php artisan view:cache
   chmod -R 775 storage bootstrap/cache
   ```

Подробнее: [QUICK_DEPLOY.md](QUICK_DEPLOY.md)

## Документация

- [SETUP.md](SETUP.md) - Настройка проекта
- [DATABASE_SCHEMA.md](DATABASE_SCHEMA.md) - Схема базы данных
- [DEPLOY_TIMEWEB.md](DEPLOY_TIMEWEB.md) - Деплой на Timeweb
- [DEPLOY_CHECKLIST.md](DEPLOY_CHECKLIST.md) - Чек-лист деплоя
- [QUICK_DEPLOY.md](QUICK_DEPLOY.md) - Быстрый деплой

## Учетные данные по умолчанию

После выполнения `php artisan db:seed` создается пользователь:
- **Логин:** `olikon`
- **Пароль:** `11592309`

## Структура проекта

```
olikonzp/
├── app/                    # Laravel приложение
│   ├── Http/Controllers/   # API контроллеры
│   └── Models/             # Eloquent модели
├── database/               # Миграции и сидеры
├── resources/
│   ├── js/                 # Vue 3 компоненты
│   │   ├── components/     # Vue компоненты
│   │   ├── stores/         # Pinia stores
│   │   └── api/            # API клиент
│   └── css/                # Стили
├── routes/                 # Маршруты
└── public/                 # Публичная директория
```

## Лицензия

MIT License
