@extends('layouts.app')

@section('title', 'Resumer - AI ATS CV Maker, Score Checker & Job Matcher')

@section('meta_description', 'Aplikasi cerdas pembuat CV otomatis berstandar ATS (Applicant Tracking System), penganalisis skor kualifikasi 0-100, dan pencocok lowongan kerja berbasis AI Google Gemini 2.5 Flash Lite.')

@push('styles')
<style>
    /* Hero Section Styles */
    .hero-section {
        padding: 64px 0 80px 0;
        position: relative;
        overflow: hidden;
    }

    .hero-grid {
        display: grid;
        grid-template-columns: 1.15fr 0.85fr;
        gap: 56px;
        align-items: center;
    }

    .hero-badge-pill {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 6px 14px;
        border-radius: 30px;
        background: rgba(11, 19, 43, 0.05);
        border: 1px solid var(--border);
        font-size: 12.5px;
        font-weight: 600;
        color: var(--primary);
        margin-bottom: 24px;
    }

    .hero-badge-dot {
        width: 8px;
        height: 8px;
        background-color: var(--score-high);
        border-radius: 50%;
        display: inline-block;
        box-shadow: 0 0 0 3px rgba(6, 95, 70, 0.15);
    }

    .hero-title {
        font-size: 44px;
        font-weight: 900;
        line-height: 1.15;
        letter-spacing: -1.2px;
        color: var(--primary);
        margin-bottom: 20px;
    }

    .hero-title-accent {
        background: linear-gradient(135deg, var(--primary) 0%, var(--accent) 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
    }

    .hero-desc {
        font-size: 16.5px;
        line-height: 1.6;
        color: var(--text-secondary);
        margin-bottom: 32px;
        max-width: 540px;
    }

    .hero-cta-group {
        display: flex;
        align-items: center;
        gap: 16px;
        flex-wrap: wrap;
        margin-bottom: 36px;
    }

    .hero-proof-list {
        display: flex;
        align-items: center;
        gap: 24px;
        padding-top: 24px;
        border-top: 1px solid var(--border);
        flex-wrap: wrap;
    }

    .hero-proof-item {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 13px;
        font-weight: 600;
        color: var(--text-secondary);
    }

    .hero-proof-icon {
        color: var(--score-high);
    }

    /* Mockup Score Card */
    .mockup-wrapper {
        position: relative;
    }

    .ats-card-mockup {
        background: var(--surface);
        border: 1px solid var(--border);
        border-radius: var(--radius-xl);
        padding: 32px;
        box-shadow: var(--shadow-lg);
        position: relative;
        transition: transform 0.3s ease;
    }

    .ats-card-mockup:hover {
        transform: translateY(-4px);
    }

    .mockup-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 24px;
        padding-bottom: 16px;
        border-bottom: 1px solid var(--border-subtle);
    }

    .mockup-user-info {
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .mockup-avatar {
        width: 44px;
        height: 44px;
        background: var(--primary);
        color: #FFFFFF;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 800;
        font-size: 15px;
    }

    .mockup-user-name {
        font-size: 15px;
        font-weight: 700;
        color: var(--text-primary);
        line-height: 1.2;
    }

    .mockup-user-role {
        font-size: 12px;
        color: var(--text-secondary);
    }

    .mockup-verified-badge {
        padding: 4px 10px;
        background: var(--score-high-bg);
        color: var(--score-high);
        border-radius: 20px;
        font-size: 11.5px;
        font-weight: 700;
        display: inline-flex;
        align-items: center;
        gap: 4px;
    }

    .mockup-score-hero {
        display: flex;
        align-items: center;
        justify-content: space-between;
        background: var(--canvas);
        border: 1px solid var(--border);
        border-radius: var(--radius-lg);
        padding: 20px;
        margin-bottom: 24px;
    }

    .score-number-box {
        display: flex;
        align-items: baseline;
        gap: 4px;
    }

    .score-big {
        font-size: 48px;
        font-weight: 900;
        color: var(--score-high);
        line-height: 1;
        letter-spacing: -1px;
    }

    .score-max {
        font-size: 18px;
        font-weight: 700;
        color: var(--text-secondary);
    }

    .score-rating-label {
        font-size: 13px;
        font-weight: 700;
        color: var(--score-high);
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    .score-breakdown-list {
        display: flex;
        flex-direction: column;
        gap: 14px;
        margin-bottom: 24px;
    }

    .score-bar-item {
        display: flex;
        flex-direction: column;
        gap: 4px;
    }

    .score-bar-meta {
        display: flex;
        justify-content: space-between;
        font-size: 12.5px;
        font-weight: 600;
    }

    .score-bar-title {
        color: var(--text-primary);
    }

    .score-bar-val {
        color: var(--score-high);
    }

    .score-track {
        height: 6px;
        background: var(--border-subtle);
        border-radius: 3px;
        overflow: hidden;
    }

    .score-fill {
        height: 100%;
        background: var(--score-high);
        border-radius: 3px;
    }

    .mockup-feedback-quote {
        padding: 14px 16px;
        background: #F1F5F9;
        border-left: 3px solid var(--primary);
        border-radius: 4px var(--radius-sm) var(--radius-sm) 4px;
        font-size: 12.5px;
        color: var(--text-secondary);
        line-height: 1.5;
    }

    /* Section Global Headers */
    .section-spacing {
        padding: 80px 0;
    }

    .section-header {
        text-align: center;
        max-width: 680px;
        margin: 0 auto 56px auto;
    }

    .section-tag {
        font-size: 11.5px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 1px;
        color: var(--accent);
        margin-bottom: 12px;
        display: inline-block;
    }

    .section-title {
        font-size: 32px;
        font-weight: 800;
        letter-spacing: -0.8px;
        color: var(--primary);
        margin-bottom: 16px;
        line-height: 1.25;
    }

    .section-desc {
        font-size: 15.5px;
        color: var(--text-secondary);
        line-height: 1.6;
    }

    /* Feature Grid (6 Pillars) */
    .feature-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 28px;
    }

    .feature-card {
        background: var(--surface);
        border: 1px solid var(--border);
        border-radius: var(--radius-lg);
        padding: 32px 28px;
        box-shadow: var(--shadow-sm);
        transition: all 0.3s ease;
        display: flex;
        flex-direction: column;
    }

    .feature-card:hover {
        border-color: var(--accent);
        transform: translateY(-4px);
        box-shadow: var(--shadow-md);
    }

    .feature-icon-box {
        width: 48px;
        height: 48px;
        border-radius: var(--radius-md);
        background: var(--canvas);
        border: 1px solid var(--border);
        color: var(--primary);
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 22px;
    }

    .feature-card-title {
        font-size: 18px;
        font-weight: 700;
        color: var(--primary);
        margin-bottom: 10px;
        letter-spacing: -0.3px;
    }

    .feature-card-desc {
        font-size: 13.5px;
        color: var(--text-secondary);
        line-height: 1.6;
        flex: 1;
    }

    /* ATS Standards Comparison */
    .standards-box {
        background: var(--surface);
        border: 1px solid var(--border);
        border-radius: var(--radius-xl);
        padding: 48px;
        box-shadow: var(--shadow-md);
    }

    .standards-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 40px;
    }

    .standard-col {
        padding: 24px;
        border-radius: var(--radius-lg);
        background: var(--canvas);
        border: 1px solid var(--border);
    }

    .standard-badge {
        display: inline-block;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 11px;
        font-weight: 700;
        margin-bottom: 16px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    .standard-badge-asian {
        background: #FEF3C7;
        color: #92400E;
    }

    .standard-badge-western {
        background: #EFF6FF;
        color: #1E40AF;
    }

    .standard-title {
        font-size: 20px;
        font-weight: 800;
        color: var(--primary);
        margin-bottom: 10px;
    }

    .standard-desc {
        font-size: 13.5px;
        color: var(--text-secondary);
        margin-bottom: 20px;
        line-height: 1.5;
    }

    .standard-checklist {
        list-style: none;
        display: flex;
        flex-direction: column;
        gap: 10px;
    }

    .standard-checklist li {
        display: flex;
        align-items: center;
        gap: 10px;
        font-size: 13px;
        color: var(--text-primary);
        font-weight: 500;
    }

    /* Privacy Banner */
    .privacy-highlight-box {
        background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
        border-radius: var(--radius-xl);
        padding: 56px;
        color: #FFFFFF;
        box-shadow: var(--shadow-lg);
        position: relative;
        overflow: hidden;
    }

    .privacy-grid {
        display: grid;
        grid-template-columns: 1.2fr 0.8fr;
        gap: 48px;
        align-items: center;
    }

    .privacy-title {
        font-size: 32px;
        font-weight: 900;
        letter-spacing: -0.6px;
        margin-bottom: 16px;
        line-height: 1.25;
    }

    .privacy-desc {
        font-size: 15px;
        color: #CBD5E1;
        line-height: 1.6;
        margin-bottom: 24px;
    }

    .privacy-stat-card {
        background: rgba(255, 255, 255, 0.08);
        backdrop-filter: blur(12px);
        border: 1px solid rgba(255, 255, 255, 0.15);
        border-radius: var(--radius-lg);
        padding: 28px;
        display: flex;
        flex-direction: column;
        gap: 16px;
    }

    .privacy-stat-row {
        display: flex;
        align-items: center;
        gap: 14px;
    }

    .privacy-stat-number {
        font-size: 28px;
        font-weight: 900;
        color: #34D399;
        min-width: 80px;
    }

    .privacy-stat-label {
        font-size: 13px;
        color: #E2E8F0;
        line-height: 1.4;
    }

    /* Steps Section */
    .steps-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 32px;
    }

    .step-card {
        position: relative;
        padding: 32px 24px;
        background: var(--surface);
        border: 1px solid var(--border);
        border-radius: var(--radius-lg);
    }

    .step-number {
        font-size: 36px;
        font-weight: 900;
        color: rgba(11, 19, 43, 0.12);
        line-height: 1;
        margin-bottom: 14px;
    }

    .step-title {
        font-size: 17px;
        font-weight: 700;
        color: var(--primary);
        margin-bottom: 8px;
    }

    .step-desc {
        font-size: 13px;
        color: var(--text-secondary);
        line-height: 1.5;
    }

    /* FAQ Section */
    .faq-container {
        max-width: 780px;
        margin: 0 auto;
        display: flex;
        flex-direction: column;
        gap: 16px;
    }

    .faq-item {
        background: var(--surface);
        border: 1px solid var(--border);
        border-radius: var(--radius-md);
        overflow: hidden;
    }

    .faq-question {
        padding: 20px 24px;
        font-size: 15px;
        font-weight: 700;
        color: var(--primary);
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: space-between;
        user-select: none;
    }

    .faq-answer {
        padding: 0 24px 20px 24px;
        font-size: 13.5px;
        color: var(--text-secondary);
        line-height: 1.6;
    }

    /* Download CTA Box */
    .download-cta-section {
        background: var(--surface);
        border: 1px solid var(--border);
        border-radius: var(--radius-xl);
        padding: 64px 32px;
        text-align: center;
        box-shadow: var(--shadow-md);
        margin-top: 40px;
    }

    @media (max-width: 992px) {
        .hero-grid {
            grid-template-columns: 1fr;
            gap: 48px;
        }
        .feature-grid {
            grid-template-columns: repeat(2, 1fr);
        }
        .standards-grid {
            grid-template-columns: 1fr;
        }
        .privacy-grid {
            grid-template-columns: 1fr;
        }
        .steps-grid {
            grid-template-columns: 1fr;
        }
    }

    @media (max-width: 640px) {
        .hero-title {
            font-size: 32px;
        }
        .feature-grid {
            grid-template-columns: 1fr;
        }
        .standards-box {
            padding: 24px;
        }
        .privacy-highlight-box {
            padding: 32px 20px;
        }
    }
</style>
@endpush

@section('content')

    <!-- 1. Hero Section -->
    <section class="hero-section">
        <div class="container">
            <div class="hero-grid">
                <div>
                    <div class="hero-badge-pill">
                        <span class="hero-badge-dot"></span>
                        <span>Google Gemini 2.5 Flash Lite Powered • 100% Free Ad-Supported</span>
                    </div>

                    <h1 class="hero-title">
                        Tembus Filter Robot HRD dengan <span class="hero-title-accent">CV Berstandar ATS 90–98+</span>
                    </h1>

                    <p class="hero-desc">
                        Resumer menggabungkan kecerdasan buatan Gemini AI dengan formula rekrutmen global (Google XYZ) untuk menghasilkan draf resume berdaya saing tinggi, menganalisis skor ATS secara instan, dan mencocokkan kualifikasi loker target Anda.
                    </p>

                    <div class="hero-cta-group">
                        <a href="{{ route('download-apk') }}" class="btn btn-primary btn-lg">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                            Unduh APK Android (Gratis)
                        </a>
                        <a href="#features" class="btn btn-secondary btn-lg">
                            Pelajari Fitur Cerdas
                        </a>
                    </div>

                    <div class="hero-proof-list">
                        <div class="hero-proof-item">
                            <svg class="hero-proof-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                            <span>1-Tap Google Sign-In</span>
                        </div>
                        <div class="hero-proof-item">
                            <svg class="hero-proof-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                            <span>0-Byte Foto di Server</span>
                        </div>
                        <div class="hero-proof-item">
                            <svg class="hero-proof-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                            <span>Client-Side PDF Engine</span>
                        </div>
                    </div>
                </div>

                <!-- Live ATS Mockup Card -->
                <div class="mockup-wrapper">
                    <div class="ats-card-mockup">
                        <div class="mockup-header">
                            <div class="mockup-user-info">
                                <div class="mockup-avatar">AW</div>
                                <div>
                                    <div class="mockup-user-name">Alexander Wright</div>
                                    <div class="mockup-user-role">Senior Product Operations Specialist</div>
                                </div>
                            </div>
                            <div class="mockup-verified-badge">
                                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                                ATS Ready
                            </div>
                        </div>

                        <div class="mockup-score-hero">
                            <div>
                                <div class="score-number-box">
                                    <span class="score-big">96</span>
                                    <span class="score-max">/100</span>
                                </div>
                                <div class="score-rating-label">Top 5% ATS Ready</div>
                            </div>
                            <div style="text-align: right;">
                                <div style="font-size: 11px; color: var(--text-secondary); text-transform: uppercase; font-weight: 600;">Engine Analisis</div>
                                <div style="font-size: 13px; font-weight: 700; color: var(--primary);">Gemini 2.5 Flash Lite</div>
                            </div>
                        </div>

                        <div class="score-breakdown-list">
                            <div class="score-bar-item">
                                <div class="score-bar-meta">
                                    <span class="score-bar-title">Keyword & Industry Match</span>
                                    <span class="score-bar-val">98%</span>
                                </div>
                                <div class="score-track"><div class="score-fill" style="width: 98%;"></div></div>
                            </div>

                            <div class="score-bar-item">
                                <div class="score-bar-meta">
                                    <span class="score-bar-title">Impact & Action Verbs (Formula XYZ)</span>
                                    <span class="score-bar-val">94%</span>
                                </div>
                                <div class="score-track"><div class="score-fill" style="width: 94%;"></div></div>
                            </div>

                            <div class="score-bar-item">
                                <div class="score-bar-meta">
                                    <span class="score-bar-title">Format & ATS Readability</span>
                                    <span class="score-bar-val">97%</span>
                                </div>
                                <div class="score-track"><div class="score-fill" style="width: 97%;"></div></div>
                            </div>

                            <div class="score-bar-item">
                                <div class="score-bar-meta">
                                    <span class="score-bar-title">Data Completeness & Sections</span>
                                    <span class="score-bar-val">100%</span>
                                </div>
                                <div class="score-track"><div class="score-fill" style="width: 100%;"></div></div>
                            </div>
                        </div>

                        <div class="mockup-feedback-quote">
                            <strong>Feedback AI:</strong> "Deskripsi pengalaman kerja berhasil menggunakan metrik kuantitatif dan kata kerja aksi aktif. Struktur linear terbaca sempurna oleh mesin ATS Workday, Taleo, dan Greenhouse."
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- 2. The ATS Reality Stats -->
    <section style="background: #FFFFFF; border-top: 1px solid var(--border); border-bottom: 1px solid var(--border); padding: 48px 0;">
        <div class="container">
            <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 32px; text-align: center;">
                <div>
                    <div style="font-size: 38px; font-weight: 900; color: var(--primary); letter-spacing: -1px; margin-bottom: 4px;">90%+</div>
                    <div style="font-size: 13.5px; color: var(--text-secondary); max-width: 260px; margin: 0 auto;">Perusahaan Fortune 500 menggunakan parser ATS untuk menyaring kandidat.</div>
                </div>
                <div>
                    <div style="font-size: 38px; font-weight: 900; color: var(--score-low); letter-spacing: -1px; margin-bottom: 4px;">75%</div>
                    <div style="font-size: 13.5px; color: var(--text-secondary); max-width: 260px; margin: 0 auto;">Resume gugur di tahap awal akibat format tabel, grafik rumit, atau salah tata letak.</div>
                </div>
                <div>
                    <div style="font-size: 38px; font-weight: 900; color: var(--score-high); letter-spacing: -1px; margin-bottom: 4px;">95–98+</div>
                    <div style="font-size: 13.5px; color: var(--text-secondary); max-width: 260px; margin: 0 auto;">Skor garansi bawaan pada seluruh template resmi yang di-generate via Resumer.</div>
                </div>
            </div>
        </div>
    </section>

    <!-- 3. Features Section (6 Pillars) -->
    <section id="features" class="section-spacing">
        <div class="container">
            <div class="section-header">
                <span class="section-tag">Fitur Cerdas Generasi Baru</span>
                <h2 class="section-title">Teknologi Rekrutmen Modern di Genggaman Tangan Anda</h2>
                <p class="section-desc">
                    Resumer dirancang bukan sekadar sebagai aplikasi pembuat dokumen biasa, melainkan laboratorium kalibrasi resume yang menyelaraskan profil Anda dengan algoritma perekrutan korporat.
                </p>
            </div>

            <div class="feature-grid">
                <!-- Feature 1 -->
                <div class="feature-card">
                    <div class="feature-icon-box">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                    </div>
                    <h3 class="feature-card-title">AI ATS Resume Builder</h3>
                    <p class="feature-card-desc">
                        Menyusun ringkasan eksekutif dan poin pengalaman kerja dengan formula Google XYZ (<em>Accomplished [X], measured by [Y], by doing [Z]</em>) serta kata kerja aksi yang persuasif.
                    </p>
                </div>

                <!-- Feature 2 -->
                <div class="feature-card">
                    <div class="feature-icon-box">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="m9 12 2 2 4-4"/></svg>
                    </div>
                    <h3 class="feature-card-title">ATS Score & Quality Checker</h3>
                    <p class="feature-card-desc">
                        Analisis instan kualitas CV dengan skor 0–100. Sistem membongkar kerapian susunan, kerapatan kata kunci industri, dan memberikan rekomendasi konkret untuk perbaikan.
                    </p>
                </div>

                <!-- Feature 3 -->
                <div class="feature-card">
                    <div class="feature-icon-box">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m12 3-1.9 5.8a2 2 0 0 1-1.3 1.3L3 12l5.8 1.9a2 2 0 0 1 1.3 1.3L12 21l1.9-5.8a2 2 0 0 1 1.3-1.3L21 12l-5.8-1.9a2 2 0 0 1-1.3-1.3L12 3z"/></svg>
                    </div>
                    <h3 class="feature-card-title">1-Click ATS Auto-Fix</h3>
                    <p class="feature-card-desc">
                        Punya CV lama bernilai sedang (50–75)? Satu sentuhan AI langsung merombak kalimat pasif, menyisipkan estimasi metrik capaian, dan melesatkan skor menjadi 95+ dalam sekejap.
                    </p>
                </div>

                <!-- Feature 4 -->
                <div class="feature-card">
                    <div class="feature-icon-box">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                    </div>
                    <h3 class="feature-card-title">Multimodal Job Matcher</h3>
                    <p class="feature-card-desc">
                        Cukup unggah screenshot loker atau tempel teks persyaratan. AI mendeteksi kecocokan kualifikasi, menemukan kata kunci yang hilang, dan menyesuaikan CV secara otomatis.
                    </p>
                </div>

                <!-- Feature 5 -->
                <div class="feature-card">
                    <div class="feature-icon-box">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                    </div>
                    <h3 class="feature-card-title">AI Cover Letter Generator</h3>
                    <p class="feature-card-desc">
                        Menghasilkan surat lamaran kerja profesional 3-paragraf yang diselaraskan dengan nama perusahaan dan posisi target. Dilengkapi dukungan tanda tangan digital terintegrasi.
                    </p>
                </div>

                <!-- Feature 6 -->
                <div class="feature-card">
                    <div class="feature-icon-box">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                    </div>
                    <h3 class="feature-card-title">Multi-Profil CV (Satu Akun, 3 CV)</h3>
                    <p class="feature-card-desc">
                        Simpan hingga 3 variasi CV berbeda (misal: Versi IT, Versi Manajerial, Versi Administrasi) di akun Anda. Beralih profil seketika tanpa khawatir draf tertimpa.
                    </p>
                </div>
            </div>
        </div>
    </section>

    <!-- 4. Dual ATS Standards Section -->
    <section id="ats-standards" class="section-spacing" style="background-color: #F1F5F9; border-top: 1px solid var(--border); border-bottom: 1px solid var(--border);">
        <div class="container">
            <div class="section-header">
                <span class="section-tag">Dual-Market Engineering</span>
                <h2 class="section-title">Standar Khusus Pasar Asia vs Pasar Global</h2>
                <p class="section-desc">
                    Format rekrutmen di Indonesia dan Asia Tenggara memiliki kebiasaan berbeda dengan regulasi di Amerika dan Eropa. Resumer menyediakan cetakan matematis untuk kedua pasar tersebut.
                </p>
            </div>

            <div class="standards-box">
                <div class="standards-grid">
                    <!-- Asian ATS Standard -->
                    <div class="standard-col">
                        <span class="standard-badge standard-badge-asian">Standar Pasar Asia & Indonesia</span>
                        <h3 class="standard-title">Asian ATS Standard</h3>
                        <p class="standard-desc">
                            Dirancang khusus untuk preferensi rekruter di Indonesia, Singapura, dan Malaysia yang masih mengharapkan foto formal kandidat tanpa mengorbankan keterbacaan robot ATS.
                        </p>
                        <ul class="standard-checklist">
                            <li>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" color="var(--score-high)"><polyline points="20 6 9 17 4 12"/></svg>
                                <span>Header terisolasi dengan slot pas foto 3x4 formal</span>
                            </li>
                            <li>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" color="var(--score-high)"><polyline points="20 6 9 17 4 12"/></svg>
                                <span>Tata letak linear satu kolom ramah parser sistem HRD</span>
                            </li>
                            <li>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" color="var(--score-high)"><polyline points="20 6 9 17 4 12"/></svg>
                                <span>Garansi Skor ATS tetap tinggi (85–95 poin)</span>
                            </li>
                        </ul>
                    </div>

                    <!-- Western Strict ATS -->
                    <div class="standard-col">
                        <span class="standard-badge standard-badge-western">Standar Global, US & Eropa</span>
                        <h3 class="standard-title">Western Strict ATS</h3>
                        <p class="standard-desc">
                            Format hitam-putih murni tanpa foto guna mematuhi undang-undang ketenagakerjaan anti-bias di Amerika Serikat dan Eropa (EEOC compliance).
                        </p>
                        <ul class="standard-checklist">
                            <li>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" color="var(--score-high)"><polyline points="20 6 9 17 4 12"/></svg>
                                <span>Nol foto & nol grafis dekoratif (100% Text Linear)</span>
                            </li>
                            <li>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" color="var(--score-high)"><polyline points="20 6 9 17 4 12"/></svg>
                                <span>Kesesuaian absolut dengan Workday, Taleo, dan Greenhouse</span>
                            </li>
                            <li>
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" color="var(--score-high)"><polyline points="20 6 9 17 4 12"/></svg>
                                <span>Garansi Skor ATS sempurna (95–100 poin)</span>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- 5. Zero-Photo Privacy Guarantee -->
    <section class="section-spacing">
        <div class="container">
            <div class="privacy-highlight-box">
                <div class="privacy-grid">
                    <div>
                        <div style="display: inline-flex; align-items: center; gap: 8px; background: rgba(255,255,255,0.1); padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; margin-bottom: 16px;">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                            Zero Server Photo Guarantee
                        </div>
                        <h2 class="privacy-title">Foto & Dokumen Anda Adalah Privasi Mutlak Anda</h2>
                        <p class="privacy-desc">
                            Tidak seperti aplikasi resume online yang mengunggah foto wajah Anda ke cloud, Resumer memproses pemotongan, kompresi, dan penataan pas foto <strong>100% di dalam memori lokal ponsel pintar Anda</strong>. Foto tidak pernah disentuh server backend kami maupun dikirim ke Gemini AI.
                        </p>
                        <a href="{{ route('privacy-policy') }}" class="btn btn-secondary btn-sm" style="background: rgba(255,255,255,0.15); color: #FFFFFF; border-color: rgba(255,255,255,0.3);">
                            Baca Kebijakan Privasi Lengkap
                        </a>
                    </div>

                    <div class="privacy-stat-card">
                        <div class="privacy-stat-row">
                            <div class="privacy-stat-number">0 Byte</div>
                            <div class="privacy-stat-label">Beban penyimpanan foto di server hosting (Privasi 100% aman).</div>
                        </div>
                        <div style="height: 1px; background: rgba(255,255,255,0.1);"></div>
                        <div class="privacy-stat-row">
                            <div class="privacy-stat-number">100%</div>
                            <div class="privacy-stat-label">Render & kompilasi file PDF diproses secara client-side di HP Anda.</div>
                        </div>
                        <div style="height: 1px; background: rgba(255,255,255,0.1);"></div>
                        <div class="privacy-stat-row">
                            <div class="privacy-stat-number">1-Tap</div>
                            <div class="privacy-stat-label">Google OAuth aman tanpa menyimpan sandi Anda di database.</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- 6. How It Works (3 Steps) -->
    <section id="how-it-works" class="section-spacing" style="background: #FFFFFF; border-top: 1px solid var(--border); border-bottom: 1px solid var(--border);">
        <div class="container">
            <div class="section-header">
                <span class="section-tag">Alur Cepat</span>
                <h2 class="section-title">Hasilkan CV Siap Kerja dalam 3 Langkah</h2>
                <p class="section-desc">Proses ringkas tanpa pendaftaran manual yang berbelit-belit.</p>
            </div>

            <div class="steps-grid">
                <div class="step-card">
                    <div class="step-number">01</div>
                    <h3 class="step-title">Masuk & Isi Profil</h3>
                    <p class="step-desc">
                        Masuk cukup 1-klik dengan Akun Google. Masukkan data diri, riwayat karir, dan keahlian menggunakan sistem modul toggle dinamis.
                    </p>
                </div>

                <div class="step-card">
                    <div class="step-number">02</div>
                    <h3 class="step-title">Kalibrasi dengan Gemini AI</h3>
                    <p class="step-desc">
                        Biarkan AI Gemini Flash Lite memoles kalimat aksi dan menguji skor ATS. Tonton Rewarded Ad untuk menikmati fitur cek skor & auto-fix secara gratis.
                    </p>
                </div>

                <div class="step-card">
                    <div class="step-number">03</div>
                    <h3 class="step-title">Ekspor PDF High-Res</h3>
                    <p class="step-desc">
                        Tinjau live preview, beralih antara template Asian ATS atau Western Strict secara instan, dan unduh berkas PDF siap kirim ke portal karir impian Anda.
                    </p>
                </div>
            </div>
        </div>
    </section>

    <!-- 7. FAQ Section -->
    <section class="section-spacing">
        <div class="container">
            <div class="section-header">
                <span class="section-tag">Pertanyaan Umum</span>
                <h2 class="section-title">Kerap Ditanyakan oleh Para Pencari Kerja</h2>
            </div>

            <div class="faq-container">
                <div class="faq-item">
                    <div class="faq-question">
                        <span>Apakah aplikasi Resumer benar-benar gratis digunakan?</span>
                        <span>+</span>
                    </div>
                    <div class="faq-answer">
                        Ya, Resumer 100% gratis dengan model Ad-Supported. Anda mendapatkan jatah kuota 5x generate/revisi AI setiap hari yang direset otomatis pada pukul 00:00. Fitur AI lanjutan dibuka melalui penayangan Rewarded Video Ads tanpa perlu berlangganan kartu kredit.
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">
                        <span>Mengapa foto profil saya dijamin aman?</span>
                        <span>+</span>
                    </div>
                    <div class="faq-answer">
                        Aplikasi Resumer menjalankan prinsip Zero-Server Photo Processing. Seluruh berkas foto profil dipotong dan dikompresi langsung di memori smartphone Anda menggunakan library Flutter lokal. Berkas gambar tidak pernah dikirimkan ke server hosting kami maupun ke Gemini AI API.
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">
                        <span>Apa perbedaan mendasar template Asian ATS dan Western Strict ATS?</span>
                        <span>+</span>
                    </div>
                    <div class="faq-answer">
                        Template Asian ATS mengakomodasi kebiasaan rekrutmen di Indonesia dan Asia yang mengharapkan pas foto formal di sudut atas dengan tata letak satu kolom ramah mesin. Sedangkan Western Strict ATS menghapus seluruh foto dan ornamen visual guna memenuhi kepatuhan regulasi ketenagakerjaan anti-diskriminasi di Amerika Serikat dan Eropa.
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">
                        <span>Bagaimana cara menghapus akun dan data saya?</span>
                        <span>+</span>
                    </div>
                    <div class="faq-answer">
                        Anda dapat menghapus akun beserta seluruh 3 variasi CV dan riwayat skor ATS Anda secara instan melalui aplikasi Android (di menu Profil) atau melalui formulir web resmi pada tautan <a href="{{ route('account-deletion') }}" style="color: var(--primary); font-weight: 700; text-decoration: underline;">Permintaan Hapus Akun</a>.
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- 8. Download CTA Box -->
    <section style="padding-bottom: 80px;">
        <div class="container">
            <div class="download-cta-section">
                <h2 style="font-size: 32px; font-weight: 900; color: var(--primary); margin-bottom: 12px; letter-spacing: -0.6px;">
                    Mulai Susun Resume Berstandar Eksekutif Sekarang
                </h2>
                <p style="font-size: 15.5px; color: var(--text-secondary); max-width: 580px; margin: 0 auto 32px auto;">
                    Gratis, tanpa langganan tersembunyi, dan aman dari pembocoran data pribadi. Unduh aplikasi Android Resumer hari ini.
                </p>
                <div style="display: flex; align-items: center; justify-content: center; gap: 16px; flex-wrap: wrap;">
                    <a href="{{ route('download-apk') }}" class="btn btn-primary btn-lg">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                        Unduh File APK Android (v1.0.0)
                    </a>
                    <a href="{{ route('privacy-policy') }}" class="btn btn-secondary btn-lg">
                        Tinjau Kebijakan Privasi
                    </a>
                </div>
            </div>
        </div>
    </section>

@endsection
