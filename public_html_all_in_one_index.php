<?php

use Illuminate\Foundation\Application;
use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

// Если весь проект находится в public_html/, пути должны быть относительно текущей директории
// Все файлы Laravel находятся в той же директории, что и этот index.php

// Determine if the application is in maintenance mode...
if (file_exists($maintenance = __DIR__ . '/storage/framework/maintenance.php')) {
    require $maintenance;
}

// Register the Composer autoloader...
require __DIR__ . '/vendor/autoload.php';

// Bootstrap Laravel and handle the request...
/** @var Application $app */
$app = require_once __DIR__ . '/bootstrap/app.php';

$app->handleRequest(Request::capture());
