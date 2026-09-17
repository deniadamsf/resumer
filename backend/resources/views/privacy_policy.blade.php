@extends('layouts.app')

@section('title', 'Kebijakan Privasi (Privacy Policy) - Resumer')

@section('meta_description', 'Kebijakan privasi resmi aplikasi Resumer (AI ATS CV Maker). Penjelasan lengkap pemrosesan foto 100% client-side, kompilasi PDF lokal, dan keamanan data pengguna.')

@push('styles')
<style>
    .legal-container {
        max-width: 860px;
        margin: 48px auto;
        padding: 0 20px;
    }

    .legal-header {
        text-align: center;
        margin-bottom: 40px;
    }

    .legal-title {
        font-size: 34px;
        font-weight: 900;
        color: var(--primary);
        letter-spacing: -0.6px;
        margin-bottom: 10px;
    }

    .legal-meta {
        font-size: 13.5px;
        color: var(--text-secondary);
    }

    .legal-card {
        background: var(--surface);
        border: 1px solid var(--border);
        border-radius: var(--radius-lg);
        padding: 40px;
        box-shadow: var(--shadow-sm);
        margin-bottom: 32px;
    }

    .legal-card h2 {
        font-size: 18px;
        font-weight: 800;
        color: var(--primary);
        margin-top: 32px;
        margin-bottom: 14px;
        padding-bottom: 8px;
        border-bottom: 1px solid var(--border-subtle);
        letter-spacing: -0.2px;
    }

    .legal-card h2:first-of-type {
        margin-top: 0;
    }

    .legal-card p {
        font-size: 14.5px;
        color: var(--text-secondary);
        margin-bottom: 16px;
        line-height: 1.7;
    }

    .legal-card ul, .legal-card ol {
        margin-bottom: 18px;
        padding-left: 24px;
    }

    .legal-card li {
        font-size: 14px;
        color: var(--text-secondary);
        margin-bottom: 8px;
        line-height: 1.6;
    }

    .legal-card strong {
        color: var(--text-primary);
        font-weight: 700;
    }

    .highlight-banner {
        background-color: var(--canvas);
        border-left: 4px solid var(--primary);
        border-radius: 4px var(--radius-sm) var(--radius-sm) 4px;
        padding: 16px 20px;
        margin: 20px 0;
    }

    .highlight-banner p {
        margin-bottom: 0;
        font-size: 13.5px;
        color: var(--text-primary);
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
<div class="legal-container">
    <div class="legal-header">
        <span class="badge-pill">Dokumen Hukum Resmi</span>
        <h1 class="legal-title">Kebijakan Privasi (Privacy Policy)</h1>
        <p class="legal-meta">Berlaku Efektif: 15 September 2026 | Terakhir Diperbarui: 17 September 2026</p>
    </div>

    <div class="legal-card">
        <h2>1. Pendahuluan & Ruang Lingkup</h2>
        <p>
            Selamat datang di <strong>Resumer - AI ATS CV Maker, Score Checker & Job Matcher</strong> ("Resumer", "kami", atau "pengembang"). Kami menghargai dan menjunjung tinggi hak privasi digital Anda. Dokumen Kebijakan Privasi ini menjelaskan prinsip pengumpulan, pemrosesan, dan perlindungan informasi pribadi Anda saat menggunakan aplikasi seluler Resumer di Android serta layanan API pada domain <code>resumer.cellanoma.my.id</code>.
        </p>
        <p>
            Dengan mengunduh, mengakses, atau menggunakan aplikasi Resumer, Anda menyatakan telah membaca, memahami, dan menyetujui seluruh ketentuan yang tercantum dalam dokumen ini.
        </p>

        <h2>2. Jaminan Privasi Foto 100% Client-Side (Zero Server Photo Storage)</h2>
        <div class="highlight-banner">
            <p><strong>KOMITMEN PRIVASI MUTLAK:</strong> Foto wajah dan dokumen gambar identitas pribadi Anda <strong>TIDAK PERNAH dikirimkan atau disimpan ke server hosting kami maupun ke pihak ketiga mana pun</strong>.</p>
        </div>
        <p>
            Seluruh proses pemotongan pas foto (<em>cropping</em> rasio 3x4), kompresi ukuran, dan penempatan grafis ke dalam dokumen resume dieksekusi <strong>100% di dalam memori smartphone pengguna secara lokal</strong> menggunakan pustaka Flutter client-side. Server backend kami mencatat beban <strong>0 Byte</strong> untuk foto pengguna, sehingga Anda memiliki kendali penuh atas foto diri Anda.
        </p>

        <h2>3. Kompilasi dan Render PDF di Perangkat Lokal</h2>
        <p>
            Proses perakitan dan render berkas PDF beresolusi tinggi (meliputi tata letak teks, tipografi font eksekutif, dan pas foto) diproses secara mandiri pada perangkat Anda. Kami tidak menyimpan, mengunggah, atau membuat salinan berkas PDF resume Anda di server cloud.
        </p>

        <h2>4. Informasi yang Kami Kumpulkan & Cara Penggunaannya</h2>
        <p>Untuk mendukung sinkronisasi multi-perangkat dan manajemen profil karir, kami memproses jenis data terbatas berikut:</p>
        <ul>
            <li>
                <strong>Data Otentikasi (Google Sign-In OAuth):</strong> Kami menerapkan autentikasi 1-klik berbasis Google OAuth 2.0. Kami menerima Google ID terenkripsi, nama akun, alamat email, dan URL foto profil publik Google Anda. Kami <strong>tidak pernah meminta atau menyimpan kata sandi (password)</strong> Anda.
            </li>
            <li>
                <strong>Data Teks Draf CV:</strong> Informasi riwayat karir berupa teks terstruktur (ringkasan eksekutif, pengalaman kerja, riwayat pendidikan, dan daftar keahlian) disimpan secara aman di database MySQL cloud terenkripsi agar draf CV Anda (hingga 3 variasi profil) tidak hilang saat Anda berganti smartphone.
            </li>
            <li>
                <strong>Pemrosesan Teks AI (Google Gemini):</strong> Ketika Anda menggunakan fitur poles teks, evaluasi Skor ATS, atau Job Matcher, potongan teks deskripsi pekerjaan Anda dikirimkan melalui saluran aman SSL/TLS (HTTPS) ke Google Gemini 2.5 Flash Lite API murni untuk pemrosesan teks dan kalkulasi kata kunci.
            </li>
            <li>
                <strong>Pengenal Perangkat (Device UUID):</strong> Pengenal unik acak perangkat non-pribadi digunakan untuk mengelola jatah kuota wajar harian (maksimal 5 kali request AI per hari).
            </li>
        </ul>

        <h2>5. Monetisasi & Penayangan Iklan (Google AdMob)</h2>
        <p>
            Resumer disediakan 100% gratis dengan dukungan penayangan iklan Google AdMob (Adaptive Banner & Rewarded Video Ads). Kami mengintegrasikan Google User Messaging Platform (UMP) SDK guna mematuhi regulasi privasi global seperti GDPR (Eropa) dan CCPA (California). Google AdMob dapat mengumpulkan identifikasi periklanan anonim perangkat sesuai dengan Kebijakan Layanan Google Play.
        </p>

        <h2>6. Keamanan Data & Standar Enkripsi</h2>
        <p>
            Kami menerapkan standar industri untuk mengamankan data Anda:
        </p>
        <ul>
            <li>Enkripsi transmisi data menggunakan protokol HTTPS / TLS 1.3 terkini.</li>
            <li>Verifikasi keaslian request aplikasi menggunakan signature HMAC SHA-256.</li>
            <li>Perlindungan token sesi stateless melalui Laravel Sanctum.</li>
            <li>Pemisahan folder core sistem di luar direktori web publik server hosting.</li>
        </ul>

        <h2>7. Hak Pengguna & Prosedur Penghapusan Akun (Account Deletion)</h2>
        <p>
            Anda memiliki hak mutlak untuk melihat, memperbarui, maupun menghapus seluruh data Anda kapan saja:
        </p>
        <ul>
            <li>
                <strong>Melalui Aplikasi:</strong> Buka tab <em>Profil</em> di aplikasi Resumer, pilih menu pengaturan, dan klik opsi <em>Hapus Akun & Data</em>.
            </li>
            <li>
                <strong>Melalui Halaman Web Publik:</strong> Anda dapat mengajukan permohonan penghapusan akun kapan saja melalui tautan resmi: <a href="{{ route('account-deletion') }}" style="color: var(--primary); font-weight: 700; text-decoration: underline;">Permintaan Hapus Akun (Delete Account)</a>.
            </li>
        </ul>
        <p>
            Saat penghapusan diproses, seluruh profil pengguna, token otentikasi, ketiga variasi profil CV, dan seluruh riwayat skor ATS akan <strong>dihapus secara permanen dari server database kami</strong> tanpa ada arsip tersisa.
        </p>

        <h2>8. Perubahan Kebijakan Privasi</h2>
        <p>
            Kami dapat memperbarui dokumen Kebijakan Privasi ini dari waktu ke waktu untuk menyesuaikan dengan pembaruan fitur atau regulasi hukum yang berlaku. Setiap perubahan akan dicantumkan pada halaman ini beserta tanggal pembaruan terbarunya.
        </p>

        <h2>9. Kontak Pengembang</h2>
        <p>
            Jika Anda memiliki pertanyaan, saran, atau keluhan terkait kebijakan privasi dan pemrosesan data ini, silakan hubungi tim kami di:
        </p>
        <p style="margin-left: 16px;">
            <strong>Cellanoma Studio</strong><br>
            Email Kontak: <a href="mailto:privacy@cellanoma.my.id" style="color: var(--primary); font-weight: 600;">privacy@cellanoma.my.id</a><br>
            Situs Web: <a href="https://resumer.cellanoma.my.id" style="color: var(--primary); font-weight: 600;">https://resumer.cellanoma.my.id</a>
        </p>
    </div>
</div>
@endsection
