<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Page;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;

class PageController extends Controller
{
    /**
     * Получить список всех страниц
     */
    public function index(): JsonResponse
    {
        $pages = Page::with('periods')->get();
        return response()->json($pages);
    }

    /**
     * Создать новую страницу
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:255|unique:pages,title',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $page = Page::create($request->only('title'));

        return response()->json([
            'success' => true,
            'data' => $page
        ], 201);
    }

    /**
     * Получить страницу с периодами
     */
    public function show(Page $page): JsonResponse
    {
        $page->load([
            'periods.periodDepartments' => function ($query) {
                $query->with([
                    'department.employees',
                    'periodItems.employees'
                ]);
            }
        ]);
        return response()->json($page);
    }

    /**
     * Обновить страницу
     */
    public function update(Request $request, Page $page): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:255|unique:pages,title,' . $page->id,
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $page->update($request->only('title'));

        return response()->json([
            'success' => true,
            'data' => $page
        ]);
    }

    /**
     * Удалить страницу
     */
    public function destroy(Page $page): JsonResponse
    {
        $page->delete();
        return response()->json([
            'success' => true,
            'message' => 'Страница удалена'
        ]);
    }
}
