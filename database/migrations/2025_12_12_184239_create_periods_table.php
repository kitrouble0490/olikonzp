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
        Schema::create('periods', function (Blueprint $table) {
            $table->id();
            $table->foreignId('page_id')->constrained('pages')->onDelete('cascade'); // Связь со страницей (годом)
            $table->tinyInteger('number')->unsigned(); // Номер месяца (1-12)
            $table->string('name'); // Название месяца (Январь, Февраль и т.д.)
            $table->tinyInteger('days')->unsigned(); // Количество дней в месяце
            $table->unique(['page_id', 'number']); // Уникальность: один месяц на страницу
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('periods');
    }
};
