<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Database\Eloquent\Relations\HasMany;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'google_id',
        'avatar_url',
        'device_uuid',
        'password',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    /**
     * User's CV profiles (up to 3 variations).
     */
    public function cvProfiles(): HasMany
    {
        return $this->hasMany(CvProfile::class)->orderBy('profile_index');
    }

    /**
     * User's daily quota records.
     */
    public function dailyQuotas(): HasMany
    {
        return $this->hasMany(DailyQuota::class);
    }

    /**
     * User's ATS scoring histories.
     */
    public function atsHistories(): HasMany
    {
        return $this->hasMany(AtsHistory::class);
    }
}
