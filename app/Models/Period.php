<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Period extends Model
{
    protected $fillable = [
        'page_id',
        'number',
        'name',
        'days',
    ];

    protected $casts = [
        'number' => 'integer',
        'days' => 'integer',
    ];

    /**
     * Получить страницу периода
     */
    public function page(): BelongsTo
    {
        return $this->belongsTo(Page::class);
    }

    /**
     * Получить все отделы в периоде
     */
    public function periodDepartments(): HasMany
    {
        return $this->hasMany(PeriodDepartment::class);
    }
}
