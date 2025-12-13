<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ItemEmployee extends Model
{
    protected $fillable = [
        'period_item_id',
        'employee_id',
    ];

    /**
     * Получить день периода
     */
    public function periodItem(): BelongsTo
    {
        return $this->belongsTo(PeriodItem::class);
    }

    /**
     * Получить сотрудника
     */
    public function employee(): BelongsTo
    {
        return $this->belongsTo(Employee::class);
    }
}
