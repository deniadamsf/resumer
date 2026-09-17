<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class AccountDeletionController extends Controller
{
    /**
     * Show the account deletion explanation and request form.
     */
    public function show()
    {
        return view('delete_account');
    }

    /**
     * Process the account deletion request submitted from the web form.
     */
    public function submit(Request $request)
    {
        $validated = $request->validate([
            'email' => 'required|email|max:255',
            'confirm_deletion' => 'required|accepted',
            'reason' => 'nullable|string|max:500',
        ], [
            'email.required' => 'Silakan masukkan alamat email akun Google Anda.',
            'email.email' => 'Format alamat email tidak valid.',
            'confirm_deletion.accepted' => 'Anda wajib mencentang persetujuan konfirmasi penghapusan data permanen.',
        ]);

        $email = trim(strtolower($validated['email']));

        try {
            $user = User::where('email', $email)->first();

            if ($user) {
                $userName = $user->name;

                DB::transaction(function () use ($user) {
                    // Revoke all sanctum authentication tokens
                    $user->tokens()->delete();

                    // Cascade delete CV profiles, ATS histories, and quotas
                    $user->cvProfiles()->delete();
                    $user->atsHistories()->delete();
                    $user->dailyQuotas()->delete();

                    // Delete the user record
                    $user->delete();
                });

                Log::info("Account deletion executed for email: {$email} (Name: {$userName}) via Web Request. Reason: " . ($validated['reason'] ?? 'Not provided'));

                return redirect()->route('account-deletion')->with('success', "Permintaan berhasil diproses. Seluruh akun, variasi CV, dan riwayat skor ATS yang terhubung dengan {$email} telah dihapus secara permanen dari server kami.");
            } else {
                return redirect()->route('account-deletion')->with('info', "Alamat email {$email} tidak ditemukan di database kami atau akun tersebut telah dihapus sebelumnya. Tidak ada data pribadi yang tersisa.");
            }
        } catch (\Exception $e) {
            Log::error("Account deletion failed for email {$email}: " . $e->getMessage());
            return redirect()->route('account-deletion')->with('error', 'Terjadi kendala saat memproses permintaan Anda. Silakan coba kembali atau hubungi privacy@cellanoma.my.id.');
        }
    }
}
