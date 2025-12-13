<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Employee;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;

class EmployeeController extends Controller
{
    /**
     * Получить список всех сотрудников
     */
    public function index(): JsonResponse
    {
        $employees = Employee::with('department')->get();
        return response()->json($employees);
    }

    /**
     * Создать нового сотрудника
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'surname' => 'required|string|max:255',
            'department_id' => 'required|exists:departments,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $employee = Employee::create($request->only(['name', 'surname', 'department_id']));
        $employee->load('department');

        return response()->json([
            'success' => true,
            'data' => $employee
        ], 201);
    }

    /**
     * Получить сотрудника
     */
    public function show(Employee $employee): JsonResponse
    {
        $employee->load('department');
        return response()->json($employee);
    }

    /**
     * Обновить сотрудника
     */
    public function update(Request $request, Employee $employee): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'surname' => 'required|string|max:255',
            'department_id' => 'required|exists:departments,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $employee->update($request->only(['name', 'surname', 'department_id']));
        $employee->load('department');

        return response()->json([
            'success' => true,
            'data' => $employee
        ]);
    }

    /**
     * Удалить сотрудника
     */
    public function destroy(Employee $employee): JsonResponse
    {
        $employee->delete();
        return response()->json([
            'success' => true,
            'message' => 'Сотрудник удален'
        ]);
    }
}
