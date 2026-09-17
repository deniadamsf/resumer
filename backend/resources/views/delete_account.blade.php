@extends('layouts.app')

@section('title', 'Permintaan Penghapusan Akun & Data - Resumer')

@section('meta_description', 'Halaman resmi pengajuan penghapusan akun dan pembersihan data permanen untuk aplikasi Resumer sesuai kebijakan Google Play Console Data Safety.')

@push('styles')
<style>
    .delete-container {
        max-width: 820px;
        margin: 48px auto;
        padding: 0 20px;
    }

    .delete-header {
        text-align: center;
        margin-bottom: 40px;
    }

    .delete-title {
        font-size: 34px;
        font-weight: 900;
        color: var(--primary);
        letter-spacing: -0.6px;
        margin-bottom: 10px;
    }

    .delete-meta {
        font-size: 14px;
        color: var(--text-secondary);
        max-width: 540px;
        margin: 0 auto;
        line-height: 1.5;
    }

    .card-box {
        background: var(--surface);
        border: 1px solid var(--border);
        border-radius: var(--radius-lg);
        padding: 36px;
        box-shadow: var(--shadow-sm);
        margin-bottom: 28px;
    }

    .card-box h2 {
        font-size: 18px;
        font-weight: 800;
        color: var(--primary);
        margin-bottom: 14px;
        letter-spacing: -0.2px;
    }

    .card-box p {
        font-size: 14px;
        color: var(--text-secondary);
        line-height: 1.6;
        margin-bottom: 14px;
    }

    .warning-callout {
        background-color: var(--score-low-bg);
        border: 1px solid #FECDD3;
        border-radius: var(--radius-md);
        padding: 16px 20px;
        display: flex;
        gap: 14px;
        align-items: flex-start;
        margin-bottom: 24px;
    }

    .warning-callout svg {
        color: var(--score-low);
        flex-shrink: 0;
        margin-top: 2px;
    }

    .warning-callout-text {
        font-size: 13.5px;
        color: var(--score-low);
        line-height: 1.5;
        font-weight: 500;
    }

    .data-list {
        list-style: none;
        display: flex;
        flex-direction: column;
        gap: 10px;
        margin: 16px 0;
    }

    .data-list li {
        display: flex;
        align-items: center;
        gap: 10px;
        font-size: 13.5px;
        color: var(--text-primary);
        font-weight: 500;
    }

    .form-group {
        margin-bottom: 20px;
    }

    .form-label {
        display: block;
        font-size: 13.5px;
        font-weight: 600;
        color: var(--text-primary);
        margin-bottom: 6px;
    }

    .form-control {
        width: 100%;
        padding: 12px 16px;
        border: 1px solid var(--border);
        border-radius: var(--radius-md);
        font-family: inherit;
        font-size: 14px;
        color: var(--text-primary);
        background-color: var(--canvas);
        transition: border-color 0.2s ease, box-shadow 0.2s ease;
    }

    .form-control:focus {
        outline: none;
        border-color: var(--primary);
        box-shadow: 0 0 0 3px rgba(11, 19, 43, 0.08);
        background-color: #FFFFFF;
    }

    .form-checkbox-label {
        display: flex;
        align-items: flex-start;
        gap: 12px;
        cursor: pointer;
        font-size: 13px;
        color: var(--text-secondary);
        line-height: 1.5;
        user-select: none;
    }

    .form-checkbox-label input[type="checkbox"] {
        margin-top: 3px;
        width: 16px;
        height: 16px;
        accent-color: var(--primary);
        cursor: pointer;
    }

    .btn-danger {
        background-color: var(--score-low);
        color: #FFFFFF;
        border: 1px solid transparent;
        padding: 12px 24px;
        font-weight: 700;
        font-size: 14.5px;
        border-radius: var(--radius-md);
        cursor: pointer;
        transition: all 0.2s ease;
        display: inline-flex;
        align-items: center;
        gap: 8px;
    }

    .btn-danger:hover {
        background-color: #701A28;
        transform: translateY(-1px);
        box-shadow: 0 4px 14px rgba(136, 19, 55, 0.25);
    }

    .steps-nav-box {
        background: var(--canvas);
        border-radius: var(--radius-md);
        padding: 18px 20px;
        margin-top: 14px;
        border: 1px solid var(--border);
    }

    .badge-pill {
        display: inline-block;
        background: var(--canvas);
        border: 1px solid var(--border);
        padding: 4px 14px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 700;
        color: var(--secondary);
        margin-bottom: 16px;
    }
</style>
@endpush

@section('content')
<div class="delete-container">
    <div class="delete-header">
        <span class="badge-pill">Google Play Policy Compliance</span>
        <h1 class="delete-title">Permintaan Penghapusan Akun & Data</h1>
        <p class="delete-meta">
            Sesuai dengan Kebijakan Data Keamanan Pengguna Google Play Console, Anda memiliki hak penuh untuk meminta penghapusan akun serta seluruh data terkait dari server Resumer.
        </p>
    </div>

    <!-- Data Explanation Card -->
    <div class="card-box">
        <h2>Data Apa Saja yang Akan Dihapus Secara Permanen?</h2>
        <p>
            Ketika permohonan penghapusan akun diproses, sistem kami akan langsung menghapus seluruh entri database yang terhubung dengan akun Anda:
        </p>

        <ul class="data-list">
            <li>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" color="var(--score-low)"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                <span><strong>Profil Pengguna:</strong> Google OAuth ID, alamat email, nama, dan tautan avatar.</span>
            </li>
            <li>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" color="var(--score-low)"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                <span><strong>Seluruh Variasi Profil CV:</strong> Seluruh draf teks CV (hingga 3 profil) dan pengaturan template.</span>
            </li>
            <li>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" color="var(--score-low)"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                <span><strong>Riwayat Skor ATS:</strong> Seluruh catatan evaluasi skor, breakdown parameter, dan feedback AI.</span>
            </li>
            <li>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" color="var(--score-low)"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                <span><strong>Sesi & Kuota:</strong> Token autentikasi Sanctum dan catatan kuota harian.</span>
            </li>
        </ul>

        <div style="margin-top: 20px;">
            <p style="font-size: 13.5px; color: var(--text-secondary);">
                <strong>Kebijakan Retensi Data:</strong> Kami menerapkan penghapusan seketika (<em>immediate permanent purge</em>). Kami tidak mengarsipkan atau mencadangkan data pribadi Anda setelah proses penghapusan selesai dieksekusi.
            </p>
        </div>
    </div>

    <!-- In-App Method Card -->
    <div class="card-box">
        <h2>Metode 1: Menghapus Langsung dari Aplikasi Android</h2>
        <p>
            Jika Anda masih memiliki akses ke smartphone dan aplikasi Resumer, cara tercepat adalah menghapus akun langsung dari dalam aplikasi:
        </p>
        <div class="steps-nav-box">
            <ol style="margin-left: 20px; font-size: 13.5px; color: var(--text-primary); line-height: 1.8;">
                <li>Buka aplikasi <strong>Resumer</strong> di smartphone Anda.</li>
                <li>Pilih tab <strong>Profil</strong> pada navigasi bawah (ikon paling kanan).</li>
                <li>Gulir ke bawah dan ketuk opsi <strong>Hapus Akun & Data</strong>.</li>
                <li>Konfirmasikan dialog peringatan untuk menyelesaikan proses penghapusan instan.</li>
            </ol>
        </div>
    </div>

    <!-- Web Form Request Card (Method 2) -->
    <div class="card-box">
        <h2>Metode 2: Formulir Permintaan Hapus Akun Online</h2>
        <p>
            Jika Anda sudah mencopot pemasangan aplikasi atau ingin menghapus data Anda secara langsung melalui web ini, silakan isi formulir di bawah ini:
        </p>

        <div class="warning-callout">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
            <div class="warning-callout-text">
                Tindakan ini tidak dapat dibatalkan. Semua profil resume yang pernah Anda rancang akan terhapus selamanya dan tidak dapat dipulihkan kembali.
            </div>
        </div>

        <form action="{{ route('account-deletion.submit') }}" method="POST">
            @csrf

            <div class="form-group">
                <label for="email" class="form-label">Alamat Email Akun Google Terdaftar <span style="color: var(--score-low);">*</span></label>
                <input 
                    type="email" 
                    id="email" 
                    name="email" 
                    class="form-control" 
                    placeholder="nama.anda@gmail.com" 
                    value="{{ old('email') }}" 
                    required
                >
                <span style="font-size: 12px; color: var(--text-secondary); margin-top: 4px; display: block;">
                    Masukkan email yang Anda gunakan saat login dengan Google di aplikasi Resumer.
                </span>
            </div>

            <div class="form-group">
                <label for="reason" class="form-label">Alasan Penghapusan (Opsional)</label>
                <select id="reason" name="reason" class="form-control">
                    <option value="">-- Pilih Alasan (Opsional) --</option>
                    <option value="Sudah mendapatkan pekerjaan">Saya sudah mendapatkan pekerjaan</option>
                    <option value="Tidak memerlukan resume lagi">Tidak memerlukan resume lagi saat ini</option>
                    <option value="Ingin membersihkan data pribadi">Ingin membersihkan data pribadi saya</option>
                    <option value="Alasan lainnya">Lainnya</option>
                </select>
            </div>

            <div class="form-group" style="margin-top: 24px;">
                <label class="form-checkbox-label">
                    <input type="checkbox" name="confirm_deletion" value="1" required>
                    <span>
                        Saya memahami dan menyatakan persetujuan secara sadar bahwa akun Google saya beserta seluruh 3 draf profil CV, data riwayat skor ATS, dan preferensi akun di Resumer akan dihapus permanen dari server database dan tidak dapat dipulihkan.
                    </span>
                </label>
            </div>

            <div style="margin-top: 28px;">
                <button type="submit" class="btn-danger">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><line x1="10" y1="11" x2="10" y2="17"/><line x1="14" y1="11" x2="14" y2="17"/></svg>
                    Hapus Akun & Data Saya Secara Permanen
                </button>
            </div>
        </form>
    </div>

    <!-- Contact & Assistance -->
    <div style="text-align: center; margin-top: 32px; font-size: 13px; color: var(--text-secondary);">
        Butuh bantuan teknis seputar akun Anda? Hubungi Petugas Privasi di <a href="mailto:privacy@cellanoma.my.id" style="color: var(--primary); font-weight: 700;">privacy@cellanoma.my.id</a>.
    </div>
</div>
@endsection
