package com.digibulkmarketing.telecaller_app

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.app.Activity
import android.app.KeyguardManager
import android.content.Context
import android.util.Log
import android.view.WindowManager
import android.os.Build
import android.telephony.SubscriptionManager
import android.telephony.SubscriptionInfo
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class CallActivity : Activity() {
    private var callInitiated = false
    private var hasBeenPaused = false
    private var selectedSlotIndex: Int = -1

    override fun onPause() {
        super.onPause()
        if (callInitiated) {
            hasBeenPaused = true
            Log.d("CallActivity", "onPause - Dialer or system dialog likely took focus")
        }
    }

    override fun onResume() {
        super.onResume()
        Log.d("CallActivity", "onResume - callInitiated: $callInitiated, hasBeenPaused: $hasBeenPaused")
        if (callInitiated && hasBeenPaused) {
            Log.d("CallActivity", "User returned to CallActivity after dial attempt. Notifying Flutter and bringing app to front.")
            notifyDialerClosed()
            
            // ✅ Bring MainActivity to front explicitly to ensure it resumes over lock screen
            // ✅ App opening removed as per user request to keep app in background
            /*
            try {
                val mainIntent = Intent(this, MainActivity::class.java)
                mainIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                startActivity(mainIntent)
            } catch (e: Exception) {
                Log.e("CallActivity", "❌ Failed to bring MainActivity to front: ${e.message}")
            }
            */
            
            finish()
        }
    }

    private fun notifyDialerClosed() {
        try {
            Log.d("CallActivity", "📣 Sending DIALER_CLOSED broadcast to PhoneStateReceiver")
            val intent = Intent(this, PhoneStateReceiver::class.java)
            intent.action = "com.digibulkmarketing.telecaller_app.DIALER_CLOSED"
            sendBroadcast(intent)
        } catch (e: Exception) {
            Log.e("CallActivity", "❌ Failed to send dialer_closed broadcast: ${e.message}")
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        if (intent == null) return

        val wakeOnly = intent.getBooleanExtra("wakeOnly", false)
        val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        val isLocked = keyguardManager.isKeyguardLocked
        
        // Extract slotIndex if present (from FCM/BackgroundService)
        selectedSlotIndex = intent.getIntExtra("slotIndex", -1)

        Log.d("CallActivity", "handleIntent - wakeOnly: $wakeOnly, isLocked: $isLocked, slotIndex: $selectedSlotIndex")

        // Lock screen flags removed as per user request to keep process background/silent.


        // ✅ 2. Handle wake-only request
        if (wakeOnly) {
            Log.d("CallActivity", "Waking screen only (isLocked=$isLocked). Flags applied. Auto-finishing in 2s.")
            // Stay alive briefly so the OS applies the lock-screen/wake flags,
            // then finish to avoid leaving a zombie activity in the back-stack.
            window.decorView.postDelayed({
                if (!isFinishing) {
                    Log.d("CallActivity", "wakeOnly: finishing now")
                    finish()
                }
            }, 2000)
            return
        }

        // ✅ 3. Extract Phone Number
        val phoneNumber = intent.getStringExtra("phoneNumber") ?: ""
        var finalNumber = phoneNumber

        if (finalNumber.isEmpty()) {
            val dataUri = intent.data
            if (dataUri != null && dataUri.scheme == "tel") {
                finalNumber = dataUri.schemeSpecificPart
            }
        }

        if (finalNumber.isEmpty()) {
            Log.e("CallActivity", "No phone number found. Finishing.")
            finish()
            return
        }

        // ✅ 4. Initiate Call
        
        // 1. Bring MainActivity to front (it will show over lock screen behind this translucent activity)
        // 1. App opening removed as per user request to keep app in background
        /*
        try {
            Log.d("CallActivity", "Bringing MainActivity to front...")
            val mainIntent = Intent(this, MainActivity::class.java)
            mainIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            startActivity(mainIntent)
        } catch (e: Exception) {
            Log.e("CallActivity", "❌ Failed to start MainActivity: ${e.message}")
        }
        */

        // 2. Wait 1 second before starting the dialer to avoid focus competition with SIM dialog
        Log.d("CallActivity", "Waiting 1000ms for dialer to start...")
        window.decorView.postDelayed({
            if (!isFinishing) {
                initiateCall(finalNumber, if (selectedSlotIndex == -1) null else selectedSlotIndex)
                callInitiated = true
                Log.d("CallActivity", "Call initiated after delay")
            }
        }, 1000)

        if (isLocked) {
            Log.d("CallActivity", "Screen is locked - CallActivity will stay alive (ShowWhenLocked) to detect return from dialer")
        } else {
            Log.d("CallActivity", "Screen is NOT locked - CallActivity will stay alive to detect return from dialer")
        }
    }

    private fun initiateCall(phoneNumber: String, slotIndex: Int?) {
        try {
            Log.d("CallActivity", "Initiating ACTION_CALL to $phoneNumber using slot ${slotIndex ?: "default"}")
            val callIntent = Intent(Intent.ACTION_CALL)
            callIntent.data = Uri.parse("tel:${Uri.encode(phoneNumber)}")
            callIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            
            if (slotIndex != null) {
                // Multi-SIM support extras
                callIntent.putExtra("com.android.phone.extra.slot", slotIndex)
                callIntent.putExtra("com.android.phone.force.slot", true)
                callIntent.putExtra("Slot", slotIndex)
                callIntent.putExtra("simSlot", slotIndex)
                callIntent.putExtra("sim_slot", slotIndex)
                callIntent.putExtra("subscription", slotIndex)
                callIntent.putExtra("phone", slotIndex)

                // Try to find subscription ID for better compatibility
                try {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
                        val sm = getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
                        val list = sm.activeSubscriptionInfoList
                        if (list != null) {
                            for (info in list) {
                                if (info.simSlotIndex == slotIndex) {
                                    val subId = info.subscriptionId
                                    callIntent.putExtra("subscription", subId)
                                    callIntent.putExtra("com.android.phone.extra.SUBSCRIPTION_ID", subId)
                                    callIntent.putExtra("phone_id", subId)
                                    Log.d("CallActivity", "Added subId $subId for slot $slotIndex")

                                    // Set modern Telecom PhoneAccountHandle to completely bypass system Dual SIM selection dialog
                                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                        val telecomManager = getSystemService(Context.TELECOM_SERVICE) as android.telecom.TelecomManager
                                        val accounts = try {
                                            telecomManager.callCapablePhoneAccounts
                                        } catch (e: SecurityException) {
                                            Log.w("CallActivity", "Permission denied for callCapablePhoneAccounts: ${e.message}")
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
                                                            Log.d("CallActivity", "Matched PhoneAccountHandle via getSubscriptionId: $account")
                                                            break
                                                        }
                                                    } catch (e: Exception) {
                                                        Log.w("CallActivity", "Failed getSubscriptionId check: ${e.message}")
                                                    }
                                                }
                                                
                                                // Method B: Fallback - Match by comparing account.id with subId string
                                                val accountId = account.id
                                                if (accountId != null) {
                                                    if (accountId == subId.toString()) {
                                                        matchedAccount = account
                                                        Log.d("CallActivity", "Matched PhoneAccountHandle via subId string comparison: $account")
                                                        break
                                                    }
                                                    
                                                    // Method C: Fallback - Match by comparing account.id with ICCID
                                                    val iccId = info.iccId
                                                    if (iccId != null && iccId.isNotEmpty() && (accountId.contains(iccId) || iccId.contains(accountId))) {
                                                        matchedAccount = account
                                                        Log.d("CallActivity", "Matched PhoneAccountHandle via ICCID: $account")
                                                        break
                                                    }
                                                    
                                                    // Method D: Fallback - Match by slotIndex in id (some ROMs use slotIndex e.g. "0" or "1")
                                                    if (accountId == slotIndex.toString()) {
                                                        matchedAccount = account
                                                        Log.d("CallActivity", "Matched PhoneAccountHandle via slotIndex string: $account")
                                                        break
                                                    }
                                                }
                                            }
                                            
                                            if (matchedAccount != null) {
                                                callIntent.putExtra("android.telecom.extra.PHONE_ACCOUNT_HANDLE", matchedAccount)
                                                Log.d("CallActivity", "Successfully set android.telecom.extra.PHONE_ACCOUNT_HANDLE: $matchedAccount")
                                            } else {
                                                Log.w("CallActivity", "Could not find a matching PhoneAccountHandle for subId $subId / slotIndex $slotIndex")
                                            }
                                        }
                                    }
                                    break
                                }
                            }
                        }
                    }
                } catch (e: Exception) {
                    Log.w("CallActivity", "Error setting subId or PhoneAccountHandle: ${e.message}")
                }
            }

            startActivity(callIntent)
            Log.d("CallActivity", "ACTION_CALL intent started successfully")
        } catch (e: Exception) {
            Log.e("CallActivity", "Error starting ACTION_CALL: ${e.message}")
            try {
                Log.d("CallActivity", "Attempting fallback to ACTION_DIAL")
                val dialIntent = Intent(Intent.ACTION_DIAL)
                dialIntent.data = Uri.parse("tel:$phoneNumber")
                dialIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(dialIntent)
                Log.d("CallActivity", "ACTION_DIAL intent started successfully")
            } catch (e2: Exception) {
                Log.e("CallActivity", "Error starting ACTION_DIAL: ${e2.message}")
            }
        }
    }
}