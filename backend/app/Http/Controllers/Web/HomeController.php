<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\File;

class HomeController extends Controller
{
    /**
     * Show the executive landing page.
     */
    public function index()
    {
        return view('landing');
    }

    /**
     * Download the latest released Android APK if available.
     */
    public function downloadApk()
    {
        $paths = [
            public_path('downloads/resumer-release.apk'),
            base_path('downloads/resumer-release.apk'),
            base_path('public/downloads/resumer-release.apk'),
            base_path('../Resumer-release.apk'),
        ];

        foreach ($paths as $path) {
            if (File::exists($path)) {
                return response()->download($path, 'Resumer-AI-ATS-CV-Maker.apk', [
                    'Content-Type' => 'application/vnd.android.package-archive',
                ]);
            }
        }

        // Direct static fallback URL
        return redirect('/downloads/resumer-release.apk');
    }
}
