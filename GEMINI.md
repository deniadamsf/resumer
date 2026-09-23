# ATURAN PROYEK RESUMER (AI ATS CV MAKER, SCORE CHECKER & JOB MATCHER)

> **ATURAN MUTLAK (MANDATORY & ALWAYS ENFORCED):**
> 1. Setiap kali akan **membuat**, **mengubah**, **mengevaluasi**, atau **merestrukturisasi** file apa pun di dalam repositori ini, asisten **WAJIB** membaca dan merujuk secara mendalam pada dokumen rancang bangun utama:
>    `d:/StudioProject/RESUMER/rangkuman_konsultasi_aplikasi.md`
> 2. Untuk setiap perancangan, implementasi, dan perbaikan tampilan antarmuka (UI/UX) pada Flutter, asisten **WAJIB SELALU MENGGUNAKAN SKILL `ui-ux-pro-max`** secara ketat dan konsisten.
>
> Seluruh implementasi teknis, keputusan arsitektur, penamaan variabel, alur monetisasi, hingga detail desain UI/UX **HARUS SELARAS 100%** dengan dokumen tersebut tanpa deviasi sepihak.

---

## 1. Pembagian Peran Sistem (Koki vs Piring Saji)
* **Backend Laravel (`resumer.cellanoma.my.id`):**
  * Bertindak sebagai *API Gateway & Reverse Proxy* terisolasi.
  * Menggunakan **Laravel versi terbaru (Laravel 12 / PHP 8.2+)**.
  * Menyimpan dan melindungi Gemini API Key (tidak boleh bocor ke APK).
  * Mengelola kuota harian (maksimal 5x per hari per User/Device UUID, reset pukul 00:00).
  * Rate limiting ketat (`throttle:5,1`) dan proteksi HMAC SHA-256 signature pada header request.
  * Menyimpan data teks CV dan riwayat skor ATS di MySQL hosting (kapasitas mikro ~2-5KB per CV).
  * Seluruh backend Laravel berada di `/home/u731410318/domains/cellanoma.my.id/public_html/resumer/` dengan `.env` berproteksi chmod 600 dan dilindungi `.htaccess`.
* **AI Gemini (Google Gemini 2.5 Flash Lite):**
  * Berperan murni sebagai **"Koki Teks"**.
  * Dilarang keras memproses/menghasilkan layout grafis atau PDF.
  * Wajib mengembalikan output murni JSON berstruktur kaku (`response_mime_type: "application/json"`).
* **Flutter Mobile App:**
  * Berperan sebagai **"Piring Saji & Desainer"**.
  * Render dan ekspor PDF diproses **100% Client-Side di smartphone** (`package:pdf`).
  * Foto profil diproses dan dikompres di memori lokal HP (`image_cropper`, `flutter_image_compress`). **TIDAK PERNAH dikirim ke server backend maupun Gemini API** (0 Byte Server Load).
  * Mengatur *live preview*, switching template instan (Rp0 biaya token).
* **ATURAN MUTLAK KEAMANAN (Zero-Secret-in-Client Policy):**
  * **DILARANG KERAS** menyimpan Gemini API Key, Master Secret, atau kredensial sensitif apa pun di dalam kode Flutter (`.dart`), BuildConfig, maupun file asset `.env` di dalam bundel APK/AAB.
  * File APK sangat mudah di-*decompile* (menggunakan JADX / APKTool / Strings viewer); menaruh `.env` di dalam APK sama dengan membagikan API Key secara publik.
  * Gemini API Key **100% EKSKLUSIF** hanya boleh ada di file `.env` server Laravel di `/home/u731410318/domains/cellanoma.my.id/public_html/resumer/.env`.
  * Aplikasi Flutter hanya boleh mengetahui Base URL publik Laravel (`https://resumer.cellanoma.my.id/api/v1`) dan berkomunikasi via token sesi Laravel Sanctum.

---

## 2. Struktur Autentikasi (OAuth Only)
* Autentikasi aplikasi **Wajib Menggunakan OAuth Saja (Google Sign-In / OAuth Provider)**.
* **DILARANG** membuat form pendaftaran/login email & password manual yang merepotkan user.
* Pengguna masuk dengan 1-klik via Google ID Token / OAuth Provider.
* Backend Laravel memverifikasi ID Token dan menautkan data profil (hingga 3 variasi CV), riwayat skor ATS, serta jatah kuota harian (5x/hari) ke akun pengguna & Device UUID.

---

## 3. Alur Siklus Pengerjaan (Lokal -> Test -> Deploy Online)
* **Pengembangan Lokal Terlebih Dahulu:** Seluruh kode backend dan mobile app dibangun serta diuji coba di lingkungan lokal hingga stabil dan bebas error.
* **Pengetesan Otomatis & Manual:** Memastikan endpoint API, schema JSON, dan UI widget berjalan mulus (`flutter test`, `flutter analyze`).
* **Deploy ke Hosting Online (`resumer.cellanoma.my.id`):**
  * **Production & Laravel Root Directory:** `/home/u731410318/domains/cellanoma.my.id/public_html/resumer/` (seluruh kode backend Laravel: `app/`, `config/`, `routes/`, `database/`, `.env`, `vendor/`, `artisan`, `index.php`, `.htaccess`, dsb. beroperasi langsung di dalam direktori ini).
  * **Database:** MySQL `u731410318_resumer`.
  * **Akses SSH:** Menggunakan alias `ssh -T -n resumer` atau `ssh -T -n hostinger` (Host `153.92.8.198`, Port `65002`, User `u731410318`).
  * **ATURAN EKSEKUSI SSH & DEPLOY:**
    * Selalu deploy file backend ke: `/home/u731410318/domains/cellanoma.my.id/public_html/resumer/` (DILARANG deploy ke folder lain seperti `resumer-core`).
    * Selalu sertakan flag `-T -n` (misal: `ssh -T -n resumer "cd /home/u731410318/domains/cellanoma.my.id/public_html/resumer && php artisan optimize:clear"`) guna menonaktifkan alokasi TTY & stdin agar eksekusi perintah remote di Hostinger berjalan instan (< 1 detik) tanpa pernah *hang*/terhenti.

---

## 4. Standar UI/UX "Quiet Luxury & Bespoke Executive" (UI UX Pro Max)
* Seluruh implementasi antarmuka wajib mematuhi standar skill **`ui-ux-pro-max`** secara menyeluruh.
* **Palet Warna Resmi:**
  * Primary: `Midnight Oxford Navy` (`#0B132B`), `Muted Steel Slate` (`#1C2541`, `#3A506B`), `Subtle Slate Tint` (`#F1F5F9`).
  * Status/Skor ATS: `Deep Forest Pine` (`#065F46` / `#047857` untuk skor 85-100), `Antique Bronze` (`#92400E` / `#B45309` untuk skor 60-84), `Crimson Bordeaux` (`#881337` / `#991B1B` untuk skor <60).
  * Latar & Teks: `Oyster Paper Canvas` (`#F8F9FA`), Card (`#FFFFFF`), Border hairline (`#E2E8F0`), `Text Primary` (`#0A0F1D`), `Text Secondary` (`#64748B`).
  * **Dilarang keras menggunakan warna biru neon atau warna menyala murahan.**
* **Tipografi:**
  * Font utama: **Outfit** (via `google_fonts`).
  * Hierarki: Hero Score (32-40sp, w800), Header Title (18-20sp, w800), Card Title (15-16sp, w700), Body (13-14sp, w400), Helper (11-12sp, w500).
* **Geometri & Ergonomi:**
  * Header bar frosted glass: tinggi `56.0 + topPadding`, blur `BackdropFilter(sigma: 16)`.
  * Card `BorderRadius: 16px`, border `1px #E2E8F0`, subtle shadow.
  * Tombol CTA tinggi `50px - 52px`, `BorderRadius: 14px`, haptic feedback.
* **Proteksi Layar Kecil & Responsif:**
  * Root wajib memasang `MediaQuery.textScalerOf(context).clamp(minScaleFactor: 0.85, maxScaleFactor: 1.15)`.
  * Seluruh badge/tags/skills **WAJIB menggunakan Wrap**, dilarang `Row` kaku.
  * Elemen teks sebaris dalam `Row` wajib dibungkus `Expanded` atau `Flexible` dengan `ellipsis`.
  * Bottom padding formulir/halaman wajib minimal `65px - 80px` agar tidak tertutup AdMob Adaptive Banner atau Floating Bar.
* **Standar Ikonografi Eksekutif (Anti-Icon Murahan):**
  * **DILARANG KERAS** menggunakan icon pensil untuk edit, icon petir untuk kuota/energi, emoji kekanak-kanakan, atau icon warna-warni menyala (kuning amber neon, dsb.) yang membuat aplikasi tampak murahan ala game arcade.
  * **Aksi Edit & Opsi Lanjutan:** Wajib menggunakan tombol titik tiga (`Icons.more_horiz_rounded` atau `Icons.more_vert_rounded`) yang menampilkan menu/modal dengan teks aksi jelas ("Ubah Profil", "Kelola Data").
  * **Indikator Kuota / Metrik:** Wajib menggunakan icon eksekutif minimalis dan elegan (misal `Icons.donut_large_rounded`, `Icons.data_usage_rounded`, atau `Icons.tune_rounded`) dengan palet monokromatik yang tenang.
  * **Warna Icon:** Wajib serasi dan monokromatik mengikuti palet Quiet Luxury (`Midnight Oxford Navy`, `Muted Steel Slate`, atau putih pada tombol). Dilarang menyisipkan warna-warni kontras murahan.
* **Standar Tautan Portofolio & Ikon Media Sosial (6 Platform):**
  * Mendukung 6 platform: LinkedIn, GitHub, Instagram, Facebook, WhatsApp, Website / Portofolio.
  * Di editor: Input opsional berbasis username / nomor via helper cerdas `SocialLinkHelper`.
  * Di Template Non-ATS: Menampilkan **ikon vektor brand tajam** (`pw.SvgImage`) bersanding dengan teks link ringkas, dibungkus `pw.UrlLink` interaktif.
  * Di Template ATS: Menampilkan **teks linear bersih** (`pw.Wrap`) untuk menjamin 100% keterbacaan parser mesin ATS tanpa memicu karakter encoding box (`☒`).
  * Integrasi AI: Terbaca di ATS plain text simulation, ATS Score completeness pillar, dan dikutip pada Paragraf 2 AI Cover Letter.

---

## 5. Lokalisasi & Bahasa (`.tr`)
* Dilarang meletakkan string antarmuka secara *hardcoded* di dalam widget UI.
* Wajib menggunakan format ekstensi `.tr` dengan hierarki bertitik (misal: `common.*`, `form.*`, `ats.*`, `job_match.*`, `quota.*`, `ad.*`).
* Mendukung penuh `id_ID` dan `en_US` dengan *automatic fallback* ke `en_US`.

---

## 6. Alur Monetisasi & Rewarded Ads
* Kuota harian gratis: 5x generate/revisi AI per hari (reset pukul 00:00).
* Rewarded Video Ads dipasangkan pada:
  1. Analisa Skor ATS CV (sebelum laporan feedback muncul).
  2. Generate / 1-Click ATS Auto-Fix (memotong 1 kuota harian).
  3. Job Matcher (sebelum pencocokan kualifikasi).
  4. Ekspor AI Cover Letter.
  5. Download PDF High-Res.
* Graceful Rollback: Kuota 5x harian hanya berkurang jika response API berhasil (HTTP 200).

---

## 7. Standar Arsitektur Bersih & Larangan Spaghetti Code (Separation of Concerns)
* **DILARANG KERAS membuat Spaghetti Code / God File** (menumpuk UI, state management, query database, dan API call dalam satu file raksasa).
* **Aturan Kode Flutter Mobile:**
  * Wajib memisahkan layer secara tegas:
    * `models/`: Struktur data immutable & JSON serialization.
    * `services/` & `repositories/`: Komunikasi API HTTP & penyimpanan lokal (Hive/Secure Storage).
    * `controllers/` / `state/`: Pengelolaan state murni, terisolasi dari widget UI.
    * `views/` & `widgets/`: Antarmuka visual yang dipecah menjadi komponen modular kecil (maksimal 150–200 baris per file widget).
    * `templates/`: Setiap template PDF memiliki file independen (`asian_ats_template.dart`, `western_ats_template.dart`).
* **Aturan Kode Backend Laravel 12:**
  * **Larangan Fat Controller:** Controller hanya bertugas menerima request, memanggil Service/Action, dan mengembalikan Resource JSON.
  * **Form Requests:** Seluruh aturan validasi request wajib dipisah ke kelas Form Request mandiri (`app/Http/Requests/`).
  * **Service Layer:** Seluruh logika bisnis (panggilan Gemini API, kalkulasi skor ATS, manajemen kuota) wajib diisolasi di kelas Service (`app/Services/`).
  * **API Resources:** Seluruh format respons JSON wajib melalui kelas API Resource (`app/Http/Resources/`) demi konsistensi output data.

