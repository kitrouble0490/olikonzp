<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Page extends Model
{
    protected $fillable = [
        'title',
    ];

    /**
     * Получить все периоды страницы
     */
    public function periods(): HasMany
    {
        return $this->hasMany(Period::class);
    }
}
