<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class PeriodDepartment extends Model
{
    protected $fillable = [
        'period_id',
        'department_id',
        'plan_summ',
        'fact_summ',
    ];

    protected $casts = [
        'plan_summ' => 'decimal:2',
        'fact_summ' => 'decimal:2',
    ];

    /**
     * Получить период
     */
    public function period(): BelongsTo
    {
        return $this->belongsTo(Period::class);
    }

    /**
     * Получить отдел
     */
    public function department(): BelongsTo
    {
        return $this->belongsTo(Department::class);
    }

    /**
     * Получить все дни периода для отдела
     */
    public function periodItems(): HasMany
    {
        return $this->hasMany(PeriodItem::class);
    }

    /**
     * Получить сотрудников отдела для этого периода
     */
    public function getEmployeesAttribute()
    {
        return $this->department->employees ?? collect();
    }

    /**
     * Получить зарплату сотрудника за период
     */
    public function getEmployeeZp($employeeId): float
    {
        return $this->periodItems()
            ->whereHas('employees', function ($query) use ($employeeId) {
                $query->where('employees.id', $employeeId);
            })
            ->sum('zp') ?? 0;
    }

    /**
     * Пересчитать фактическую сумму из всех дней
     */
    public function recalculateFactSumm(): void
    {
        $this->fact_summ = $this->periodItems()->sum('fact') ?? 0;
        $this->save();
    }
}
