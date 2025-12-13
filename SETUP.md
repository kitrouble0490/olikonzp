# Инструкция по настройке проекта OLIKON-ЗП

## Этап 1: Настройка проекта Laravel ✅

Проект успешно настроен с:
- ✅ Laravel 12
- ✅ Vite 7
- ✅ Vue 3
- ✅ Pinia

## Настройка MySQL

1. Создайте базу данных MySQL:
```sql
CREATE DATABASE olikonzp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

2. Настройте `.env` файл:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=olikonzp
DB_USERNAME=your_username
DB_PASSWORD=your_password
```

3. Запустите миграции (после создания на этапе 2):
```bash
php artisan migrate
```

## Запуск проекта

### Разработка
```bash
# Терминал 1: Laravel сервер
php artisan serve

# Терминал 2: Vite dev server
npm run dev
```

### Продакшн
```bash
# Сборка фронтенда
npm run build

# Запуск Laravel
php artisan serve
```

## Структура проекта

- `legacy_app/` - старое приложение (сохранено для справки)
- `resources/js/` - Vue 3 компоненты и логика
- `resources/js/stores/` - Pinia stores (будут созданы на этапе 4)
- `resources/css/app.css` - стили приложения
- `routes/web.php` - маршруты Laravel

## Следующие этапы

- Этап 2: Проектирование БД и создание миграций
- Этап 3: Backend (Laravel API)
- Этап 4: Frontend (Vue 3 + Pinia stores)
- Этап 5: Интеграция и тестирование

