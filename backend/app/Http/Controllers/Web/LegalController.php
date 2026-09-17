<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class LegalController extends Controller
{
    /**
     * Privacy Policy page for Google Play Store compliance & GDPR/CCPA.
     */
    public function privacyPolicy()
    {
        return view('privacy_policy');
    }

    /**
     * Official Legal Disclaimer regarding ATS predictions, AI outputs, and trademarks.
     */
    public function disclaimer()
    {
        return view('disclaimer');
    }
}
