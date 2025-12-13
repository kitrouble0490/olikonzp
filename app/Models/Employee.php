<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Employee extends Model
{
    protected $fillable = [
        'name',
        'surname',
        'department_id',
    ];

    /**
     * Получить отдел сотрудника
     */
    public function department(): BelongsTo
    {
        return $this->belongsTo(Department::class);
    }

    /**
     * Получить все дни, в которых участвует сотрудник
     */
    public function periodItems(): BelongsToMany
    {
        return $this->belongsToMany(PeriodItem::class, 'item_employees')
            ->withTimestamps();
    }
}
