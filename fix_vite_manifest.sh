#!/bin/bash

# Скрипт для исправления ошибки Vite manifest not found
# Использование: ./fix_vite_manifest.sh

PUBLIC_HTML_DIR="$HOME/public_html"

echo "🔧 Исправление ошибки Vite manifest not found"
echo ""

if [ ! -d "$PUBLIC_HTML_DIR" ]; then
    echo "❌ Ошибка: Директория $PUBLIC_HTML_DIR не найдена!"
    exit 1
fi

cd "$PUBLIC_HTML_DIR"

# Проверка наличия build/
if [ ! -d "build" ]; then
    echo "❌ Ошибка: Папка build/ не найдена!"
    echo "Выполните 'npm run build' на локальной машине и загрузите build/ на сервер."
    exit 1
fi

# Создание директории public/
echo "📋 Создание директории public/..."
mkdir -p public

# Создание симлинка
echo "📋 Создание симлинка public/build -> ../build..."
if ln -sf ../build public/build 2>/dev/null; then
    echo "✅ Симлинк создан успешно"
else
    echo "⚠️  Не удалось создать симлинк. Перемещаю build/ в public/build/..."
    mv build public/build
    echo "✅ build/ перемещен в public/build/"
fi

# Проверка
echo ""
echo "📋 Проверка..."
if [ -f "public/build/manifest.json" ]; then
    echo "✅ manifest.json найден: public/build/manifest.json"
    ls -lh public/build/manifest.json
elif [ -f "build/manifest.json" ]; then
    echo "✅ manifest.json найден: build/manifest.json"
    ls -lh build/manifest.json
else
    echo "❌ manifest.json не найден!"
    echo "Проверьте, что выполнили 'npm run build' и загрузили build/ на сервер."
    exit 1
fi

echo ""
echo "✅ Исправление завершено!"
echo "Теперь Laravel должен найти manifest.json по пути public/build/manifest.json"
