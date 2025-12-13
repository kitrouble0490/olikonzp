<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\PageController;
use App\Http\Controllers\Api\DepartmentController;
use App\Http\Controllers\Api\EmployeeController;
use App\Http\Controllers\Api\PeriodController;
use App\Http\Controllers\Api\PeriodDepartmentController;
use App\Http\Controllers\Api\PeriodItemController;
use App\Http\Controllers\Api\AuthController;

// Авторизация (публичные маршруты с поддержкой сессий)
// StartSession middleware уже добавлен глобально для API маршрутов
Route::post('/auth/login', [AuthController::class, 'login']);
Route::post('/auth/logout', [AuthController::class, 'logout'])->middleware('auth');
Route::get('/auth/check', [AuthController::class, 'check']);

// Защищенные маршруты (требуют авторизации)
Route::middleware('auth')->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
    // Pages (Страницы/Годы)
    Route::apiResource('pages', PageController::class);

    // Departments (Отделы)
    Route::apiResource('departments', DepartmentController::class);

    // Employees (Сотрудники)
    Route::apiResource('employees', EmployeeController::class);

    // Periods (Расчетные периоды/Месяцы)
    Route::apiResource('periods', PeriodController::class);
    Route::get('/periods/months/list', [PeriodController::class, 'months']);

    // Period Departments (Отделы в периоде)
    Route::apiResource('period-departments', PeriodDepartmentController::class);

    // Period Items (Дни периода)
    Route::put('/period-items/{periodItem}', [PeriodItemController::class, 'update']);
    Route::post('/period-items/{periodItem}/toggle-employee', [PeriodItemController::class, 'toggleEmployee']);
});

