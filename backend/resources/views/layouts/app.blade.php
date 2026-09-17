<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>@yield('title', 'Resumer - AI ATS CV Maker, Score Checker & Job Matcher')</title>
    <meta name="description" content="@yield('meta_description', 'Aplikasi cerdas pembuat CV otomatis berstandar ATS (Applicant Tracking System), penganalisis skor CV 0-100, dan pencocok kualifikasi lowongan kerja berbasis AI Google Gemini.')">
    <meta name="theme-color" content="#0B132B">

    <!-- Open Graph / Meta -->
    <meta property="og:type" content="website">
    <meta property="og:url" content="{{ url()->current() }}">
    <meta property="og:title" content="@yield('title', 'Resumer - AI ATS CV Maker & Score Checker')">
    <!-- Favicon -->
    <link rel="icon" type="image/svg+xml" href="{{ asset('favicon.svg') }}?v=2">
    <link rel="icon" type="image/png" sizes="32x32" href="{{ asset('favicon-32x32.png') }}?v=2">
    <link rel="icon" type="image/png" sizes="16x16" href="{{ asset('favicon-16x16.png') }}?v=2">
    <link rel="shortcut icon" href="{{ asset('favicon.ico') }}?v=2">
    <link rel="apple-touch-icon" sizes="180x180" href="{{ asset('apple-touch-icon.png') }}?v=2">

    <!-- Fonts: Outfit (Bespoke Executive Standard) -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">

    <!-- Stylesheet -->
    <style>
        :root {
            --primary: #0B132B;          /* Midnight Oxford Navy */
            --secondary: #1C2541;        /* Muted Steel Slate Dark */
            --accent: #3A506B;           /* Muted Steel Slate Light */
            --canvas: #F8F9FA;           /* Oyster Paper Canvas */
            --surface: #FFFFFF;          /* Pure White Card Surface */
            --border: #E2E8F0;           /* Titanium Hairline Border */
            --border-subtle: #EDF2F7;
            --text-primary: #0A0F1D;     /* Obsidian Charcoal */
            --text-secondary: #64748B;   /* Slate Graphite */
            --text-muted: #94A3B8;
            
            /* Status / Scoring Colors */
            --score-high: #065F46;       /* Deep Forest Pine */
            --score-high-bg: #ECFDF5;
            --score-mid: #92400E;        /* Antique Bronze */
            --score-mid-bg: #FEF3C7;
            --score-low: #881337;        /* Crimson Bordeaux */
            --score-low-bg: #FFE4E6;
            
            --radius-sm: 8px;
            --radius-md: 12px;
            --radius-lg: 16px;
            --radius-xl: 24px;
            
            --shadow-sm: 0 2px 8px rgba(11, 19, 43, 0.03);
            --shadow-md: 0 8px 24px rgba(11, 19, 43, 0.05);
            --shadow-lg: 0 16px 36px rgba(11, 19, 43, 0.07);
        }

        *, *::before, *::after {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        html {
            scroll-behavior: smooth;
            -webkit-text-size-adjust: 100%;
        }

        body {
            font-family: 'Outfit', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            background-color: var(--canvas);
            color: var(--text-primary);
            line-height: 1.6;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
            overflow-x: hidden;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        a {
            color: inherit;
            text-decoration: none;
            transition: all 0.2s ease;
        }

        img, svg {
            display: block;
            max-width: 100%;
        }

        .container {
            width: 100%;
            max-width: 1160px;
            margin: 0 auto;
            padding: 0 24px;
        }

        /* ===== NAVBAR (FROSTED GLASS) ===== */
        .header-navbar {
            position: sticky;
            top: 0;
            z-index: 1000;
            background: rgba(248, 249, 250, 0.88);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border-bottom: 1px solid var(--border);
            transition: background-color 0.3s ease, border-color 0.3s ease;
        }

        .header-navbar .container {
            height: 72px;
            display: flex;
            align-items: center;
        }

        .nav-wrapper {
            display: flex;
            align-items: center;
            justify-content: space-between;
            width: 100%;
        }

        .brand-logo {
            display: flex;
            align-items: center;
            gap: 12px;
            text-decoration: none;
        }

        .brand-icon {
            width: 38px;
            height: 38px;
            background: var(--primary);
            color: #FFFFFF;
            border-radius: var(--radius-md);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            font-size: 19px;
            letter-spacing: -0.5px;
            box-shadow: 0 4px 12px rgba(11, 19, 43, 0.15);
        }

        .brand-text {
            display: flex;
            flex-direction: column;
        }

        .brand-title {
            font-size: 20px;
            font-weight: 800;
            letter-spacing: -0.4px;
            color: var(--primary);
            line-height: 1.1;
        }

        .brand-subtitle {
            font-size: 10.5px;
            font-weight: 600;
            color: var(--text-secondary);
            letter-spacing: 0.6px;
            text-transform: uppercase;
        }

        .nav-links {
            display: flex;
            align-items: center;
            gap: 28px;
            list-style: none;
        }

        .nav-link {
            font-size: 14px;
            font-weight: 500;
            color: var(--text-secondary);
            position: relative;
            padding: 6px 0;
        }

        .nav-link:hover, .nav-link.active {
            color: var(--primary);
        }

        .nav-link.active::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            width: 100%;
            height: 2px;
            background: var(--primary);
            border-radius: 2px;
        }

        .nav-actions {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 10px 20px;
            border-radius: var(--radius-md);
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
            border: 1px solid transparent;
            text-decoration: none;
            line-height: 1.2;
        }

        .btn-primary {
            background-color: var(--primary);
            color: #FFFFFF;
            box-shadow: 0 4px 14px rgba(11, 19, 43, 0.18);
        }

        .btn-primary:hover {
            background-color: var(--secondary);
            transform: translateY(-1px);
            box-shadow: 0 6px 18px rgba(11, 19, 43, 0.22);
            color: #FFFFFF;
        }

        .btn-secondary {
            background-color: var(--surface);
            color: var(--primary);
            border-color: var(--border);
        }

        .btn-secondary:hover {
            border-color: var(--accent);
            background-color: var(--canvas);
            color: var(--primary);
        }

        .btn-sm {
            padding: 8px 16px;
            font-size: 13px;
            border-radius: var(--radius-sm);
        }

        .btn-lg {
            padding: 14px 28px;
            font-size: 15.5px;
            border-radius: var(--radius-md);
        }

        /* Mobile Hamburger & Drawer (Hidden on Desktop) */
        .mobile-menu-btn {
            display: none !important;
            background: none;
            border: none;
            cursor: pointer;
            padding: 8px;
            color: var(--primary);
        }

        .mobile-menu-drawer {
            display: none !important;
        }

        /* Flash Notifications */
        .flash-container {
            margin-top: 16px;
        }

        .flash-alert {
            display: flex;
            align-items: flex-start;
            gap: 14px;
            padding: 16px 20px;
            border-radius: var(--radius-md);
            font-size: 14px;
            font-weight: 500;
            margin-bottom: 20px;
            animation: fadeIn 0.3s ease;
        }

        .flash-success {
            background-color: var(--score-high-bg);
            color: var(--score-high);
            border: 1px solid #A7F3D0;
        }

        .flash-info {
            background-color: #EFF6FF;
            color: #1E40AF;
            border: 1px solid #BFDBFE;
        }

        .flash-error {
            background-color: var(--score-low-bg);
            color: var(--score-low);
            border: 1px solid #FECDD3;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-6px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* ===== MAIN CONTENT WRAPPER ===== */
        main {
            flex: 1;
        }

        /* ===== FOOTER (QUIET LUXURY) ===== */
        .site-footer {
            background-color: #FFFFFF;
            border-top: 1px solid var(--border);
            padding: 56px 0 32px 0;
            margin-top: 80px;
        }

        .footer-grid {
            display: grid;
            grid-template-columns: 2fr 1fr 1fr 1.2fr;
            gap: 40px;
            margin-bottom: 48px;
        }

        .footer-brand-desc {
            font-size: 13.5px;
            color: var(--text-secondary);
            margin-top: 14px;
            max-width: 340px;
            line-height: 1.6;
        }

        .footer-heading {
            font-size: 14px;
            font-weight: 700;
            color: var(--primary);
            letter-spacing: -0.2px;
            margin-bottom: 18px;
            text-transform: uppercase;
            font-size: 12px;
            letter-spacing: 0.6px;
        }

        .footer-nav {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .footer-nav a {
            font-size: 13.5px;
            color: var(--text-secondary);
        }

        .footer-nav a:hover {
            color: var(--primary);
            padding-left: 2px;
        }

        .footer-bottom {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding-top: 28px;
            border-top: 1px solid var(--border-subtle);
            font-size: 12.5px;
            color: var(--text-muted);
            flex-wrap: wrap;
            gap: 16px;
        }

        .footer-privacy-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 10px;
            border-radius: 20px;
            background: var(--canvas);
            border: 1px solid var(--border);
            font-size: 11.5px;
            font-weight: 600;
            color: var(--score-high);
        }

        /* ===== RESPONSIVE BREAKPOINTS ===== */
        @media (max-width: 900px) {
            .footer-grid {
                grid-template-columns: 1fr 1fr;
                gap: 32px;
            }
        }

        @media (max-width: 768px) {
            .nav-links, .nav-actions .desktop-only {
                display: none !important;
            }
            .mobile-menu-btn {
                display: block !important;
            }
            .mobile-menu-drawer {
                display: none !important;
                flex-direction: column;
                position: absolute;
                top: 72px;
                left: 0;
                width: 100%;
                background: #FFFFFF;
                border-bottom: 1px solid var(--border);
                padding: 20px 24px;
                box-shadow: var(--shadow-md);
            }
            .mobile-menu-drawer.open {
                display: flex !important;
            }
            .mobile-nav-list {
                list-style: none;
                display: flex;
                flex-direction: column;
                gap: 16px;
                margin-bottom: 20px;
                padding: 0;
            }
            .mobile-nav-list a {
                font-size: 15px;
                font-weight: 600;
                color: var(--text-primary);
            }
            .footer-grid {
                grid-template-columns: 1fr;
                gap: 28px;
            }
            .footer-bottom {
                flex-direction: column;
                align-items: flex-start;
            }
        }
    </style>

    @stack('styles')
</head>
<body>

    <!-- Header & Frosted Navigation -->
    <header class="header-navbar">
        <div class="container">
            <div class="nav-wrapper">
                <a href="{{ route('home') }}" class="brand-logo">
                    <div class="brand-icon">R</div>
                    <div class="brand-text">
                        <span class="brand-title">RESUMER</span>
                        <span class="brand-subtitle">AI ATS CV Maker</span>
                    </div>
                </a>

                <nav>
                    <ul class="nav-links">
                        <li><a href="{{ route('home') }}#features" class="nav-link">Fitur AI</a></li>
                        <li><a href="{{ route('home') }}#ats-standards" class="nav-link">Standar ATS</a></li>
                        <li><a href="{{ route('home') }}#how-it-works" class="nav-link">Cara Kerja</a></li>
                        <li><a href="{{ route('privacy-policy') }}" class="nav-link {{ request()->routeIs('privacy-policy') ? 'active' : '' }}">Kebijakan Privasi</a></li>
                        <li><a href="{{ route('disclaimer') }}" class="nav-link {{ request()->routeIs('disclaimer') ? 'active' : '' }}">Sanggahan</a></li>
                        <li><a href="{{ route('account-deletion') }}" class="nav-link {{ request()->routeIs('account-deletion') ? 'active' : '' }}">Hapus Akun</a></li>
                    </ul>
                </nav>

                <div class="nav-actions">
                    <a href="{{ route('download-apk') }}" class="btn btn-primary btn-sm desktop-only">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                        Unduh APK
                    </a>

                    <button class="mobile-menu-btn" id="mobileMenuBtn" aria-label="Buka Menu Navigasi">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="18" x2="21" y2="18"/></svg>
                    </button>
                </div>
            </div>
        </div>

        <!-- Mobile Drawer Menu -->
        <div class="mobile-menu-drawer" id="mobileDrawer">
            <ul class="mobile-nav-list">
                <li><a href="{{ route('home') }}#features">Fitur AI ATS</a></li>
                <li><a href="{{ route('home') }}#ats-standards">Standar Format ATS</a></li>
                <li><a href="{{ route('home') }}#how-it-works">Cara Kerja Aplikasi</a></li>
                <li><a href="{{ route('privacy-policy') }}">Kebijakan Privasi</a></li>
                <li><a href="{{ route('disclaimer') }}">Sanggahan (Disclaimer)</a></li>
                <li><a href="{{ route('account-deletion') }}">Permintaan Hapus Akun</a></li>
            </ul>
            <a href="{{ route('download-apk') }}" class="btn btn-primary" style="width: 100%;">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                Unduh Aplikasi (APK Android)
            </a>
        </div>
    </header>

    <!-- Global Alert Notifications -->
    @if(session('success') || session('info') || session('error') || $errors->any())
        <div class="container flash-container">
            @if(session('success'))
                <div class="flash-alert flash-success">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                    <div>{{ session('success') }}</div>
                </div>
            @endif

            @if(session('info'))
                <div class="flash-alert flash-info">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    <div>{{ session('info') }}</div>
                </div>
            @endif

            @if(session('error'))
                <div class="flash-alert flash-error">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                    <div>{{ session('error') }}</div>
                </div>
            @endif

            @if($errors->any())
                <div class="flash-alert flash-error">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                    <div>
                        <strong>Terdapat kesalahan pengisian formulir:</strong>
                        <ul style="margin-top: 4px; padding-left: 18px;">
                            @foreach($errors->all() as $err)
                                <li>{{ $err }}</li>
                            @endforeach
                        </ul>
                    </div>
                </div>
            @endif
        </div>
    @endif

    <!-- Main Body Content -->
    <main>
        @yield('content')
    </main>

    <!-- Executive Footer -->
    <footer class="site-footer">
        <div class="container">
            <div class="footer-grid">
                <div>
                    <a href="{{ route('home') }}" class="brand-logo">
                        <div class="brand-icon">R</div>
                        <div class="brand-text">
                            <span class="brand-title">RESUMER</span>
                            <span class="brand-subtitle">AI ATS CV Maker</span>
                        </div>
                    </a>
                    <p class="footer-brand-desc">
                        Aplikasi cerdas pembuat CV otomatis berstandar Applicant Tracking System (ATS), penganalisis skor kualifikasi, dan pencocok kualifikasi loker berbasis AI Google Gemini 2.5 Flash Lite.
                    </p>
                    <div style="margin-top: 14px;">
                        <span class="footer-privacy-pill">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                            100% Client-Side Photo & PDF Privacy
                        </span>
                    </div>
                </div>

                <div>
                    <h4 class="footer-heading">Navigasi Utama</h4>
                    <ul class="footer-nav">
                        <li><a href="{{ route('home') }}">Beranda</a></li>
                        <li><a href="{{ route('home') }}#features">Fitur Unggulan</a></li>
                        <li><a href="{{ route('home') }}#ats-standards">Standar Asian vs Western</a></li>
                        <li><a href="{{ route('home') }}#how-it-works">Panduan Penggunaan</a></li>
                        <li><a href="{{ route('download-apk') }}">Unduh APK Android</a></li>
                    </ul>
                </div>

                <div>
                    <h4 class="footer-heading">Kepatuhan Hukum</h4>
                    <ul class="footer-nav">
                        <li><a href="{{ route('privacy-policy') }}">Kebijakan Privasi</a></li>
                        <li><a href="{{ route('disclaimer') }}">Sanggahan (Disclaimer)</a></li>
                        <li><a href="{{ route('account-deletion') }}">Permintaan Hapus Akun</a></li>
                        <li><a href="mailto:privacy@cellanoma.my.id">Kontak Privasi</a></li>
                    </ul>
                </div>

                <div>
                    <h4 class="footer-heading">Teknologi & Keamanan</h4>
                    <p style="font-size: 13px; color: var(--text-secondary); line-height: 1.5; margin-bottom: 12px;">
                        Didukung oleh arsitektur Laravel 12 API Gateway, Google Gemini 2.5 Flash Lite strict JSON output, dan pemrosesan client-side di smartphone pengguna.
                    </p>
                    <div style="font-size: 12px; color: var(--text-muted);">
                        Developer: <strong>Cellanoma Studio</strong><br>
                        Versi: 1.0.0 (Bespoke Executive)
                    </div>
                </div>
            </div>

            <div class="footer-bottom">
                <div>
                    &copy; {{ date('Y') }} Resumer by Cellanoma Studio. Hak Cipta Dilindungi Undang-Undang.
                </div>
                <div>
                    Dirancang dengan prinsip <em>Quiet Luxury & Bespoke Executive</em>.
                </div>
            </div>
        </div>
    </footer>

    <!-- Mobile Drawer Toggle Script -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const btn = document.getElementById('mobileMenuBtn');
            const drawer = document.getElementById('mobileDrawer');
            if (btn && drawer) {
                btn.addEventListener('click', function() {
                    drawer.classList.toggle('open');
                });
            }
        });
    </script>

    @stack('scripts')
</body>
</html>
