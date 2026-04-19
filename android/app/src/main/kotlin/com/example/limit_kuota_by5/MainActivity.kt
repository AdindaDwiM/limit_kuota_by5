package com.example.limit_kuota_by5

import android.app.usage.NetworkStatsManager
import android.app.usage.NetworkStats
import android.content.Context
import android.os.Build
import android.telephony.TelephonyManager
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

class MainActivity: FlutterActivity() {
    private val CHANNEL = "limit_kuota/channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->

            if (call.method == "getTodayUsage") {
                val usage = getTodayUsage()
                result.success(usage)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getTodayUsage(): Map<String, Long> {
        return mapOf(
            "wifi" to 300L * 1024 * 1024,
            "mobile" to 700L * 1024 * 1024
        )
    }
}