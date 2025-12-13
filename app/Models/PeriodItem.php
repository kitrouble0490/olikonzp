<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class PeriodItem extends Model
{
    protected $fillable = [
        'period_department_id',
        'number',
        'plan',
        'fact',
        'percent',
        'zp',
    ];

    protected $casts = [
        'number' => 'integer',
        'plan' => 'decimal:2',
        'fact' => 'decimal:2',
        'percent' => 'decimal:2',
        'zp' => 'decimal:2',
    ];

    /**
     * Получить период-отдел
     */
    public function periodDepartment(): BelongsTo
    {
        return $this->belongsTo(PeriodDepartment::class);
    }

    /**
     * Получить сотрудников, работавших в этот день
     */
    public function employees(): BelongsToMany
    {
        return $this->belongsToMany(Employee::class, 'item_employees')
            ->withTimestamps();
    }

    /**
     * Пересчитать зарплату для дня
     */
    public function recalculateZp(): void
    {
        $employeeCount = $this->employees()->count();
        
        if ($employeeCount > 0 && $this->fact && $this->percent) {
            $this->zp = (($this->fact / 100) * $this->percent) / $employeeCount;
        } else {
            $this->zp = 0;
        }
        
        $this->save();
    }

    /**
     * Автоматически определить процент на основе плана и факта
     */
    public function calculatePercent(): void
    {
        $department = $this->periodDepartment->department;
        
        if ($this->plan - 1000 > $this->fact) {
            $this->percent = $department->min_percent;
        } else {
            $this->percent = $department->max_percent;
        }
        
        $this->save();
    }
}
