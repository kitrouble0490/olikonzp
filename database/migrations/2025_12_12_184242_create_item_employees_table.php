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
        Schema::create('item_employees', function (Blueprint $table) {
            $table->id();
            $table->foreignId('period_item_id')->constrained('period_items')->onDelete('cascade'); // Связь с днем периода
            $table->foreignId('employee_id')->constrained('employees')->onDelete('cascade'); // Связь с сотрудником
            $table->unique(['period_item_id', 'employee_id']); // Уникальность: один сотрудник на день
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('item_employees');
    }
};
