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
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
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
                "getSimInfo" -> {
                    try {
                        val simHelper = SimDetectionHelper(this)
                        val simInfoList = simHelper.getSimInfo()
                        result.success(simInfoList)
                    } catch (e: Exception) {
                        Log.e("MainActivity", "Failed to get SIM info: ${e.message}")
                        result.error("SIM_INFO_FAILED", e.message, null)
                    }
                }
                "makeDirectCall" -> {
                    val number = call.argument<String>("number")
                    val slotIndex = call.argument<Int>("slotIndex") // 0 or 1
                    
                    if (number != null) {
                        try {
                            makeCall(number, slotIndex)
                            result.success(true)
                        } catch (e: Exception) {
                            Log.e("MainActivity", "Call failed: ${e.message}")
                            result.error("CALL_FAILED", e.message, null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Number is null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun makeCall(number: String, slotIndex: Int?) {
        val uri = Uri.parse("tel:${Uri.encode(number)}")
        val intent = Intent(Intent.ACTION_CALL, uri)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        
        if (slotIndex != null) {
            Log.d("MainActivity", "Making call to $number using SIM slot $slotIndex")
            
            // Multi-SIM support extras (various manufacturers)
            val slotKey = if (slotIndex == 0) "0" else "1"
            
            intent.putExtra("com.android.phone.extra.slot", slotIndex)
            intent.putExtra("com.android.phone.force.slot", true)
            intent.putExtra("Slot", slotIndex)
            intent.putExtra("simSlot", slotIndex)
            intent.putExtra("sim_slot", slotIndex)
            intent.putExtra("subscription", slotIndex) // Some OEMs use slot as subId fallback
            
            // Samsung specific
            intent.putExtra("phone", slotIndex)
            
            // For newer Android versions using SubscriptionManager to find the actual subscription ID
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
                    val subscriptionManager = getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
                    val activeSubscriptionInfoList = try {
                        subscriptionManager.activeSubscriptionInfoList
                    } catch (e: SecurityException) {
                        null
                    }
                    
                    if (activeSubscriptionInfoList != null) {
                        for (subscriptionInfo in activeSubscriptionInfoList) {
                            if (subscriptionInfo.simSlotIndex == slotIndex) {
                                val subId = subscriptionInfo.subscriptionId
                                Log.d("MainActivity", "Found subId $subId for slot $slotIndex")
                                
                                // Standard Android extras for subscription ID
                                intent.putExtra("subscription", subId)
                                intent.putExtra("com.android.phone.extra.SUBSCRIPTION_ID", subId)
                                
                                // Samsung extras for subId
                                intent.putExtra("phone_id", subId)

                                // Set modern Telecom PhoneAccountHandle to completely bypass system Dual SIM selection dialog
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                    val telecomManager = getSystemService(Context.TELECOM_SERVICE) as android.telecom.TelecomManager
                                    val accounts = try {
                                        telecomManager.callCapablePhoneAccounts
                                    } catch (e: SecurityException) {
                                        Log.w("MainActivity", "Permission denied for callCapablePhoneAccounts: ${e.message}")
                                        null
                                    }
                                    
                                    if (accounts != null) {
                                        var matchedAccount: android.telecom.PhoneAccountHandle? = null
                                        val telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as android.telephony.TelephonyManager
                                        
                                        for (account in accounts) {
                                            // Method A: API 30+ official way
                                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                                                try {
                                                    val accountSubId = telephonyManager.getSubscriptionId(account)
                                                    if (accountSubId == subId) {
                                                        matchedAccount = account
                                                        Log.d("MainActivity", "Matched PhoneAccountHandle via getSubscriptionId: $account")
                                                        break
                                                    }
                                                } catch (e: Exception) {
                                                    Log.w("MainActivity", "Failed getSubscriptionId check: ${e.message}")
                                                }
                                            }
                                            
                                            // Method B: Fallback - Match by comparing account.id with subId string
                                            val accountId = account.id
                                            if (accountId != null) {
                                                if (accountId == subId.toString()) {
                                                    matchedAccount = account
                                                    Log.d("MainActivity", "Matched PhoneAccountHandle via subId string comparison: $account")
                                                    break
                                                }
                                                
                                                // Method C: Fallback - Match by comparing account.id with ICCID
                                                val iccId = subscriptionInfo.iccId
                                                if (iccId != null && iccId.isNotEmpty() && (accountId.contains(iccId) || iccId.contains(accountId))) {
                                                    matchedAccount = account
                                                    Log.d("MainActivity", "Matched PhoneAccountHandle via ICCID: $account")
                                                    break
                                                }
                                                
                                                // Method D: Fallback - Match by slotIndex in id (some ROMs use slotIndex e.g. "0" or "1")
                                                if (accountId == slotIndex.toString()) {
                                                    matchedAccount = account
                                                    Log.d("MainActivity", "Matched PhoneAccountHandle via slotIndex string: $account")
                                                    break
                                                }
                                            }
                                        }
                                        
                                        if (matchedAccount != null) {
                                            intent.putExtra("android.telecom.extra.PHONE_ACCOUNT_HANDLE", matchedAccount)
                                            Log.d("MainActivity", "Successfully set android.telecom.extra.PHONE_ACCOUNT_HANDLE: $matchedAccount")
                                        } else {
                                            Log.w("MainActivity", "Could not find a matching PhoneAccountHandle for subId $subId / slotIndex $slotIndex")
                                        }
                                    }
                                }
                                break
                            }
                        }
                    }
                }
            } catch (e: Exception) {
                Log.w("MainActivity", "Error getting subscription ID or PhoneAccountHandle: ${e.message}")
            }
        } else {
            Log.d("MainActivity", "Making call to $number using default SIM")
        }
        
        startActivity(intent)
    }
}