<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * Akun developer (denif9734@gmail.com) sudah pernah menerima 1000 koin lewat logika lama
 * yang tidak mencatat transaksi. Tandai sebagai "sudah diberikan" (amount 0, saldo tidak berubah)
 * agar logika grant sekali-saja di AuthController tidak memberi 1000 koin lagi.
 */
return new class extends Migration
{
    public function up(): void
    {
        $user = DB::table('users')->whereRaw('LOWER(email) = ?', ['denif9734@gmail.com'])->first();
        if (!$user) {
            return;
        }

        $alreadyMarked = DB::table('coin_transactions')
            ->where('user_id', $user->id)
            ->where('action_type', 'developer_grant')
            ->exists();

        if (!$alreadyMarked) {
            DB::table('coin_transactions')->insert([
                'user_id' => $user->id,
                'amount' => 0,
                'action_type' => 'developer_grant',
                'description' => 'Developer Grant (sudah diberikan sebelumnya)',
                'balance_after' => max(0, (int) $user->coins),
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }

    public function down(): void
    {
        // Marker sengaja tidak dihapus agar grant tidak terulang.
    }
};
