<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class VerifyHmacSignature
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Allow bypass in test mode if explicitly specified
        if (app()->environment('testing') && $request->header('X-Bypass-Hmac') === 'true') {
            return $next($request);
        }

        $secret = config('services.resumer.hmac_secret', env('RESUMER_HMAC_SECRET', 'resumer_super_secret_hmac_key_2026'));
        $signature = $request->header('X-Resumer-Signature');
        $timestamp = $request->header('X-Resumer-Timestamp');

        if (!$signature || !$timestamp) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized: Missing security signature headers.',
            ], 401);
        }

        // Check timestamp replay window (tolerance 5 minutes / 300 seconds)
        if (abs(time() - (int)$timestamp) > 300) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized: Request timestamp expired.',
            ], 401);
        }

        // Expected signature: hash_hmac('sha256', timestamp . '.' . rawBody, secret)
        $rawBody = $request->getContent();
        $payloadToSign = $timestamp . '.' . $rawBody;
        $expectedSignature = hash_hmac('sha256', $payloadToSign, $secret);

        if (!hash_equals($expectedSignature, $signature)) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized: Invalid signature.',
            ], 401);
        }

        return $next($request);
    }
}
