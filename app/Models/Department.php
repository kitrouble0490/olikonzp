<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Department extends Model
{
    protected $fillable = [
        'name',
        'min_percent',
        'max_percent',
    ];

    protected $casts = [
        'min_percent' => 'decimal:2',
        'max_percent' => 'decimal:2',
    ];

    /**
     * Получить всех сотрудников отдела
     */
    public function employees(): HasMany
    {
        return $this->hasMany(Employee::class);
    }

    /**
     * Получить все связи с периодами
     */
    public function periodDepartments(): HasMany
    {
        return $this->hasMany(PeriodDepartment::class);
    }
}
