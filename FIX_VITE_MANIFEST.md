# Исправление ошибки Vite manifest not found

## Проблема

```
Vite manifest not found at: /home/c/cg915925/public_html/public/build/manifest.json
```

Laravel ищет файл манифеста Vite в `public/build/manifest.json`, но если весь проект находится в `public_html/`, то путь должен быть `build/manifest.json` (без `public/`).

## Решение 1: Создать директорию public/ и симлинк (РЕКОМЕНДУЕТСЯ)

```bash
# На сервере через SSH
cd ~/public_html

# Создайте директорию public/
mkdir -p public

# Создайте симлинк build -> ../build
ln -s ../build public/build

# Проверьте
ls -la public/build/
# Должен показать manifest.json
```

## Решение 2: Переместить build/ в public/build/

```bash
# На сервере через SSH
cd ~/public_html

# Создайте директорию public/
mkdir -p public

# Переместите build/ в public/build/
mv build public/build

# Проверьте
ls -la public/build/
# Должен показать manifest.json
```

## Решение 3: Настроить public_path() через AppServiceProvider

Если симлинки не работают, можно настроить путь программно:

**Отредактируйте `app/Providers/AppServiceProvider.php`:**

```php
<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\App;

class AppServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        // Если проект полностью в public_html/, настройте public_path
        if (file_exists(base_path('public/build'))) {
            // Стандартная структура - ничего не меняем
        } elseif (file_exists(base_path('build'))) {
            // Проект в public_html/ - переопределяем public_path для Vite
            $this->app->bind('path.public', function () {
                return base_path();
            });
        }
    }
}
```

Но это может вызвать другие проблемы, поэтому лучше использовать Решение 1 или 2.

## Быстрое исправление (одна команда)

```bash
# На сервере через SSH
cd ~/public_html && mkdir -p public && ln -s ../build public/build && ls -la public/build/ | head -5
```

## Проверка

После исправления проверьте:

```bash
# Проверьте наличие manifest.json
ls -la ~/public_html/public/build/manifest.json
# или
ls -la ~/public_html/build/manifest.json

# Должен существовать один из путей
```

## Если симлинки не работают

Используйте Решение 2 - просто переместите `build/` в `public/build/`:

```bash
cd ~/public_html
mkdir -p public
mv build public/build
```

## Обновление скрипта setup_all_in_public_html.sh

Скрипт будет обновлен для автоматического создания этой структуры.
