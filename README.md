# Resumer

AI-powered ATS CV Maker, Score Checker & Job Matcher. Buat CV profesional yang lolos screening ATS secara otomatis.

## Struktur Proyek

```
mobile/    # Aplikasi Flutter (Android)
backend/   # REST API & Gemini AI Proxy (Laravel 12)
```

## Tech Stack

**Mobile:**
- Flutter (Dart ^3.12.2)
- PDF generation client-side (package:pdf + printing)
- Google Sign-In
- Google AdMob & In-App Purchase
- Multi-template CV (12+ desain)

**Backend:**
- Laravel 12 (PHP ^8.2)
- MySQL
- Gemini AI 2.5 Flash (via server-side proxy)
- HMAC SHA-256 signature verification

## Fitur

- Buat CV otomatis dengan bantuan AI
- 12+ template CV profesional (ATS-friendly, creative, executive, dll.)
- Cek skor ATS (seberapa ramah CV kamu terhadap sistem rekrutmen)
- Job matching — cocokkan CV dengan lowongan kerja
- Export PDF langsung dari HP
- Foto profil dengan crop & compress (100% client-side)
- Kuota harian 5x request AI (gratis)
- Premium via In-App Purchase (unlimited)
- Cover letter generator

## Arsitektur

```
Mobile (Flutter)              Backend (Laravel)           AI (Gemini)
┌────────────────┐           ┌─────────────────┐        ┌──────────┐
│ Input CV data  │──HMAC──>  │ Validate + proxy │──────> │ Generate │
│ Render PDF     │           │ Rate limit       │<────── │ JSON     │
│ Live preview   │<────────  │ Store history    │        └──────────┘
└────────────────┘           └─────────────────┘
```

API key Gemini disimpan di backend — tidak pernah masuk ke APK (Zero-Secret-in-Client).

## Setup

### Mobile
```bash
cd mobile
flutter pub get
flutter run
```

### Backend
```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan serve
```

## Versi

Mobile: **1.0.4+5**

## Lisensi

Proprietary — Seluruh hak cipta dilindungi.
