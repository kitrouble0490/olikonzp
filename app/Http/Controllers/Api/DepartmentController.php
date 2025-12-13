<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Department;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;

class DepartmentController extends Controller
{
    /**
     * Получить список всех отделов
     */
    public function index(): JsonResponse
    {
        $departments = Department::with('employees')->get();
        return response()->json($departments);
    }

    /**
     * Создать новый отдел
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255|unique:departments,name',
            'min_percent' => 'required|numeric|min:0|max:100',
            'max_percent' => 'required|numeric|min:0|max:100|gt:min_percent',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $department = Department::create($request->only(['name', 'min_percent', 'max_percent']));

        return response()->json([
            'success' => true,
            'data' => $department
        ], 201);
    }

    /**
     * Получить отдел
     */
    public function show(Department $department): JsonResponse
    {
        $department->load('employees');
        return response()->json($department);
    }

    /**
     * Обновить отдел
     */
    public function update(Request $request, Department $department): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255|unique:departments,name,' . $department->id,
            'min_percent' => 'required|numeric|min:0|max:100',
            'max_percent' => 'required|numeric|min:0|max:100|gt:min_percent',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $department->update($request->only(['name', 'min_percent', 'max_percent']));

        return response()->json([
            'success' => true,
            'data' => $department
        ]);
    }

    /**
     * Удалить отдел
     */
    public function destroy(Department $department): JsonResponse
    {
        $department->delete();
        return response()->json([
            'success' => true,
            'message' => 'Отдел удален'
        ]);
    }
}
