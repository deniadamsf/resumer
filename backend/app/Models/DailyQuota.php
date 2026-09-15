<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DailyQuota extends Model
{
    use HasFactory;

    public const MAX_DAILY_LIMIT = 5;

    protected $fillable = [
        'user_id',
        'device_uuid',
        'quota_date',
        'used_count',
        'last_request_at',
    ];

    protected function casts(): array
    {
        return [
            'quota_date' => 'date',
            'used_count' => 'integer',
            'last_request_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get or create today's quota record for given device and optional user.
     */
    public static function getTodayQuota(?int $userId, string $deviceUuid): self
    {
        $today = now()->format('Y-m-d');

        $record = self::where('device_uuid', $deviceUuid)
            ->whereDate('quota_date', $today)
            ->first();

        if ($record) {
            if ($userId && !$record->user_id) {
                $record->update(['user_id' => $userId]);
            }
            return $record;
        }

        return self::create([
            'device_uuid' => $deviceUuid,
            'quota_date' => $today,
            'user_id' => $userId,
            'used_count' => 0,
            'last_request_at' => null,
        ]);
    }

    /**
     * Check if user still has remaining quota today.
     */
    public function hasRemainingQuota(int $maxLimit = self::MAX_DAILY_LIMIT): bool
    {
        return $this->used_count < $maxLimit;
    }

    /**
     * Get remaining quota count.
     */
    public function remainingCount(int $maxLimit = self::MAX_DAILY_LIMIT): int
    {
        return max(0, $maxLimit - $this->used_count);
    }

    /**
     * Deduct 1 quota usage.
     */
    public function consumeQuota(): bool
    {
        if ($this->hasRemainingQuota()) {
            $this->increment('used_count');
            $this->update(['last_request_at' => now()]);
            return true;
        }

        return false;
    }

    /**
     * Rollback quota if AI generation fails.
     */
    public function rollbackQuota(): void
    {
        if ($this->used_count > 0) {
            $this->decrement('used_count');
        }
    }
}
