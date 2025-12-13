<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Period;
use App\Models\PeriodDepartment;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class PeriodDepartmentController extends Controller
{
    /**
     * Добавить отдел в период
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'period_id' => 'required|exists:periods,id',
            'department_id' => 'required|exists:departments,id',
            'plan_summ' => 'nullable|numeric|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        // Проверка на дубликат
        $exists = PeriodDepartment::where('period_id', $request->period_id)
            ->where('department_id', $request->department_id)
            ->exists();

        if ($exists) {
            return response()->json([
                'success' => false,
                'message' => 'Отдел уже добавлен в этот период'
            ], 422);
        }

        DB::beginTransaction();
        try {
            $periodDepartment = PeriodDepartment::create([
                'period_id' => $request->period_id,
                'department_id' => $request->department_id,
                'plan_summ' => $request->plan_summ ?? 0,
                'fact_summ' => 0,
            ]);

            $period = Period::findOrFail($request->period_id);
            
            // Создать дни периода для отдела
            for ($i = 1; $i <= $period->days; $i++) {
                $periodDepartment->periodItems()->create([
                    'number' => $i,
                    'plan' => $request->plan_summ ? ($request->plan_summ / $period->days) : 0,
                    'fact' => null,
                    'percent' => 0,
                    'zp' => 0,
                ]);
            }

            // Пересчитать план по дням, если указана общая сумма
            if ($request->plan_summ) {
                $this->recalculatePlanDays($periodDepartment, $request->plan_summ);
            }

            $periodDepartment->load(['department', 'period', 'periodItems']);

            DB::commit();

            return response()->json([
                'success' => true,
                'data' => $periodDepartment
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Ошибка при создании: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Обновить период-отдел
     */
    public function update(Request $request, PeriodDepartment $periodDepartment): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'plan_summ' => 'nullable|numeric|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        if ($request->has('plan_summ')) {
            $this->recalculatePlanDays($periodDepartment, $request->plan_summ);
            $periodDepartment->plan_summ = $request->plan_summ;
            $periodDepartment->save();
        }

        $periodDepartment->load(['department', 'period', 'periodItems']);

        return response()->json([
            'success' => true,
            'data' => $periodDepartment
        ]);
    }

    /**
     * Удалить отдел из периода
     */
    public function destroy(PeriodDepartment $periodDepartment): JsonResponse
    {
        $periodDepartment->delete();
        return response()->json([
            'success' => true,
            'message' => 'Отдел удален из периода'
        ]);
    }

    /**
     * Пересчитать план по дням
     */
    private function recalculatePlanDays(PeriodDepartment $periodDepartment, float $planSumm): void
    {
        $daysCount = $periodDepartment->periodItems()->count();
        if ($daysCount > 0) {
            $dayPlan = $planSumm / $daysCount;
            $periodDepartment->periodItems()->update(['plan' => round($dayPlan, 2)]);
        }
    }
}
