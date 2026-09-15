<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class PrivacyPolicyController extends Controller
{
    /**
     * Privacy Policy Page for Google Play Store Compliance.
     */
    public function show()
    {
        return response()->view('privacy_policy');
    }
}
