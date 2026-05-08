package com.digibulkmarketing.telecaller_app

import android.app.Application
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
import android.webkit.WebView
import android.webkit.RenderProcessGoneDetail
import android.telephony.SubscriptionManager
import android.telephony.SubscriptionInfo
import android.telephony.TelephonyManager

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.digibulkmarketing.telecaller_app/lockscreen"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        applyLockScreenFlags()

        // Safety net for modern Android: Isolate WebView data directories
        // if the app starts in multiple processes (common for background services).
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val processName = Application.getProcessName()
            if (packageName != processName) {
                WebView.setDataDirectorySuffix(processName)
            }
        }
    }

    override fun onResume() {
        super.onResume()
        applyLockScreenFlags()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        applyLockScreenFlags()
    }

    private fun applyLockScreenFlags() {
        // ✅ Apply lock screen flags so the app can show/resume over lock screen
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            try {
                val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    keyguardManager.requestDismissKeyguard(this, null)
                }
            } catch (e: Exception) {
                Log.e("MainActivity", "Failed to dismiss keyguard: ${e.message}")
            }
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                        WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                        WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
        }
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Register the main UI engine in the cache so other components can find it
        io.flutter.embedding.engine.FlutterEngineCache.getInstance().put("main_ui_engine", flutterEngine)

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
                "requestIgnoreBatteryOptimizations" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val packageName = packageName
                        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                        if (!pm.isIgnoringBatteryOptimizations(packageName)) {
                            val intent = Intent()
                            intent.action = android.provider.Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
                            intent.data = Uri.parse("package:$packageName")
                            startActivity(intent)
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    } else {
                        result.success(false)
                    }
                }
                "isXiaomi" -> {
                    val manufacturer = Build.MANUFACTURER
                    result.success(manufacturer.equals("Xiaomi", ignoreCase = true) || manufacturer.equals("Redmi", ignoreCase = true))
                }
                "openXiaomiPermissions" -> {
                    try {
                        val intent = Intent("miui.intent.action.APP_PERM_EDITOR")
                        intent.setClassName("com.miui.securitycenter", "com.miui.permcenter.permissions.PermissionsEditorActivity")
                        intent.putExtra("extra_pkgname", packageName)
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        try {
                            val intent = Intent("miui.intent.action.APP_PERM_EDITOR")
                            intent.putExtra("extra_pkgname", packageName)
                            startActivity(intent)
                            result.success(true)
                        } catch (e2: Exception) {
                            Log.e("MainActivity", "Failed to open Xiaomi permissions: ${e2.message}")
                            result.error("XIAOMI_PERM_FAILED", e2.message, null)
                        }
                    }
                }
                "openAutoStartSettings" -> {
                    val manufacturer = Build.MANUFACTURER.lowercase()
                    val intent = Intent()
                    when {
                        manufacturer.contains("xiaomi") -> {
                            intent.component = android.content.ComponentName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity")
                        }
                        manufacturer.contains("oppo") -> {
                            intent.component = android.content.ComponentName("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity")
                        }
                        manufacturer.contains("vivo") -> {
                            intent.component = android.content.ComponentName("com.vivo.permissionmanager", "com.vivo.permissionmanager.activity.BgStartUpManagerActivity")
                        }
                        manufacturer.contains("letv") -> {
                            intent.component = android.content.ComponentName("com.letv.android.letvsafe", "com.letv.android.letvsafe.AutobootManageActivity")
                        }
                        manufacturer.contains("huawei") -> {
                            intent.component = android.content.ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.optimize.process.ProtectActivity")
                        }
                    }
                    try {
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e("MainActivity", "Failed to open Auto-start settings: ${e.message}")
                        result.error("AUTOSTART_FAILED", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}