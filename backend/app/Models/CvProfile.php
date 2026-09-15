<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class CvProfile extends Model
{
    use HasFactory;

    public const MAX_PROFILES_PER_USER = 3;

    protected $fillable = [
        'user_id',
        'profile_index',
        'title',
        'target_job',
        'template_id',
        'font_family',
        'accent_color',
        'cv_data',
        'ats_score',
    ];

    protected function casts(): array
    {
        return [
            'profile_index' => 'integer',
            'ats_score' => 'integer',
            'cv_data' => 'array',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function atsHistories(): HasMany
    {
        return $this->hasMany(AtsHistory::class);
    }
}
