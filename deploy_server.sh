#!/bin/bash

# Скрипт для деплоя на сервере после git pull
# Использование: ./deploy_server.sh

set -e

echo "🚀 Деплой на сервере"
echo ""

# Цвета
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 1. Обновление кода из git
echo -e "${YELLOW}Обновление кода из git...${NC}"
git pull origin main || git pull origin master

# 2. Установка/обновление зависимостей Composer
echo -e "\n${YELLOW}Установка зависимостей Composer...${NC}"
composer install --no-dev --optimize-autoloader

# 3. Проверка наличия public/build
echo -e "\n${YELLOW}Проверка сборки фронтенда...${NC}"
if [ ! -d "public/build" ] || [ -z "$(ls -A public/build 2>/dev/null)" ]; then
    echo -e "${YELLOW}⚠️  public/build отсутствует или пуст, собираем фронтенд...${NC}"
    
    # Проверка наличия Node.js и npm
    if ! command -v node &> /dev/null; then
        echo -e "${RED}❌ Node.js не установлен на сервере${NC}"
        echo -e "${YELLOW}Установите Node.js или убедитесь, что public/build/ был закоммичен в git${NC}"
        exit 1
    fi
    
    if ! command -v npm &> /dev/null; then
        echo -e "${RED}❌ npm не установлен на сервере${NC}"
        exit 1
    fi
    
    # Установка npm зависимостей
    echo -e "${YELLOW}Установка npm зависимостей...${NC}"
    npm install
    
    # Сборка фронтенда
    echo -e "${YELLOW}Сборка production версии фронтенда...${NC}"
    npm run build
    
    if [ ! -d "public/build" ]; then
        echo -e "${RED}❌ Ошибка: директория public/build не создана${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Фронтенд собран успешно${NC}"
else
    echo -e "${GREEN}✅ public/build найден${NC}"
fi

# 4. Запуск миграций
echo -e "\n${YELLOW}Запуск миграций...${NC}"
php artisan migrate --force

# 5. Очистка кеша Laravel
echo -e "\n${YELLOW}Очистка кеша Laravel...${NC}"
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan cache:clear

# 6. Создание кеша для production
echo -e "\n${YELLOW}Создание кеша для production...${NC}"
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo -e "\n${GREEN}✅ Деплой завершен успешно!${NC}"
echo ""
echo -e "${YELLOW}Проверьте работу приложения${NC}"
