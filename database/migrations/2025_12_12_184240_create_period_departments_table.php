<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('period_departments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('period_id')->constrained('periods')->onDelete('cascade'); // Связь с периодом
            $table->foreignId('department_id')->constrained('departments')->onDelete('cascade'); // Связь с отделом
            $table->decimal('plan_summ', 10, 2)->default(0); // Плановая сумма
            $table->decimal('fact_summ', 10, 2)->default(0); // Фактическая сумма
            $table->unique(['period_id', 'department_id']); // Уникальность: один отдел в периоде
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('period_departments');
    }
};
