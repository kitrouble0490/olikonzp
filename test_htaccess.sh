#!/bin/bash

# Скрипт для тестирования .htaccess на сервере
# Использование: ./test_htaccess.sh

PUBLIC_HTML_DIR="$HOME/public_html"

echo "🔍 Тестирование .htaccess и путей к файлам"
echo ""

if [ ! -d "$PUBLIC_HTML_DIR" ]; then
    echo "❌ Ошибка: Директория $PUBLIC_HTML_DIR не найдена!"
    exit 1
fi

cd "$PUBLIC_HTML_DIR"

# Проверка наличия файлов
echo "📋 Проверка наличия файлов..."
echo ""

# Проверка build/assets/
if [ -d "build/assets" ]; then
    echo "✅ build/assets/ существует"
    JS_FILES=$(find build/assets -name "*.js" -type f 2>/dev/null | head -3)
    CSS_FILES=$(find build/assets -name "*.css" -type f 2>/dev/null | head -3)
    
    if [ -n "$JS_FILES" ]; then
        echo "   JS файлы найдены:"
        echo "$JS_FILES" | sed 's/^/   - /'
        
        # Проверка первого файла
        FIRST_JS=$(echo "$JS_FILES" | head -1)
        if [ -f "$FIRST_JS" ]; then
            echo "   ✅ Файл существует: $FIRST_JS"
            echo "   Размер: $(ls -lh "$FIRST_JS" | awk '{print $5}')"
            echo "   Права: $(ls -l "$FIRST_JS" | awk '{print $1}')"
        fi
    else
        echo "   ❌ JS файлы не найдены!"
    fi
    
    if [ -n "$CSS_FILES" ]; then
        echo "   CSS файлы найдены:"
        echo "$CSS_FILES" | sed 's/^/   - /'
    else
        echo "   ❌ CSS файлы не найдены!"
    fi
else
    echo "❌ build/assets/ не существует!"
fi

echo ""

# Проверка public/build/ (если используется симлинк)
if [ -d "public/build" ] || [ -L "public/build" ]; then
    echo "✅ public/build/ существует"
    if [ -L "public/build" ]; then
        TARGET=$(readlink public/build)
        echo "   Это симлинк на: $TARGET"
        if [ -d "$TARGET" ]; then
            echo "   ✅ Целевая директория существует"
        else
            echo "   ❌ Целевая директория не существует!"
        fi
    fi
else
    echo "⚠️  public/build/ не существует"
fi

echo ""

# Проверка .htaccess
echo "📋 Проверка .htaccess..."
if [ -f ".htaccess" ]; then
    echo "✅ .htaccess существует"
    
    # Проверка правил для статических файлов
    if grep -q "RewriteCond %{REQUEST_FILENAME} -f" .htaccess; then
        echo "✅ Правило для статических файлов найдено"
    else
        echo "⚠️  Правило для статических файлов не найдено"
    fi
    
    # Проверка MIME типов
    if grep -q "AddType application/javascript" .htaccess; then
        echo "✅ MIME тип для JS настроен"
    else
        echo "⚠️  MIME тип для JS не настроен"
    fi
else
    echo "❌ .htaccess не найден!"
fi

echo ""

# Тест доступности через curl (если доступен)
if command -v curl &> /dev/null; then
    echo "📋 Тест доступности файлов..."
    
    # Найдем первый JS файл
    FIRST_JS=$(find build/assets -name "*.js" -type f 2>/dev/null | head -1)
    if [ -n "$FIRST_JS" ]; then
        # Получим относительный путь
        REL_PATH=$(echo "$FIRST_JS" | sed "s|^$PUBLIC_HTML_DIR/||")
        echo "Тестирую файл: $REL_PATH"
        
        # Получим домен из .env или используем localhost
        DOMAIN=$(grep APP_URL .env 2>/dev/null | cut -d '=' -f2 | tr -d '"' | tr -d "'" | sed 's|https\?://||' | sed 's|/$||')
        if [ -z "$DOMAIN" ]; then
            DOMAIN="localhost"
        fi
        
        echo "Проверка через curl (может не работать без реального домена)..."
        # curl -I "http://$DOMAIN/$REL_PATH" 2>/dev/null | head -5
    fi
fi

echo ""
echo "✅ Проверка завершена!"
echo ""
echo "📝 Рекомендации:"
echo "1. Убедитесь, что файлы находятся в build/assets/"
echo "2. Проверьте права доступа: chmod -R 755 build"
echo "3. Проверьте .htaccess - должно быть правило для статических файлов"
echo "4. Очистите кеш браузера и попробуйте снова"
