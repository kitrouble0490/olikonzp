<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

// Если весь проект в public_html/, basePath должен быть текущей директорией
// Используйте этот файл вместо bootstrap/app.php если проект полностью в public_html/
return Application::configure(basePath: __DIR__ . '/..')
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        // Добавляем StartSession и EncryptCookies к API маршрутам для поддержки сессий при авторизации
        // Это позволяет использовать сессии без CSRF проверки (стандартная практика для API)
        $middleware->api(prepend: [
            \Illuminate\Cookie\Middleware\EncryptCookies::class,
            \Illuminate\Session\Middleware\StartSession::class,
            \Illuminate\Session\Middleware\AuthenticateSession::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        //
    })->create();
