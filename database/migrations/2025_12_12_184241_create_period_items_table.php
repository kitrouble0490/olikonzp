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
        Schema::create('period_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('period_department_id')->constrained('period_departments')->onDelete('cascade'); // Связь с периодом-отделом
            $table->tinyInteger('number')->unsigned(); // Номер дня (1-31)
            $table->decimal('plan', 10, 2)->default(0); // План на день
            $table->decimal('fact', 10, 2)->nullable(); // Факт на день
            $table->decimal('percent', 5, 2)->default(0); // Процент бонуса
            $table->decimal('zp', 10, 2)->default(0); // Зарплата за день
            $table->unique(['period_department_id', 'number']); // Уникальность: один день в периоде-отделе
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('period_items');
    }
};
