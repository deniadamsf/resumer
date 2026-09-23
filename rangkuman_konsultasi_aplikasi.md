# Rangkuman Konsultasi Pengembangan Aplikasi & Monetisasi AI

Dokumen ini merangkum perjalanan diskusi mengenai strategi pengembangan aplikasi, manajemen risiko pemblokiran Google Play Store, serta perencanaan produk aplikasi pembuat CV otomatis berbasis AI (**Resumer**).

---

## 1. Analisis Risiko Kebijakan Google Play Store

### Konten UGC (User Generated Content) Horor & Vulgar
* **Risiko Pemblokiran:** **Sangat Tinggi**. Google membebankan tanggung jawab konten sepenuhnya kepada developer, bukan penulis.
* **Jenis Pelanggaran:** 
  * Konten Vulgar melanggar kebijakan *Sexual Explicit Content* (berpotensi *banned* instan).
  * Konten Horor ekstrem/sadis melanggar kebijakan *Violence & Shocking Content*.
* **Konsekuensi:** Penghapusan aplikasi hingga pemblokiran permanen akun developer (*Terminated Account*).

### Sistem Poin dari Views Artikel (Ditukar Uang/Pulsa)
* **Risiko Pemblokiran:** **Sangat Tinggi**.
* **Jenis Pelanggaran:** 
  * *Ad Fraud* / Manipulasi Trafik: Pengguna memanipulasi klik/tayangan iklan demi poin, memicu pemblokiran akun Google AdMob.
  * Kebijakan Imbalan: Google melarang skema manipulasi ekosistem yang menyesatkan.

### Aplikasi Kesehatan Mental / Konsultasi Psikolog (Format Halodoc)
* **Aturan Akun:** **Wajib Akun Perusahaan (Organization Account)**. Tidak bisa dirilis menggunakan akun pribadi (*Personal Account*).
* **Persyaratan Tambahan:** Verifikasi legalitas tenaga medis (SIPP/STR), privasi data klinis yang super ketat, dan kewajiban menggunakan *Google Play Billing System* untuk pemotongan biaya di dalam aplikasi.

---

## 2. Evaluasi Portofolio Aplikasi Saat Ini

1. **Smart Tes IQ & Persona Tes Kepribadian (Freemium):** Model bisnis sudah tepat. Tantangannya ada pada volume trafik harian. Disarankan memaksimalkan *Rewarded Ads* atau *Interstitial Ads* di sela perpindahan soal untuk mendongkrak pendapatan harian.
2. **Zenvi POS (Sistem Langganan Rp59rb & Rp149rb/bulan):** Secara fitur (semi-offline, multi-branch ERP) sudah sangat kuat.
   * **Rekomendasi Utama:** **Jangan diiklankan secara berbayar dulu sebelum fitur thermal printer dites secara langsung**.
   * Pemilik toko sangat sensitif dengan kestabilan cetak struk (protokol ESC/POS via Bluetooth). Bug pada printer termal di awal rilis berisiko memicu ulasan bintang 1 yang merusak performa iklan.

---

## 3. Ide Bisnis Baru yang Potensial & Minim Risiko
* **Afiliasi E-Commerce (Shopee/TikTok Shop):** Memanfaatkan trafik konten untuk komisi produk digital/fisik. Risiko blokir hampir nol.
* **Telegram Mini Apps (TMAs):** Berjalan di dalam ekosistem Telegram. Sangat viral, mudah terintegrasi dengan transaksi mikro/kripto (TON), dan bebas dari kurasi ketat Play Store.
* **Mikro-SaaS Khusus E-Commerce Lokal:** Aplikasi utilitas spesifik (misal: otomatisasi cetak resi thermal via API marketplace atau kalkulator profit bersih). Pemilik toko online cenderung lebih royal belanja *tools* bisnis dibanding pasar kasir umum.

---

## 4. Proyek Utama: Blueprint Lengkap Aplikasi "Resumer" (AI ATS CV Maker, Score Checker & Job Matcher)

**Resumer** adalah aplikasi cerdas pembuat CV otomatis berstandar ATS (*Applicant Tracking System*), penganalisis skor CV, dan pencocok kualifikasi lowongan kerja berbasis AI. Mengusung model bisnis **100% gratis** yang didukung monetisasi iklan berimbalan (*Rewarded Ads*) dengan batasan kuota harian.

---

### A. Spesifikasi Produk & Nilai Jual (Value Proposition):

* **Nama Aplikasi:** **Resumer**
* **Strategi Nama Play Store (ASO):**
  * **Toko Indonesia:** `Resumer - Pembuat CV ATS, Cek Skor & Loker AI Gratis`
  * **Toko Global:** `Resumer - Free AI ATS CV Maker, Score & Job Matcher`
* **Model Bisnis:** 100% Gratis dengan Monetisasi Iklan (*Ad-Supported Freemium*).
* **Sistem Autentikasi:** **OAuth Only (1-Tap Google Sign-In & Apple Sign-In)**. 
  * Menghilangkan 100% pendaftaran email/password manual.
  * Tanpa biaya email server OTP (Rp0 SMTP cost).
  * Menjamin draf CV dan riwayat skor ATS tetap aman tersinkronisasi saat pengguna berganti smartphone.
* **Batasan Kuota Harian:**
  * Maksimal **5x request generate/revisi AI per hari per akun** (terikat pada ID Akun Google terverifikasi + proteksi Device ID).
  * Kuota di-*reset* otomatis setiap pukul 00:00 (tengah malam).
  * Masing-masing request AI dipasangkan dengan tontonan *Rewarded Video Ad*.
* **Strategi Multi-Bahasa & Dual Target Pasar:**
  * **Pasar Asia (Indonesia, Singapura, Malaysia, dll.):** Memerlukan format **Asian ATS Standard** (struktur ATS ramah mesin namun memiliki slot foto formal profesional di header terisolasi, skor ATS tetap tinggi 85–95).
  * **Pasar Global/Barat (AS, Eropa):** Memerlukan format **Western Strict ATS** tanpa foto demi kepatuhan regulasi anti-bias tenaga kerja, sekaligus mendongkrak **eCPM iklan 5–10x lipat**.
* **Mesin AI:** **Gemini 2.5 Flash Lite** (Native multimodal, respons super cepat 1–3 detik, akurat dalam format JSON kaku, dan biaya per token paling hemat di dunia).

---

### B. Fitur Utama Resumer:

1. **Pembuat CV ATS Otomatis (AI CV Generator):**
   * Menyusun ringkasan profesional (*executive summary*), deskripsi pengalaman kerja dengan kata kerja aksi (*action verbs*) dan metrik capaian terukur (formula Google XYZ), riwayat pendidikan, serta keahlian teknis/soft skills.
   * Format konten disesuaikan otomatis dengan standar seleksi sistem ATS HRD modern.
2. **Sistem Pembacaan & Hitung Skor ATS (ATS Score & Quality Checker):**
   * **Wajib Menonton Iklan (Rewarded Ad):** Setiap pengguna ingin menganalisis atau membaca skor file CV (baik CV yang dibuat di aplikasi maupun file PDF/gambar CV lama yang diunggah), pengguna **wajib menonton 1 Rewarded Video Ad** sebelum hasil analisis ditampilkan.
   * Menganalisis kualitas CV dengan output **Skor 0 – 100**.
   * Parameter penilaian:
     * *Keyword & Industry Match* (Kesesuaian kata kunci posisi pekerjaan).
     * *Impact & Action Verbs* (Tingkat penggunaan kata kerja aktif dan pencapaian kuantitatif, termasuk pada riwayat pengalaman dan deskripsi proyek).
     * *Format & ATS Readability* (Keterbacaan tata letak oleh parser ATS).
     * *Completeness* (Kelengkapan data kontak, riwayat pendidikan, keahlian, sertifikasi, dan portofolio proyek).
   * Memberikan *Actionable Feedback* (poin-poin rekomendasi perbaikan konkret, termasuk saran formula XYZ untuk seksi pengalaman dan proyek).
3. **Jaminan Skor Tinggi Bawaan (Self-Calibrated Generation Engine):**
   * Prompt AI Gemini dikalibrasi secara langsung agar selaras 100% dengan algoritma ATS Checker di dalam aplikasi.
   * **Hasil:** CV yang dihasilkan oleh aplikasi Resumer **dijamin langsung memperoleh skor sangat tinggi (90 – 98+)** ketika diuji menggunakan fitur Cek Skor ATS aplikasi ini. Memberikan kepuasan instan (*instant user satisfaction*) dan membangun reputasi aplikasi yang sangat kuat.
4. **Fitur Perbaikan Otomatis AI (1-Click ATS Auto-Fix):**
   * Jika pengguna mengunggah CV lama atau mengetik data yang menghasilkan skor rendah/sedang (misal skor 50–75):
   * Sistem menyediakan tombol sakti: **"Perbaiki Otomatis dengan AI"**.
   * Setelah menonton *Rewarded Video Ad* (menggunakan 1 jatah kuota AI), Gemini otomatis merombak kalimat pasif menjadi aktif, menyisipkan estimasi metrik/persentase dampak kerja, dan menyelaraskan kata kunci ATS pada ringkasan, riwayat kerja, keahlian, serta **deskripsi proyek** (dengan aturan ketat anti-halusinasi: jika seksi proyek/sertifikasi kosong, AI tidak boleh mengarang proyek fiktif).
   * Skor CV langsung melonjak tinggi (misal dari 65 menjadi 95+) dalam hitungan detik.
5. **Fitur "Job Matcher" (Pencocok CV dengan Lowongan Kerja) — *Tanpa Tempel Link*:**
   * **Menghilangkan Tempel Link (URL):** Ditiadakan karena situs loker besar (Glints, LinkedIn, JobStreet) memblokir request cURL/scraping dengan Cloudflare WAF dan menggunakan rendering JavaScript (SPA).
   * **2 Pilihan Input Anti-Gagal:**
     1. **Unggah Screenshot Loker:** Pengguna mengunggah tangkapan layar poster lowongan/kualifikasi dari HP. Gemini membaca gambar via *multimodal OCR* secara instan.
     2. **Salin-Tempel Teks Loker:** Pengguna menempel teks syarat kualifikasi secara langsung.
   * **Hasil Analisis:** Menampilkan **Job Match Score (%)**, daftar kata kunci yang cocok vs hilang, serta tombol **"Sesuaikan CV dengan Loker Ini"** (AI otomatis menyisipkan kata kunci dan teknologi loker ke keahlian, ringkasan, riwayat kerja, dan deskripsi proyek pengguna dengan imbalan menonton Rewarded Ad).
6. **Multi-Profil CV (Satu Akun, Banyak Variasi CV):**
   * Pengguna dapat menyimpan hingga **3 profil CV berbeda** (misal: Versi Administrasi, Versi Digital Marketing, Versi IT Support) di database MySQL hosting.
   * Pengguna dapat beralih (*switch*) profil kapan saja tanpa takut data tertimpa atau hilang.
7. **Mode Simulasi Mesin ATS (Plain Text Viewer):**
   * Tombol *toggle*: *"Lihat CV Versi Robot ATS"*.
   * Menampilkan teks CV dalam format linier tanpa grafis, membuktikan secara transparan kepada pengguna bahwa teks CV mereka terbaca runtut 100% oleh sistem parser HRD (Workday, Taleo, Greenhouse).
8. **Smart Import CV Lama (Multimodal Extraction):**
   * Pengguna dapat mengunggah file CV lama (PDF atau foto dokumen). Data diekstraksi otomatis menjadi format isian formulir digital tanpa mengetik ulang dari awal.
9. **Sistem Kolom Isian Modular (Toggle ON/OFF Dinamis):**
   * Pengguna bebas mengaktifkan/menonaktifkan seksi isian CV sesuai kebutuhan:
      * `[Wajib / Default ON]` Informasi Pribadi & Kontak:
        * Kolom Pokok: Nama Lengkap, Jabatan Target, Email, Nomor Telepon/WA, Lokasi (Kota, Negara).
        * Kolom Tautan & Portofolio Digital (Opsional - Input Cukup Username/Handle):
          * **LinkedIn, GitHub, Instagram, Facebook, WhatsApp, Website / Portofolio**.
          * **Normalisasi Cerdas (`SocialLinkHelper`):** Sistem otomatis membersihkan simbol `@`, protokol `http://`/`https://`, dan nama domain jika pengguna menempelkan link penuh (mencegah bug link ganda). Untuk WhatsApp lokal (`0812...`), dikonversi otomatis ke nomor internasional (`62812...`).
          * **Interactive Hyperlinks di PDF (`pw.UrlLink`):** Seluruh tautan di file PDF dapat diklik langsung oleh HRD untuk membuka profil LinkedIn, repositori GitHub, chat WhatsApp, atau website portofolio kandidat.
          * **Pemisahan Desain ATS vs Non-ATS (Golden Rule Industri):**
            * **Template Non-ATS (11 Template Visual):** Menampilkan **ikon vektor brand tajam** (`pw.SvgImage`) bersanding dengan teks ringkas/handle.
            * **Template ATS (3 Template Standar Mesin):** Menampilkan tautan sebagai **teks linear bersih** (`pw.Wrap`) guna menjamin 100% kompatibilitas mesin ATS korporat (*Taleo, Workday*) tanpa risiko missing glyph box (`☒`).
          * **Integrasi Menyeluruh dengan AI Gemini:**
            * *ATS Score Checker:* Menilai pilar *Completeness* kontak dan portofolio profesional kandidat.
            * *AI Cover Letter:* Paragraf 2 secara cerdas merujuk keberadaan repositori GitHub / website portofolio kandidat sebagai bukti kompetensi nyata.
            * *Auto-Fix & Job Matcher:* Menjaga keaslian tautan tanpa fabrikasi/halusinasi akun fiktif.
     * `[Toggle ON/OFF]` Ringkasan Profil Profesional (*Executive Summary*)
     * `[Toggle ON/OFF]` Riwayat Pengalaman Kerja (*Work Experience*)
     * `[Toggle ON/OFF]` Riwayat Pendidikan (*Education*)
     * `[Toggle ON/OFF]` Keahlian Teknis & Soft Skills (*Skills*)
     * `[Toggle ON/OFF]` Foto Profil (*Profile Photo*) - Default: OFF (atau ON untuk mode Asian ATS)
     * `[Toggle ON/OFF]` Sertifikasi & Pelatihan (*Certifications*)
     * `[Toggle ON/OFF]` Proyek / Portofolio (*Projects*):
       * Kolom Isian: **Nama Proyek** (*Project Name*), **Peran / Tech Stack** (*Role / Technologies*), **Tanggal Mulai** (*Start Date*: Bulan & Tahun), **Tanggal Selesai** (*End Date*: Bulan & Tahun) dipadu opsi centang *"Masih Berjalan / Aktif"* ($\rightarrow$ "Sekarang" / "Present"), serta **Deskripsi Proyek** (*multiline* berfokus capaian formula Google XYZ / STAR).
       * Terintegrasi 100% pada render Template PDF ATS/Kreatif, Cek Skor ATS, Auto-Fix AI, Job Matcher, dan Cover Letter.
     * `[Toggle ON/OFF]` Pengalaman Organisasi / Relawan (*Volunteer & Organization*)
     * `[Toggle ON/OFF]` Penguasaan Bahasa (*Languages*)
     * `[Toggle ON/OFF]` Penghargaan / Prestasi (*Awards & Honors*)
   * Seksi yang dinonaktifkan **tidak akan diproses oleh Gemini API** (menghemat token) dan **tidak dicetak pada file PDF**.
10. **Validasi Pra-Generate AI (Filter Kelayakan Data):**
    * Syarat Minimal: Wajib mengisi kolom inti (Nama, Kontak, min. 1 Riwayat Kerja/Pendidikan, min. 3 Keahlian). Proyek bersifat opsional sebagai nilai tambah portofolio.
    * Jika kolom inti masih kosong, tombol *Generate AI* terkunci (*disabled*) untuk melindungi pengguna dari pemborosan kuota harian.
11. **Pilihan Kategori Template CV:**
    * **Template Asian ATS Standard (Favorit Pasar Asia):** Tata letak linear ramah mesin ATS dengan slot foto formal di header terisolasi. Skor ATS tetap tinggi (85–95).
    * **Template Western Strict ATS (Global Minimalist):** Format 1 kolom hitam-putih murni tanpa foto, skor ATS sempurna (95–100).
    * **Template Modern Kreatif Berwarna:** Dilengkapi banner peringatan visual bahwa format berwarna dapat menurunkan skor pada mesin ATS korporat (-10 hingga -25 poin).

---

### C. Arsitektur Teknis: Backend Laravel di Shared Hosting (Zero-Cost, OAuth Only & Anti-Crash)

Penerapan backend Laravel di lingkungan **Shared Hosting** dirancang secara ketat agar tidak membebani RAM/CPU server, kuota disk tetap aman, otentikasi zero-maintenance, dan API Key terlindungi:

```
[Pengguna di Mobile App (Flutter)]
      │
      ├─ 1. [OAuth Only] 1-Tap Google Sign-In / Apple Sign-In
      │     └─ Kirim idToken ke Laravel -> Return Sanctum Bearer Token
      │
      ├─ 2. Isi Form / Screenshot Loker / Cek Skor ATS
      ├─ 3. Tonton Rewarded Ad (Jatah 5x per hari per Akun Google)
      │
      ▼
[API Backend Laravel (Shared Hosting)]
      │  ├─ Validasi Sanctum Token & Kuota Harian Akun (MySQL)
      │  ├─ Sembunyikan Gemini API Key (Aman dari decompile APK)
      │  └─ Request ke Google Gemini API (Multimodal / JSON format)
      ▼
[Google Gemini 2.5 Flash Lite API]
      │  └─ Output data murni JSON struktur CV / Breakdown Skor ATS
      ▼
[API Backend Laravel (Shared Hosting)]
      │  ├─ Simpan Teks CV & Riwayat Skor ke MySQL (Terikat User ID)
      │  └─ Meneruskan JSON ke Mobile App
      ▼
[Mobile App (Flutter) di Smartphone Pengguna]
      ├─ Menampilkan Live Preview & Hasil Skor ATS
      ├─ [Client-Side] Render & Generate File PDF Langsung di Device
      └─ Tonton Rewarded Ad -> Download / Share PDF
```

#### 1. Struktur Autentikasi "OAuth Only" (1-Tap Google Sign-In via Laravel Sanctum):
* **Bebas Form Registrasi Manual:** Menghilangkan pendaftaran email/password konvensional, fitur lupa password, dan verifikasi email OTP.
* **Keunggulan untuk Shared Hosting:**
  1. **Rp0 Biaya Email Server (Zero SMTP Load):** Shared hosting membatasi kuota pengiriman email per jam/hari dan IP-nya sering masuk folder spam. Dengan OAuth, sistem **TIDAK PERLU** mengirim email aktivasi atau kode OTP sama sekali.
  2. **Keamanan Kredensial 100%:** Server backend tidak menyimpan hash password pengguna di database (0% risiko kebocoran password pengguna).
  3. **Sinkronisasi Multi-Device yang Sah:** Seluruh draf CV, profil ganda, dan riwayat skor ATS tersimpan di MySQL terikat dengan `user_id` Akun Google. Pengguna dapat berganti smartphone kapan saja dan datanya langsung tersinkronisasi otomatis.
  4. **Anti-Bypass Kuota Harian:** Pengguna tidak dapat mereset kuota harian 5x hanya dengan membersihkan data aplikasi (*clear storage*) atau menginstal ulang APK, karena pencatatan kuota terikat pada ID Akun Google yang terverifikasi di server.
* **Alur Teknis OAuth Stateless:**
  1. Aplikasi Flutter memanggil SDK resmi `google_sign_in` $\rightarrow$ Pengguna memilih akun Google $\rightarrow$ Google mengembalikan `idToken` (JWT terenkripsi).
  2. Flutter mengirim `idToken` ke endpoint Laravel: `POST /api/v1/auth/oauth/google`.
  3. Laravel memverifikasi keaslian token ke Google OAuth API (mengambil Google ID, Nama, Email terverifikasi, dan Foto Avatar).
  4. Laravel membuat atau memperbarui data di tabel `users`, lalu menerbitkan **Laravel Sanctum Bearer Token**.
  5. Flutter menyimpan token di memori aman perangkat (`flutter_secure_storage`) dan menyertakannya pada header `Authorization: Bearer <token>` di setiap request API berikutnya.

#### 2. Pembagian Tugas Tegas: "Analogi Koki dan Piring Saji"
* **Peran AI Gemini (Hanya Sebagai "Koki" Teks):**
  * Gemini **TIDAK BISA dan TIDAK BOLEH** menata desain PDF atau menempelkan gambar foto.
  * Gemini hanya bertugas merangkai kalimat profesional dan mengembalikan **JSON data terstruktur murni** (`response_mime_type: "application/json"`).
* **Peran Aplikasi Flutter (Sebagai "Piring Saji & Desainer"):**
  * Flutter memegang cetakan template desain yang sudah dikodekan secara matematis (`package:pdf`).
  * Flutter mengambil teks dari JSON Gemini, mengambil foto dari memori lokal HP, lalu merakitnya menjadi file PDF *pixel-perfect*.
  * **Manfaat:** Pengguna bisa beralih template seketika (0.1 detik) tanpa memanggil ulang AI Gemini (Rp0 token tambahan).

#### 3. Aturan Penanganan Foto Profil (Zero Server Cost):
* **Pemrosesan 100% Client-Side:** Pemilihan, pemotongan (*crop* pas foto 3x4), dan kompresi foto diproses langsung di HP pengguna via Flutter (`image_cropper` & `flutter_image_compress`).
* **Privasi & Nol Beban Hosting:** File foto **TIDAK PERNAH dikirim ke server Laravel maupun Gemini**.
* **Beban Server:** **0 Byte Storage, 0 Byte Bandwidth, 0% CPU Server**.

#### 4. Penyimpanan Teks Terpusat di Database MySQL (Tersinkronisasi Cloud):
* Seluruh teks profil, status toggle kolom, teks hasil pemolesan AI, riwayat skor ATS, dan multi-profil tersimpan rapi di database MySQL shared hosting via Laravel yang terikat dengan **`user_id` Akun Google**.
* **Ultra-Ringan:** 1 berkas CV teks lengkap hanya membutuhkan **~2KB – 5KB**. Sebanyak 10.000 pengguna hanya memakan **~30MB – 50MB** storage hosting.
* Pengguna bisa membuka kembali CV lama kapan saja secara instan dari perangkat mana pun dengan 0 biaya token AI.

#### 5. Sistem Pembatasan & Proteksi Proxy Gemini API (API Gateway):
* Laravel bertindak sebagai gerbang terisolasi (*Reverse Proxy*). Gemini API **TIDAK PERNAH** dihubungi langsung dari HP pengguna.
* **Larangan Keras API Key & File `.env` di APK (Zero-Secret-in-Client Policy):**
  * **DILARANG KERAS** menyimpan Gemini API Key secara hardcoded di kode Flutter (`.dart`), BuildConfig, maupun membundle file `.env` di folder asset APK.
  * File APK/AAB sangat mudah di-*reverse engineer* / di-*decompile* (menggunakan JADX, APKTool, atau perintah `strings`). Menyimpan file `.env` di dalam APK sama saja dengan membagikan Gemini API Key secara gratis ke publik.
  * Gemini API Key **100% EKSKLUSIF** hanya tersimpan di file `.env` server Laravel di `/home/u731410318/domains/cellanoma.my.id/public_html/resumer/.env` (diproteksi permission ketat chmod 600 dan diblokir oleh web server `.htaccess`).
  * Aplikasi Flutter hanya mengetahui Base URL API Laravel publik (`https://resumer.cellanoma.my.id/api/v1`) dan hanya berkomunikasi via token sesi Laravel Sanctum.
* **Rate Limiting Berlapis:** Middleware Laravel membatasi `throttle:5,1` per menit dan batas maksimal 5 request per hari per Akun Google terdaftar.
* **Payload & Length Guard:** Batasan panjang karakter (maks 3.000 karakter per riwayat kerja) dan sanitasi input guna mencegah *prompt injection*.
* **HMAC Request Signature:** Setiap request dari aplikasi Flutter wajib menyertakan header signature terenkripsi (HMAC SHA-256) agar API Laravel kebal dari tembakan bot luar atau tools seperti Postman.

#### 6. Keamanan Deploy cPanel/Hostinger:
* Seluruh instalasi backend Laravel aktif berada di `/home/u731410318/domains/cellanoma.my.id/public_html/resumer/`. File `.env` diproteksi chmod 600 dan dicegah akses langsungnya oleh `.htaccess`.
* Background tasks menggunakan **Hostinger/cPanel Cron Job** (`php artisan schedule:run` per menit) untuk reset kuota harian pukul 00:00 dan pembersihan berkas temporary.

---

### D. Strategi Monetisasi & Penempatan Iklan (Ad Placements):

1. **Adaptive Banner (Bawah Layar):** Pendapatan pasif konstan selama pengguna mengetik data atau meninjau preview (diberi safe margin bawah 65px).
2. **Rewarded Video Ad 1 (Trigger Analisa Skor CV / Pembacaan File Upload):**
   * Wajib ditonton sebelum sistem menampilkan laporan skor dan feedback CV lama.
3. **Rewarded Video Ad 2 (Trigger Generate AI Baru / 1-Click ATS Auto-Fix):**
   * Ditampilkan sebelum request AI diproses ke backend (menghabiskan 1 jatah kuota harian dari total 5).
4. **Rewarded Video Ad 3 (Trigger Fitur Job Matcher):**
   * Ditampilkan sebelum AI membandingkan CV pengguna dengan screenshot/teks lowongan kerja.
5. **Rewarded Video Ad 4 (Trigger AI Cover Letter):**
   * Ditampilkan sebelum pengguna menyalin/mengunduh surat lamaran kerja hasil generate AI.
6. **Rewarded Video Ad 5 (Trigger Download PDF High-Res):**
   * Ditampilkan tepat setelah pengguna melihat *live preview* CV dan hendak mengunduh/membagikan file PDF akhir.
7. **Interstitial Ad (Iklan Transisi):** Ditampilkan dengan batas frekuensi ketat (*frequency capping*, maks 1x per 3–5 menit) saat berpindah menu antar modul.

---

### E. Analisis Biaya & Rasio Keuntungan (Unit Economics):

* **Biaya API Gemini 2.5 Flash Lite:** ~$0.075 per 1 juta input token (sekitar Rp5 – Rp15 per request CV).
* **Estimasi Pendapatan Iklan per Pengguna Aktif Harian (Kombinasi Rewarded Ads + Banner):**
  * Pasar Indonesia: Rp800 – Rp2.000 per pengguna aktif harian.
  * Pasar Global (US/SG/EU): Rp5.000 – Rp15.000 per pengguna aktif harian.
* **Biaya Server:** Menggunakan paket shared hosting yang sudah ada (biaya tetap minimal, Rp0 biaya tambahan server per user).
* **Estimasi Margin Keuntungan:** **85% – 95%** laba bersih dari pendapatan iklan.

---

### F. Standar UI/UX Responsif & Proteksi Layar Kecil (Anti-Tabrakan Bubble / Teks):

Untuk mencegah teks dan komponen visual saling bertabrakan atau meletup keluar layar (*RenderFlex overflow*) pada smartphone berlayar sempit (320px–360px width) maupun perangkat dengan pengaturan font sistem yang dibesarkan:

1. **Dynamic Text Scaling Clamping (Anti-Teks Meletup):**
   * Membatasi faktor pembesaran font di tingkat root aplikasi agar layout tidak pecah:
     ```dart
     MediaQuery(
       data: MediaQuery.of(context).copyWith(
         textScaler: MediaQuery.textScalerOf(context).clamp(
           minScaleFactor: 0.85,
           maxScaleFactor: 1.15, // Membatasi pembesaran maksimal 115%
         ),
       ),
       child: child,
     )
     ```
2. **Komponen Bubble, Tag, dan Badge Wajib Menggunakan `Wrap`:**
   * Untuk daftar *skills*, kata kunci ATS, atau status badge, **DILARANG menggunakan widget `Row` kaku**.
   * Wajib menggunakan `Wrap(spacing: 8.0, runSpacing: 6.0, children: [...])` agar elemen yang melebihi lebar layar otomatis turun rapi ke baris baru.
3. **Flexible & Auto-Ellipsis pada Komponen Sebaris:**
   * Di dalam `Row` yang memuat teks dan icon/badge (misal judul jabatan berdampingan dengan tahun kerja), teks wajib dibungkus `Expanded` atau `Flexible` dengan `overflow: TextOverflow.ellipsis`.
4. **Larangan Fixed Height pada Kontainer Dinamis:**
   * Dilarang menggunakan tinggi statis (misal `Container(height: 50)`) pada kotak yang memuat teks multibahasa. Gunakan ukuran yang beradaptasi secara dinamis (*auto-layout*).
5. **Scroll Safety & Banner Safe Area:**
   * Setiap layar formulir wajib dibungkus dalam `SingleChildScrollView` dengan `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag`.
   * Wajib menyisipkan bantalan bawah (`padding: EdgeInsets.only(bottom: 65)`) agar isian formulir terbawah tidak tertutup oleh iklan *Adaptive Banner* yang melayang.

---

### G. Standar Sistem Lokalisasi / Multi-Bahasa (`.tr`):

1. **Pola Pemanggilan Ekstensi `.tr`:**
   * Seluruh teks antarmuka pengguna **DILARANG di-hardcode** langsung di dalam widget UI.
   * Seluruh string wajib dipanggil melalui format ekstensi:
     ```dart
     Text('form.personal_info.title'.tr)
     Text('ats_score.score_summary'.tr(args: [score.toString()]))
     ```
2. **Struktur Naming Key Terstandarisasi (Hierarki Titik):**
   * `common.*` $\rightarrow$ `common.save`, `common.cancel`, `common.continue`
   * `form.*` $\rightarrow$ `form.personal.*`, `form.experience.*`, `form.skills.*`
   * `ats.*` $\rightarrow$ `ats.checker_title`, `ats.score_label`, `ats.auto_fix_btn`
   * `job_match.*` $\rightarrow$ `job_match.upload_screenshot`, `job_match.missing_keywords`
   * `quota.*` $\rightarrow$ `quota.limit_reached`, `quota.remaining_count`
   * `ad.*` $\rightarrow$ `ad.reward_prompt_generate`, `ad.reward_prompt_download`
3. **Dukungan Bahasa & Fallback Otomatis:**
   * Bahasa utama: `id_ID` (Bahasa Indonesia) dan `en_US` (Bahasa Inggris Internasional).
   * **Aturan Fallback:** Jika ada key bahasa yang belum diterjemahkan ke bahasa tertentu, sistem wajib otomatis menggunakan teks dari `en_US` tanpa menampilkan error atau merusak aplikasi.

---

### H. Jaring Pengaman Teknis & Checklist Pra-Eksekusi:

1. **Penyimpanan Draf Otomatis di Smartphone (Local Auto-Save):**
   * Menggunakan penyimpanan lokal instan (`Hive` atau `SharedPreferences`) agar setiap ketikan pengguna tersimpan secara otomatis jika aplikasi tidak sengaja tertutup.
2. **Kunci Schema Output Gemini (Strict JSON Mode):**
   * Menggunakan parameter konfigurasi `response_mime_type: "application/json"` dan skema JSON yang didefinisikan secara kaku agar output AI selalu 100% valid dan konsisten.
3. **AdMob UMP SDK (Consent GDPR / CCPA untuk Pengguna Global):**
   * Mengintegrasikan Google User Messaging Platform (UMP) SDK di Flutter agar iklan tetap tayang optimal bagi pengguna di wilayah Eropa dan California tanpa melanggar kebijakan Google.
4. **Proteksi Kuota Saat Gangguan Server AI (Graceful Rollback):**
   * Kuota 5x harian pengguna **hanya dipotong jika API sukses mengembalikan hasil (HTTP 200)**. Jika terjadi error di server AI, kuota otomatis tidak berkurang dan pengguna dapat mencoba lagi tanpa menonton iklan ulang.
5. **Proteksi API Signature (Mencegah Bot / Scraping Token):**
   * Header request Flutter ke Laravel diverifikasi menggunakan signature rahasia HMAC SHA-256.

---

### I. Strategi Pertumbuhan, Kendali Remote, & Ekosistem Produk:

1. **Mesin Viralitas Organik: "Shareable ATS Score Card" (Zero Budget Marketing):**
   * Tombol *"Bagikan Hasil Skor"* merender kartu visual elegan (ala Spotify Wrapped) berisi nama pengguna, skor ATS besar (*96/100 - Top 5% ATS Ready*), grafik radar mini kompetensi, dan watermark brand:
     > *"Dibuat & Dicek Gratis di Resumer - Unduh di Google Play Store"*.
   * Dibagikan dengan bangga oleh pengguna ke LinkedIn, status WhatsApp, atau X/Twitter.
2. **Remote Configuration via Backend Laravel (`GET /api/v1/app-config`):**
   * Mengendalikan parameter aplikasi secara nirkabel dari server Laravel tanpa rilis ulang APK:
     * `daily_quota_limit`: Angka batasan kuota harian (default: 5).
     * `admob_unit_ids`: Penggantian ID unit iklan AdMob secara instan.
     * `min_app_version` & `force_update`: Memaksa update aplikasi jika terdapat bug kritis.
     * `is_maintenance`: Saklar mode pemeliharaan server.
3. **Fitur Pendamping: AI Cover Letter (Surat Lamaran Kerja) Generator:**
   * Pengguna memasukkan *Nama Perusahaan* dan *Posisi yang Dilamar*. AI Gemini meramu data CV menjadi 3 paragraf surat lamaran formal profesional berstandar eksekutif.
   * **Pemindaian Proyek Mandatori:** Pada Paragraf 2 (Korelasi Bukti & Capaian), AI secara aktif memindai riwayat kerja dan seksi **Proyek / Portofolio** kandidat, mengutip pencapaian atau teknologi spesifik dari proyek yang relevan dengan perusahaan target.
   * Monetisasi: Pengguna menonton **1 Rewarded Video Ad ekstra** untuk mengekspor surat lamaran tersebut.
4. **Kepatuhan Kebijakan Google Play Console (AI & Privacy Policy):**
   * **Halaman Kebijakan Privasi (Privacy Policy):** Route statis di backend Laravel (`https://api.namadomain.com/privacy-policy`) yang menegaskan bahwa foto dan dokumen diproses di memori lokal perangkat.
   * **Fitur Pelaporan Konten AI:** Tombol kecil *"Laporkan respons ini"* di bawah teks hasil generate.
5. **Personalisasi Desain CV Ramah ATS (Tipografi & Aksen Warna):**
   * **4 Pilihan Font Standar ATS Resmi:** *Calibri*, *Arial*, *Garamond*, dan *Outfit / Inter*.
   * **4 Pilihan Aksen Warna Profesional:** *Hitam Monokrom*, *Deep Navy Blue*, *Charcoal Gray*, dan *Forest Emerald*.

---

### J. Standar Sistem Desain UI/UX (Design System & Color Palette):

Untuk memastikan seluruh antarmuka aplikasi Resumer tampil konsisten, berkelas, ramah mata, dan memancarkan aura profesionalisme korporat modern berpadu kecerdasan AI:

#### 1. Filosofi Visual: "Quiet Luxury & Bespoke Executive"
* Mengadopsi estetika *Quiet Luxury* (seperti aplikasi finansial elit, konsultan manajemen top-tier, dan kertas resume bertekstur mahal).
* **Menghilangkan seluruh warna biru neon/menyala yang terkesan murahan**. Seluruh warna dirancang teduh (*matte & muted*), berbobot, dan tidak melelahkan mata saat dipandang lama.

#### 2. Palet Warna Resmi (The Bespoke Executive Palette):
* **Warna Utama (Brand, Wibawa & Tombol Utama):**
  * `Midnight Oxford Navy`: `#0B132B` (Biru malam pekat yang sangat mewah, menggantikan warna biru terang).
  * `Muted Steel Slate`: `#1C2541` & `#3A506B` (Aksen tombol sekunder, border interaktif, dan ikon bernuansa baja teduh).
  * `Subtle Slate Tint`: `#F1F5F9` (Latar belakang elemen interaktif aktif atau badge penanda).
* **Aksen Status & Skor ATS (Matte & Sophisticated Feedback):**
  * `Deep Forest Pine` (`#065F46` / `#047857`): Untuk **Skor ATS Prima (85–100)** dan badge sukses. Menggunakan hijau pinus perbankan Swiss (bukan hijau neon stabilo).
  * `Antique Bronze / Champagne Gold` (`#92400E` / `#B45309`): Untuk **Skor ATS Sedang (60–84)**, indikator kuota harian, dan tombol *Rewarded Video Ad* (🎬). Warna tembaga emas antik yang mahal.
  * `Crimson Bordeaux` (`#881337` / `#991B1B`): Untuk **Skor ATS Rendah (<60)** dan peringatan format. Warna merah marun anggun (bukan merah cabai menyala).
* **Warna Netral & Kanvas Latar Belakang (Paper-Feel):**
  * `Oyster Paper Canvas`: `#F8F9FA` (Nuansa kertas linen premium yang lembut dan sangat menyejukkan mata).
  * `Surface Card`: `#FFFFFF` — Latar kartu putih bersih dengan garis pembatas super tipis *Titanium Hairline* `#E2E8F0`.
  * `Text Primary`: `#0A0F1D` (Hitam arang pekat / *Charcoal Obsidian* untuk keterbacaan tipografi kelas atas).
  * `Text Secondary`: `#64748B` (Abu-abu grafit halus untuk keterangan tanggal dan panduan).

#### 3. Kalibrasi Tipografi (Outfit Typography Scale):
* **Font Utama Aplikasi:** **Outfit** (via `google_fonts`). Modern, proporsional, dan sangat mudah dibaca pada layar smartphone kecil.
* **Hierarki Ukuran & Bobot Teks:**
  * `Display / Hero Score`: `32sp – 40sp`, `FontWeight.w800` (Angka skor ATS besar di dashboard).
  * `Page Header Title`: `18sp – 20sp`, `FontWeight.w800`, `letterSpacing: -0.4`.
  * `Card Section Title`: `15sp – 16sp`, `FontWeight.w700`, `letterSpacing: -0.2`.
  * `Body Text`: `13sp – 14sp`, `FontWeight.w400`, `lineHeight: 1.4`.
  * `Helper / Subtitle`: `11sp – 12sp`, `FontWeight.w500`, warna `Text Secondary`.
  * `Badge / Micro Label`: `10sp – 11sp`, `FontWeight.w700`, `letterSpacing: 0.3`.

#### 4. Geometri Komponen & Ergonomi:
* **Header Bar Presisi (Frosted Glass):**
  * Tinggi standar: `56.0 + topPadding` (mengikuti lekuk *notch / punch-hole* kamera HP).
  * Latar belakang: `Colors.white.withValues(alpha: 0.85)` dipadu `BackdropFilter(filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16))`.
  * Tombol kembali (*Back Button*): Melingkar `40x40` px dengan ikon `Icons.arrow_back_ios_new_rounded` (ukuran 18sp) dan border tipis.
* **Elevasi Kartu (Card Surface):**
  * `BorderRadius`: `16px` (konsisten di seluruh aplikasi).
  * `Border`: `Border.all(color: Color(0xFFE2E8F0), width: 1)` untuk memberi ketegasan visual tanpa kesan kaku.
  * `Shadow`: Super halus `BoxShadow(color: Color(0x080F172A), blurRadius: 12, offset: Offset(0, 4))`.
* **Ergonomi Tombol Aksi (CTA):**
  * Tinggi tombol utama: Minimal `50px` – `52px` (nyaman untuk jempol satu tangan).
  * `BorderRadius`: `14px`.
  * Dilengkapi respon sentuh haptik (*light vibration feedback*) saat ditekan.
* **Visualisasi Skor ATS:**
  * Menggunakan *Radial Animated Progress Bar* (lingkaran progress berputar dari 0 ke angka skor saat pengujian selesai).
  * Warna lingkaran progress berubah dinamis: Merah (<60) $\rightarrow$ Kuning/Amber (60–84) $\rightarrow$ Hijau Emerald (85–100).
* **Safe Area Navigasi & Iklan:**
  * Bantalan bawah (*bottom padding*) konten formulir dan kartu skor wajib minimal `80px` agar tidak pernah terhalang oleh *Floating Navigation Bar* maupun iklan *Adaptive Banner* AdMob.

---

### K. Standar Arsitektur Bersih & Larangan Spaghetti Code (Separation of Concerns):

Untuk memastikan proyek Resumer mudah dirawat (*maintainable*), mudah diuji (*testable*), dan tidak berubah menjadi kode kusut (*spaghetti code*):

#### 1. Prinsip Utama (Zero God-File Policy):
* **DILARANG KERAS** menyatukan logika bisnis, pemanggilan API/Database, manajemen state, dan kode antarmuka UI dalam satu file raksasa (*God File*).
* Setiap file harus memiliki **satu tanggung jawab tunggal** (*Single Responsibility Principle*).

#### 2. Standar Arsitektur Flutter (Client-Side Layering):
Aplikasi Flutter dibagi menjadi layer-layer yang terisolasi secara ketat:
* `data/models/`: Struktur data immutable (menggunakan `freezed` atau model serialisasi JSON murni). Dilarang menaruh logika UI di sini.
* `data/datasources/`: Menangani panggilan HTTP mentah ke API Laravel (`api_client.dart`) dan pembacaan memori lokal (`hive_service.dart`, `secure_storage.dart`).
* `data/repositories/`: Menjembatani datasource dengan controller/state management, menangani caching dan error handling data.
* `controllers/` / `state/`: Pengelolaan alur logika dan state (misal: BLoC/Cubit/GetX). **DILARANG mengimpor `dart:ui` atau menulis kode render widget** di dalam controller.
* `views/` (Screens): Berkas halaman utama (misal: `cv_editor_view.dart`, `ats_score_view.dart`). Tugasnya hanya menyusun komponen widget kecil tanpa menulis ratusan baris kode tata letak bersarang.
* `widgets/`: Komponen UI modular yang dapat digunakan kembali (*reusable*):
  * **Batasan Panjang Kode:** Setiap file widget dibatasi maksimal **150 – 200 baris**. Jika sebuah widget mulai panjang, wajib dipecah menjadi sub-komponen terpisah di folder `widgets/components/`.
* `pdf_templates/`: Setiap template PDF diisolasi dalam file independen (misal: `asian_ats_template.dart`, `western_ats_template.dart`, `modern_creative_template.dart`).

#### 3. Standar Arsitektur Laravel 12 (Server-Side Layering):
Backend Laravel menerapkan pola *Controller-Service-Resource* yang bersih:
* **Larangan Keras "Fat Controller":**
  * Controller **HANYA** bertugas menerima HTTP request, memanggil kelas Service, dan mengembalikan HTTP Resource (maksimal 20–30 baris per method).
  * Dilarang keras menulis query database `DB::` atau logika komunikasi Gemini API langsung di dalam Controller.
* **Form Requests (`app/Http/Requests/`):**
  * Seluruh aturan validasi request (tipe data, ukuran file, sanitasi string) wajib dipisah ke kelas Form Request mandiri (misal: `StoreCvRequest.php`, `AtsScoreRequest.php`, `JobMatchRequest.php`).
* **Service Layer (`app/Services/`):**
  * Seluruh logika bisnis diisolasi ke dalam Service Class khusus:
    * `GeminiProxyService.php`: Komunikasi dengan Google Gemini API dan parsing JSON response.
    * `AtsScoringService.php`: Algoritma pembobotan skor ATS dan formulasi rekomendasi.
    * `QuotaManagementService.php`: Logika validasi kuota 5x harian dan rollback saat gagal.
    * `JobMatcherService.php`: Analisis kecocokan CV dengan tangkapan layar/teks loker.
* **API Resources (`app/Http/Resources/`):**
  * Seluruh respons JSON wajib dibungkus menggunakan Laravel API Resource (misal: `CvResource.php`, `AtsScoreResource.php`) untuk menjamin konsistensi format output dan keamanan data.
* **Middleware (`app/Http/Middleware/`):**
  * Memisahkan logika keamanan: verifikasi signature HMAC SHA-256 (`VerifyHmacSignature.php`), autentikasi Sanctum, dan rate limiter.

---

### L. Konfigurasi Server Hosting & Akses Deployment Hostinger:

Berikut rincian arsitektur path hosting resmi untuk backend Resumer pada server Hostinger:
* **Domain Subdomain:** `resumer.cellanoma.my.id`
* **Subdomain Document Root & Laravel Root Directory:**
  `/home/u731410318/domains/cellanoma.my.id/public_html/resumer/`
  *(Memuat seluruh aplikasi backend Laravel: `app/`, `config/`, `routes/`, `database/`, `.env`, `vendor/`, `artisan`, `index.php`, `.htaccess`, dsb.)*
* **Database Server:** MySQL `u731410318_resumer` (Host: `localhost` / `127.0.0.1`)
* **Akses SSH:** Alias `hostinger` atau `resumer`
  * Host: `153.92.8.198`
  * Port: `65002`
  * User: `u731410318`
  * IdentityFile: `~/.ssh/id_rsa` / `~/.ssh/id_ed25519_resumer`
  * **PENTING (Flag Non-Interactive):** Wajib selalu menyertakan `-T -n` (contoh: `ssh -T -n resumer "<command>"`) guna menonaktifkan alokasi TTY & stdin agar eksekusi perintah remote Hostinger selesai dalam hitungan milidetik tanpa hanging.
* **Perintah Pembersihan Cache Remote:**
  `ssh -T -n resumer "cd /home/u731410318/domains/cellanoma.my.id/public_html/resumer && php artisan optimize:clear"`