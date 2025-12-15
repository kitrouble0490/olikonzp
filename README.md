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

### Быстрый деплой через Git

1. **На локальной машине:**
   ```bash
   ./prepare_production.sh
   git commit -m "Production build (frontend)"
   git push origin main
   ```

2. **На сервере:**
   ```bash
   # Автоматический деплой (рекомендуется)
   ./deploy_server.sh
   
   # Или вручную:
   git pull origin main
   composer install --no-dev --optimize-autoloader
   
   # Если public/build/ отсутствует, соберите фронтенд:
   npm install
   npm run build
   
   php artisan migrate --force
   php artisan config:clear
   php artisan route:clear
   php artisan view:clear
   php artisan cache:clear
   php artisan config:cache
   php artisan route:cache
   php artisan view:cache
   ```

3. **Если весь проект в `public_html/`:**
   ```bash
   ./documentation/setup_all_in_public_html.sh
   ```

Подробная документация по деплою находится в папке `documentation/` (не коммитится в git).

## Документация

Подробная документация находится в папке `documentation/` (локально, не коммитится в git):
- Инструкции по установке и настройке
- Документация по деплою на Timeweb
- Решения проблем и FAQ
- Схема базы данных

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
