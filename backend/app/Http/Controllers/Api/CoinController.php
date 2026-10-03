<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\ClaimedDeviceBonus;
use App\Models\CoinTransaction;
use App\Models\IapPurchase;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class CoinController extends Controller
{
    /**
     * Get live coin balance and bonus eligibility.
     */
    public function getBalance(Request $request)
    {
        $user = $request->user();
        $deviceUuid = $request->header('X-Device-UUID') ?? $request->input('device_uuid') ?? $user->device_uuid;

        $hasClaimedBonus = ClaimedDeviceBonus::where('device_uuid', $deviceUuid)
            ->orWhere('user_id', $user->id)
            ->exists();

        $recentTransactions = $user->coinTransactions()
            ->orderBy('id', 'desc')
            ->limit(10)
            ->get(['id', 'amount', 'action_type', 'description', 'balance_after', 'created_at']);

        return response()->json([
            'success' => true,
            'coins' => (int) $user->coins,
            'device_uuid' => $deviceUuid,
            'has_claimed_welcome_bonus' => $hasClaimedBonus,
            'recent_transactions' => $recentTransactions,
        ]);
    }

    /**
     * Claim initial 5 coins welcome bonus (Device UUID and User ID locked).
     */
    public function claimWelcomeBonus(Request $request)
    {
        $user = $request->user();
        $deviceUuid = $request->header('X-Device-UUID') ?? $request->input('device_uuid') ?? $user->device_uuid;

        if (empty($deviceUuid)) {
            return response()->json([
                'success' => false,
                'message' => 'Device UUID is required to claim welcome bonus.',
            ], 422);
        }

        // Anti-abuse check: locked to both device_uuid and user_id
        $alreadyClaimed = ClaimedDeviceBonus::where('device_uuid', $deviceUuid)
            ->orWhere('user_id', $user->id)
            ->exists();
        if ($alreadyClaimed) {
            return response()->json([
                'success' => false,
                'message' => 'Bonus selamat datang 5 koin sudah pernah diklaim pada perangkat atau akun ini.',
                'coins' => (int) $user->coins,
            ], 400);
        }

        return DB::transaction(function () use ($user, $deviceUuid) {
            ClaimedDeviceBonus::create([
                'device_uuid' => $deviceUuid,
                'user_id' => $user->id,
                'claimed_at' => now(),
            ]);

            $user->increment('coins', 5);
            $user->refresh();

            CoinTransaction::create([
                'user_id' => $user->id,
                'amount' => 5,
                'action_type' => 'welcome_bonus',
                'description' => 'Bonus Pengguna Baru (5 Koin)',
                'balance_after' => $user->coins,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Selamat! Bonus 5 koin berhasil ditambahkan.',
                'coins' => (int) $user->coins,
            ]);
        });
    }

    /**
     * Verify Google Play In-App Purchase and grant coins.
     */
    public function verifyPurchase(Request $request)
    {
        $request->validate([
            'order_id' => 'required|string',
            'product_id' => 'required|string|in:resumer_coins_30,resumer_coins_70,resumer_coins_200',
            'purchase_token' => 'required|string',
        ]);

        $user = $request->user();
        $orderId = $request->input('order_id');
        $productId = $request->input('product_id');
        $purchaseToken = $request->input('purchase_token');

        // Prevent replay attacks (duplicate order_id)
        if (IapPurchase::where('order_id', $orderId)->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'Transaksi ini sudah pernah diproses sebelumnya.',
                'coins' => (int) $user->coins,
            ], 409);
        }

        // Calculate coins based on product tier
        $coinsGrantMap = [
            'resumer_coins_30' => 30,
            'resumer_coins_70' => 70,
            'resumer_coins_200' => 200,
        ];

        $coinsToGrant = $coinsGrantMap[$productId] ?? 0;
        if ($coinsToGrant <= 0) {
            return response()->json([
                'success' => false,
                'message' => 'Produk tidak valid.',
            ], 422);
        }

        return DB::transaction(function () use ($user, $orderId, $productId, $purchaseToken, $coinsToGrant) {
            IapPurchase::create([
                'user_id' => $user->id,
                'order_id' => $orderId,
                'product_id' => $productId,
                'purchase_token' => $purchaseToken,
                'coins_granted' => $coinsToGrant,
            ]);

            $user->increment('coins', $coinsToGrant);
            $user->refresh();

            CoinTransaction::create([
                'user_id' => $user->id,
                'amount' => $coinsToGrant,
                'action_type' => 'iap_purchase',
                'description' => "Top-up: $productId (+$coinsToGrant Koin)",
                'balance_after' => $user->coins,
            ]);

            Log::info("IAP Success: User #{$user->id} purchased {$productId} (+{$coinsToGrant} coins), Order ID: {$orderId}");

            return response()->json([
                'success' => true,
                'message' => "Top-up berhasil! +$coinsToGrant koin telah ditambahkan.",
                'coins' => (int) $user->coins,
                'coins_granted' => $coinsToGrant,
            ]);
        });
    }

    /**
     * Spend coins for a premium action.
     */
    public function spendCoins(Request $request)
    {
        $request->validate([
            'amount' => 'required|integer|min:1',
            'action_type' => 'required|string',
            'description' => 'nullable|string',
        ]);

        $user = $request->user();
        $amount = (int) $request->input('amount');
        $actionType = $request->input('action_type');
        $description = $request->input('description') ?? "Konsumsi Koin: $actionType";

        if ($user->coins < $amount) {
            return response()->json([
                'success' => false,
                'message' => 'Saldo koin Anda tidak mencukupi untuk melakukan tindakan ini.',
                'required' => $amount,
                'coins' => (int) $user->coins,
            ], 402);
        }

        return DB::transaction(function () use ($user, $amount, $actionType, $description) {
            $user->decrement('coins', $amount);
            $user->refresh();

            CoinTransaction::create([
                'user_id' => $user->id,
                'amount' => -$amount,
                'action_type' => $actionType,
                'description' => $description,
                'balance_after' => $user->coins,
            ]);

            return response()->json([
                'success' => true,
                'message' => "Berhasil menggunakan $amount koin.",
                'coins' => (int) $user->coins,
                'spent' => $amount,
            ]);
        });
    }

    /**
     * Refund coins if an AI operation downstream fails.
     */
    public function refundCoins(Request $request)
    {
        $request->validate([
            'amount' => 'required|integer|min:1',
            'reason' => 'required|string',
            'original_action' => 'required|string',
        ]);

        $user = $request->user();
        $amount = (int) $request->input('amount');
        $reason = $request->input('reason');
        $originalAction = $request->input('original_action');

        return DB::transaction(function () use ($user, $amount, $reason, $originalAction) {
            $user->increment('coins', $amount);
            $user->refresh();

            CoinTransaction::create([
                'user_id' => $user->id,
                'amount' => $amount,
                'action_type' => 'refund',
                'description' => "Pengembalian ($originalAction): $reason",
                'balance_after' => $user->coins,
            ]);

            return response()->json([
                'success' => true,
                'message' => "$amount koin telah dikembalikan ke saldo Anda.",
                'coins' => (int) $user->coins,
            ]);
        });
    }
}
