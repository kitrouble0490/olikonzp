<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PeriodItem;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class PeriodItemController extends Controller
{
    /**
     * Обновить день периода (план, факт, процент)
     */
    public function update(Request $request, PeriodItem $periodItem): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'plan' => 'nullable|numeric|min:0',
            'fact' => 'nullable|numeric|min:0',
            'percent' => 'nullable|numeric|min:0|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        DB::beginTransaction();
        try {
            $manualPercent = $request->has('percent');

            if ($request->has('plan')) {
                $periodItem->plan = $request->plan;
            }

            if ($request->has('fact')) {
                $periodItem->fact = $request->fact;
                
                // Автоматически рассчитать процент, если не указан вручную
                if (!$manualPercent) {
                    $periodItem->calculatePercent();
                }
            }

            if ($manualPercent) {
                $periodItem->percent = $request->percent;
            }

            // Пересчитать зарплату
            $periodItem->recalculateZp();
            $periodItem->save();

            // Пересчитать фактическую сумму периода-отдела
            $periodDepartment = $periodItem->periodDepartment;
            $periodDepartment->recalculateFactSumm();

            // Пересчитать зарплату всех сотрудников отдела в этом периоде
            $this->recalculateEmployeeZp($periodDepartment);

            $periodItem->load(['periodDepartment.department', 'employees']);

            DB::commit();

            return response()->json([
                'success' => true,
                'data' => $periodItem
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Ошибка при обновлении: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Добавить/удалить сотрудника из дня
     */
    public function toggleEmployee(Request $request, PeriodItem $periodItem): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'employee_id' => 'required|exists:employees,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        DB::beginTransaction();
        try {
            $employeeId = $request->employee_id;
            $attached = $periodItem->employees()->where('employees.id', $employeeId)->exists();

            if ($attached) {
                $periodItem->employees()->detach($employeeId);
            } else {
                $periodItem->employees()->attach($employeeId);
            }

            // Пересчитать зарплату дня
            $periodItem->recalculateZp();
            $periodItem->save();

            // Пересчитать зарплату всех сотрудников отдела
            $periodDepartment = $periodItem->periodDepartment;
            $this->recalculateEmployeeZp($periodDepartment);

            $periodItem->load(['periodDepartment.department', 'employees']);

            DB::commit();

            return response()->json([
                'success' => true,
                'data' => $periodItem,
                'attached' => !$attached
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Ошибка: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Пересчитать зарплату всех сотрудников отдела в периоде
     */
    private function recalculateEmployeeZp($periodDepartment): void
    {
        $employees = $periodDepartment->department->employees;
        
        foreach ($employees as $employee) {
            $totalZp = $periodDepartment->periodItems()
                ->whereHas('employees', function ($query) use ($employee) {
                    $query->where('employees.id', $employee->id);
                })
                ->sum('zp');
            
            // Сохраняем в кэш или вычисляем на лету
            // В данном случае будем вычислять на лету при запросе
        }
    }
}
