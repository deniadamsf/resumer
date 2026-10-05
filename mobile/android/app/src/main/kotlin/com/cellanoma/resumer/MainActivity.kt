package com.cellanoma.resumer

import android.annotation.SuppressLint
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val deviceChannel = "com.cellanoma.resumer/device"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, deviceChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getAndroidId" -> result.success(readAndroidId())
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * ANDROID_ID (Android 8+) bersifat unik per kombinasi signing key aplikasi + user + perangkat.
     * Tetap sama setelah uninstall/reinstall atau Clear Data; hanya berubah setelah factory reset.
     */
    @SuppressLint("HardwareIds")
    private fun readAndroidId(): String? {
        return try {
            val id = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
            // Abaikan nilai kosong & ID bug lama yang sama di banyak perangkat (Android 2.2).
            if (id.isNullOrBlank() || id == "9774d56d682e549c") null else id
        } catch (e: Exception) {
            null
        }
    }
}
