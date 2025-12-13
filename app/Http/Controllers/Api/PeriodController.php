<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Page;
use App\Models\Period;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class PeriodController extends Controller
{
    // Список месяцев
    private const MONTHS = [
        1 => ['name' => 'Январь', 'days' => 31],
        2 => ['name' => 'Февраль', 'days' => 29],
        3 => ['name' => 'Март', 'days' => 31],
        4 => ['name' => 'Апрель', 'days' => 30],
        5 => ['name' => 'Май', 'days' => 31],
        6 => ['name' => 'Июнь', 'days' => 30],
        7 => ['name' => 'Июль', 'days' => 31],
        8 => ['name' => 'Август', 'days' => 31],
        9 => ['name' => 'Сентябрь', 'days' => 30],
        10 => ['name' => 'Октябрь', 'days' => 31],
        11 => ['name' => 'Ноябрь', 'days' => 30],
        12 => ['name' => 'Декабрь', 'days' => 31],
    ];

    /**
     * Получить список всех периодов
     */
    public function index(): JsonResponse
    {
        $periods = Period::with(['page', 'periodDepartments.department'])->get();
        return response()->json($periods);
    }

    /**
     * Создать новый период (месяц) для страницы
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'page_id' => 'required|exists:pages,id',
            'number' => 'required|integer|min:1|max:12',
            'days' => 'nullable|integer|min:1|max:31',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        // Проверка на дубликат периода в странице
        $exists = Period::where('page_id', $request->page_id)
            ->where('number', $request->number)
            ->exists();

        if ($exists) {
            return response()->json([
                'success' => false,
                'message' => 'Период с таким номером уже существует для этой страницы'
            ], 422);
        }

        $monthData = self::MONTHS[$request->number];
        $days = $request->days ?? $monthData['days'];

        $period = Period::create([
            'page_id' => $request->page_id,
            'number' => $request->number,
            'name' => $monthData['name'],
            'days' => $days,
        ]);

        $period->load('page');

        return response()->json([
            'success' => true,
            'data' => $period
        ], 201);
    }

    /**
     * Получить период с полной информацией
     */
    public function show(Period $period): JsonResponse
    {
        $period->load([
            'page',
            'periodDepartments.department.employees',
            'periodDepartments.periodItems.employees'
        ]);
        return response()->json($period);
    }

    /**
     * Обновить период
     */
    public function update(Request $request, Period $period): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'days' => 'nullable|integer|min:1|max:31',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        if ($request->has('days')) {
            $period->days = $request->days;
            $period->save();
        }

        return response()->json([
            'success' => true,
            'data' => $period
        ]);
    }

    /**
     * Удалить период
     * Можно удалить только если период пуст (нет отделов)
     */
    public function destroy(Period $period): JsonResponse
    {
        // Проверяем, есть ли отделы в периоде
        if ($period->periodDepartments()->count() > 0) {
            return response()->json([
                'success' => false,
                'message' => 'Нельзя удалить период, в котором есть отделы. Сначала удалите все отделы.'
            ], 422);
        }
        
        $period->delete();
        return response()->json([
            'success' => true,
            'message' => 'Период удален'
        ]);
    }

    /**
     * Получить список месяцев
     */
    public function months(): JsonResponse
    {
        return response()->json(self::MONTHS);
    }
}
