package com.digibulkmarketing.telecaller_app

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.app.Activity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall
import android.app.KeyguardManager
import android.content.Context
import android.util.Log
import android.view.WindowManager
import android.os.Build
import android.os.PowerManager

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.digibulkmarketing.telecaller_app/lockscreen"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isScreenLocked" -> {
                    val keyguardManager =
                        getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
                    result.success(keyguardManager.isKeyguardLocked)
                }
                "wakeScreen" -> {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                            setTurnScreenOn(true)
                            setShowWhenLocked(true)
                        } else {
                            window.addFlags(
                                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                                        WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                                        WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                            )
                        }
                        Log.d("MainActivity", "Screen wake-up flags applied")
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e("MainActivity", "Failed to wake screen: ${e.message}")
                        result.error("WAKE_FAILED", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}