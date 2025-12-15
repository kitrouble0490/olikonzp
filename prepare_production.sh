#!/bin/bash

# Скрипт для подготовки production версии фронтенда для коммита в git
# Использование: ./prepare_production.sh
# ВАЖНО: vendor/ НЕ коммитится, только build/ (фронтенд)

set -e

echo "🚀 Подготовка production версии фронтенда для git"
echo ""

# Цвета
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Проверка зависимостей
echo -e "${YELLOW}Проверка зависимостей...${NC}"

if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js не установлен${NC}"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm не установлен${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Зависимости установлены${NC}"

# 1. Установка npm зависимостей
echo -e "\n${YELLOW}Установка npm зависимостей...${NC}"
npm install

# 2. Сборка фронтенда
echo -e "\n${YELLOW}Сборка production версии фронтенда...${NC}"
npm run build

if [ ! -d "public/build" ]; then
    echo -e "${RED}❌ Ошибка: директория public/build не создана${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Фронтенд собран успешно${NC}"

# 3. Проверка размера build/
echo -e "\n${YELLOW}Проверка размера...${NC}"
BUILD_SIZE=$(du -sh public/build/ 2>/dev/null | cut -f1)
echo "Размер public/build/: $BUILD_SIZE"

# 4. Временное удаление public/build из .gitignore
echo -e "\n${YELLOW}Настройка .gitignore для production...${NC}"

# Создаем backup .gitignore
if [ ! -f ".gitignore.backup" ]; then
    cp .gitignore .gitignore.backup
    echo "✅ Backup .gitignore создан"
fi

# Комментируем только public/build в .gitignore (если еще не закомментирован)
if grep -q "^/public/build$" .gitignore; then
    sed -i.bak 's|^/public/build$|#/public/build|g' .gitignore
    echo "✅ /public/build закомментирован в .gitignore"
elif grep -q "^public/build$" .gitignore; then
    sed -i.bak 's|^public/build$|#public/build|g' .gitignore
    echo "✅ public/build закомментирован в .gitignore"
fi

# vendor/ остается в .gitignore (не коммитим)
echo "✅ vendor/ остается в .gitignore (будет установлен через Composer на сервере)"

echo -e "${GREEN}✅ .gitignore обновлен${NC}"

# 5. Добавление файлов в git (только build/)
echo -e "\n${YELLOW}Добавление файлов в git...${NC}"
git add public/build/ .gitignore

echo -e "${GREEN}✅ Файлы добавлены в git${NC}"

echo -e "\n${GREEN}✅ Подготовка завершена!${NC}"
echo -e "\n${YELLOW}Следующие шаги:${NC}"
echo "1. Проверьте изменения: git status"
echo "2. Закоммитьте: git commit -m 'Add production build (frontend)'"
echo "3. Запушьте: git push origin main"
echo ""
echo -e "${YELLOW}ℹ️  Информация:${NC}"
echo "- Только public/build/ (~5-10 МБ) будет в репозитории"
echo "- vendor/ НЕ коммитится (будет установлен через Composer на сервере)"
echo "- На сервере выполните: composer install --no-dev --optimize-autoloader"
echo ""
echo -e "${YELLOW}Для отката изменений .gitignore:${NC}"
echo "mv .gitignore.backup .gitignore"
echo "git restore .gitignore"
