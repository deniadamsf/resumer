@extends('layouts.app')

@section('title', 'Sanggahan (Disclaimer) - Resumer')

@section('meta_description', 'Sanggahan resmi aplikasi Resumer mengenai sifat prediktif skor ATS, asistensi AI generative, tanggung jawab data pengguna, dan merek dagang pihak ketiga.')

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

    .legal-card ul {
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

    .notice-box {
        background-color: var(--score-mid-bg);
        border: 1px solid #FCD34D;
        border-radius: var(--radius-md);
        padding: 18px 22px;
        margin: 24px 0;
    }

    .notice-box p {
        color: var(--score-mid);
        font-size: 13.5px;
        font-weight: 500;
        margin-bottom: 0;
        line-height: 1.6;
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
        <span class="badge-pill">Sanggahan Resmi</span>
        <h1 class="legal-title">Sanggahan & Batasan Tanggung Jawab</h1>
        <p class="legal-meta">Terakhir Diperbarui: 17 September 2026 | Resumer Platform</p>
    </div>

    <div class="legal-card">
        <div class="notice-box">
            <p>
                <strong>PERHATIAN PENTING:</strong> Layanan Resumer dirancang sebagai alat bantu (tool) digital dan panduan edukatif penulisan karir berbasis kecerdasan buatan. Kami tidak bertindak sebagai agensi penyalur tenaga kerja resmi dan tidak menjamin kelulusan kerja pada perusahaan mana pun.
            </p>
        </div>

        <h2>1. Sifat Prediktif Skor ATS & Keputusan Rekrutmen</h2>
        <p>
            Skor ATS (rentang nilai 0 – 100) serta persentase kecocokan kualifikasi yang disajikan dalam aplikasi Resumer merupakan <strong>simulasi estimasi algoritmik</strong> berdasarkan pedoman umum sistem penyaringan resume (Applicant Tracking System) modern.
        </p>
        <p>
            Perolehan skor tinggi (misalnya 90–98+) di dalam aplikasi Resumer <strong>tidak menjamin</strong> bahwa Anda akan otomatis dipanggil wawancara, lolos tahap seleksi administratif, atau diterima bekerja di perusahaan yang Anda tuju. Setiap perusahaan, perekrut, dan tim HRD memiliki kriteria subjektif, bobot penilaian khusus, dan konfigurasi sistem internal yang berada di luar kendali kami.
        </p>

        <h2>2. Tanggung Jawab Pengguna atas Kebenaran Konten</h2>
        <p>
            Pengguna memikul tanggung jawab penuh secara hukum dan moral terhadap keakuratan, kebenaran, dan keaslian seluruh data yang dimasukkan ke dalam resume, termasuk namun tidak terbatas pada:
        </p>
        <ul>
            <li>Riwayat jabatan dan periode pengalaman kerja.</li>
            <li>Nama institusi pendidikan, gelar akademik, dan nilai kelulusan.</li>
            <li>Kepemilikan sertifikasi profesi dan lisensi resmi.</li>
            <li>Pencapaian angka atau metrik kuantitatif proyek.</li>
        </ul>
        <p>
            Resumer tidak melakukan verifikasi latar belakang (<em>background check</em>) independen terhadap klaim karir yang Anda masukkan. Pencantuman data palsu atau klaim yang menyesatkan sepenuhnya menjadi konsekuensi dan tanggung jawab hukum pengguna yang bersangkutan.
        </p>

        <h2>3. Sanggahan Pemrosesan AI Generatif (Generative AI)</h2>
        <p>
            Seluruh saran perbaikan kata kunci, penulisan ringkasan eksekutif (<em>executive summary</em>), formula Google XYZ, dan draf surat lamaran kerja dihasilkan dengan bantuan teknologi kecerdasan buatan Google Gemini 2.5 Flash Lite.
        </p>
        <p>
            Meskipun model AI telah dikalibrasi secara ketat untuk menghasilkan teks formal standar HRD korporat, keluaran AI sewaktu-waktu dapat memuat ketidaksesuaian terminologi atau asumsi metrik. Anda sangat disarankan untuk meninjau, menyunting, dan memastikan kesesuaian setiap draf teks sebelum mengirimkannya ke pihak perusahaan.
        </p>

        <h2>4. Sanggahan Merek Dagang & Pihak Ketiga (Third-Party Trademarks)</h2>
        <p>
            Nama-nama sistem piranti lunak, platform rekrutmen, dan merek dagang pihak ketiga yang disebutkan dalam aplikasi atau situs web Resumer (seperti <strong>Workday</strong>, <strong>Taleo</strong>, <strong>Greenhouse</strong>, <strong>Lever</strong>, <strong>SAP SuccessFactors</strong>, <strong>Google</strong>, <strong>LinkedIn</strong>, <strong>JobStreet</strong>, <strong>Glints</strong>, dan sejenisnya) merupakan hak milik dan merek dagang terdaftar dari masing-masing pemilik resminya.
        </p>
        <p>
            Penyebutan nama merek-merek tersebut dilakukan semata-mata untuk keperluan <strong>identifikasi deskriptif teknis, kompatibilitas standar format berkas, dan konteks industri</strong>. Penggunaan nama-nama tersebut sama sekali tidak menunjukkan adanya sponsor, kemitraan resmi, afiliasi dagang, maupun dukungan dari pemilik merek dagang kepada Resumer.
        </p>

        <h2>5. Batasan Tanggung Jawab Hukum (Limitation of Liability)</h2>
        <p>
            Sepanjang diizinkan oleh peraturan perundang-undangan yang berlaku, Resumer beserta pengembang (Cellanoma Studio) tidak bertanggung jawab atas segala bentuk kerugian langsung, kerugian tidak langsung, kehilangan peluang kerja, atau kerugian finansial yang dialami pengguna sehubungan dengan:
        </p>
        <ul>
            <li>Penolakan lamaran kerja oleh pihak perekrut atau perusahaan mana pun.</li>
            <li>Ketidakcocokan interpretasi format oleh sistem ATS tertentu yang menggunakan konfigurasi non-standar.</li>
            <li>Keterlambatan atau kendala transmisi data akibat gangguan koneksi internet pengguna.</li>
        </ul>

        <h2>6. Kontak Bantuan</h2>
        <p>
            Jika Anda membutuhkan klarifikasi lebih lanjut mengenai sanggahan ini, Anda dapat menghubungi kami melalui surat elektronik di <a href="mailto:privacy@cellanoma.my.id" style="color: var(--primary); font-weight: 600;">privacy@cellanoma.my.id</a>.
        </p>
    </div>
</div>
@endsection
