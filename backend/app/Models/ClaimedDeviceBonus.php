<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ClaimedDeviceBonus extends Model
{
    use HasFactory;

    protected $fillable = [
        'device_uuid',
        'user_id',
        'claimed_at',
    ];

    protected function casts(): array
    {
        return [
            'claimed_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Cek apakah bonus selamat datang sudah pernah diklaim oleh perangkat ini
     * (Device ID baru berbasis ANDROID_ID atau UUID lama sebelum update) ATAU oleh akun ini.
     */
    public static function isClaimed(?string $deviceUuid, ?string $legacyDeviceUuid, ?int $userId): bool
    {
        $deviceIds = array_values(array_filter([$deviceUuid, $legacyDeviceUuid]));

        return self::query()
            ->where(function ($q) use ($deviceIds, $userId) {
                if (!empty($deviceIds)) {
                    $q->whereIn('device_uuid', $deviceIds);
                }
                if ($userId) {
                    $q->orWhere('user_id', $userId);
                }
                if (empty($deviceIds) && !$userId) {
                    $q->whereRaw('1 = 0');
                }
            })
            ->exists();
    }
}
