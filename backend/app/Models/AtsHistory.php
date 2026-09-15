<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AtsHistory extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'device_uuid',
        'cv_profile_id',
        'score',
        'breakdown',
        'actionable_feedback',
    ];

    protected function casts(): array
    {
        return [
            'score' => 'integer',
            'breakdown' => 'array',
            'actionable_feedback' => 'array',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function cvProfile(): BelongsTo
    {
        return $this->belongsTo(CvProfile::class);
    }
}
