#!/bin/bash

# Скрипт для подготовки проекта к деплою на Timeweb
# Использование: ./deploy.sh

set -e

echo "🚀 Начинаем подготовку к деплою..."

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Проверка наличия необходимых инструментов
echo -e "${YELLOW}Проверка зависимостей...${NC}"

if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js не установлен${NC}"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm не установлен${NC}"
    exit 1
fi

if ! command -v php &> /dev/null; then
    echo -e "${RED}❌ PHP не установлен${NC}"
    exit 1
fi

if ! command -v composer &> /dev/null; then
    echo -e "${RED}❌ Composer не установлен${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Все зависимости установлены${NC}"

# Установка зависимостей
echo -e "\n${YELLOW}Установка npm зависимостей...${NC}"
npm install

echo -e "\n${YELLOW}Сборка production версии фронтенда...${NC}"
npm run build

if [ ! -d "public/build" ]; then
    echo -e "${RED}❌ Ошибка: директория public/build не создана${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Фронтенд собран успешно${NC}"

# Проверка .env файла
if [ ! -f ".env" ]; then
    echo -e "\n${YELLOW}Создание .env файла из .env.example...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✅ .env файл создан. Не забудьте настроить его!${NC}"
else
    echo -e "\n${GREEN}✅ .env файл существует${NC}"
fi

# Проверка установки vendor
if [ ! -d "vendor" ]; then
    echo -e "\n${YELLOW}Установка Composer зависимостей...${NC}"
    composer install --no-dev --optimize-autoloader
    if [ ! -d "vendor" ]; then
        echo -e "${RED}❌ Ошибка: не удалось установить зависимости${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Зависимости установлены${NC}"
else
    echo -e "\n${GREEN}✅ Папка vendor/ уже существует${NC}"
fi

# Создание архива для загрузки (опционально)
echo -e "\n${YELLOW}Создание архива для загрузки (с vendor/)...${NC}"

# Исключаем ненужные файлы, но ВКЛЮЧАЕМ vendor/
tar --exclude='.git' \
    --exclude='node_modules' \
    --exclude='.env' \
    --exclude='storage/logs/*' \
    --exclude='storage/framework/cache/*' \
    --exclude='storage/framework/sessions/*' \
    --exclude='storage/framework/views/*' \
    -czf olikonzp-deploy-full.tar.gz .

echo -e "${GREEN}✅ Архив создан: olikonzp-deploy-full.tar.gz (включает vendor/)${NC}"

echo -e "\n${GREEN}✅ Подготовка к деплою завершена!${NC}"
echo -e "\n${YELLOW}Следующие шаги:${NC}"
echo "1. Загрузите файлы на сервер Timeweb (ВКЛЮЧАЯ папку vendor/)"
echo "   Или используйте архив: olikonzp-deploy-full.tar.gz"
echo "2. На сервере НЕ нужно выполнять composer install (vendor/ уже включен)"
echo "3. Настройте .env файл на сервере"
echo "4. Выполните: php artisan key:generate"
echo "5. Выполните: php artisan migrate --force"
echo "6. Выполните: php artisan db:seed --force"
echo "7. Настройте права доступа: chmod -R 775 storage bootstrap/cache"
echo "8. Выполните: php artisan config:cache && php artisan route:cache && php artisan view:cache"
echo -e "\n${YELLOW}ВАЖНО:${NC} Если на сервере старая версия Composer, используйте этот метод!"
echo -e "Подробная инструкция в файле DEPLOY_TIMEWEB.md"
echo -e "Решение проблемы с Composer: DEPLOY_TIMEWEB_FIX.md"

