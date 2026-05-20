package com.digibulkmarketing.telecaller_app

import android.app.*
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.*
import android.telephony.SubscriptionManager
import android.util.Log
import androidx.core.app.NotificationCompat

class CallService : Service() {

    private val CHANNEL_ID = "call_service_channel"
    private val NOTIFICATION_ID = 999
    private var handler: Handler? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val phoneNumber = intent?.getStringExtra("phoneNumber") ?: "Unknown Contact"
        val slotIndex = intent?.getIntExtra("slotIndex", -1) ?: -1

        // ✅ CRITICAL: Call startForeground IMMEDIATELY to avoid FGS startup crashes
        val notification = createNotification(phoneNumber)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            try {
                // On API 34+ we must specify FOREGROUND_SERVICE_TYPE_SPECIAL_USE (0x40000000)
                val type = if (Build.VERSION.SDK_INT >= 34) 0x40000000 else 0
                startForeground(NOTIFICATION_ID, notification, type)
                Log.d("CallService", "Started foreground service with type: $type")
            } catch (e: Exception) {
                Log.w("CallService", "Failed to start foreground with type: ${e.message}. Falling back to default.")
                startForeground(NOTIFICATION_ID, notification)
            }
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }

        if (phoneNumber == "Unknown Contact") {
            Log.w("CallService", "Received empty or null phone number, stopping service gracefully.")
            stopSelf()
            return START_NOT_STICKY
        }

        Log.d("CallService", "Starting 10-second delay for call to $phoneNumber")

        handler = Handler(Looper.getMainLooper())
        handler?.postDelayed({
            makeCall(phoneNumber, if (slotIndex == -1) null else slotIndex)
            stopSelf()
        }, 10000)

        return START_NOT_STICKY
    }

    private fun makeCall(phoneNumber: String, slotIndex: Int?) {
        try {
            Log.d("CallService", "Initiating background ACTION_CALL to $phoneNumber")
            val callIntent = Intent(Intent.ACTION_CALL)
            callIntent.data = Uri.parse("tel:${Uri.encode(phoneNumber)}")
            callIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

            if (slotIndex != null) {
                callIntent.putExtra("com.android.phone.extra.slot", slotIndex)
                callIntent.putExtra("com.android.phone.force.slot", true)
                callIntent.putExtra("Slot", slotIndex)
                callIntent.putExtra("simSlot", slotIndex)
                callIntent.putExtra("sim_slot", slotIndex)
                callIntent.putExtra("subscription", slotIndex)
                callIntent.putExtra("phone", slotIndex)

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

                                    // Set modern Telecom PhoneAccountHandle to completely bypass system Dual SIM selection dialog
                                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                        val telecomManager = getSystemService(Context.TELECOM_SERVICE) as android.telecom.TelecomManager
                                        val accounts = try {
                                            telecomManager.callCapablePhoneAccounts
                                        } catch (e: SecurityException) {
                                            Log.w("CallService", "Permission denied for callCapablePhoneAccounts: ${e.message}")
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
                                                            Log.d("CallService", "Matched PhoneAccountHandle via getSubscriptionId: $account")
                                                            break
                                                        }
                                                    } catch (e: Exception) {
                                                        Log.w("CallService", "Failed getSubscriptionId check: ${e.message}")
                                                    }
                                                }
                                                
                                                // Method B: Fallback - Match by comparing account.id with subId string
                                                val accountId = account.id
                                                if (accountId != null) {
                                                    if (accountId == subId.toString()) {
                                                        matchedAccount = account
                                                        Log.d("CallService", "Matched PhoneAccountHandle via subId string comparison: $account")
                                                        break
                                                    }
                                                    
                                                    // Method C: Fallback - Match by comparing account.id with ICCID
                                                    val iccId = info.iccId
                                                    if (iccId != null && iccId.isNotEmpty() && (accountId.contains(iccId) || iccId.contains(accountId))) {
                                                        matchedAccount = account
                                                        Log.d("CallService", "Matched PhoneAccountHandle via ICCID: $account")
                                                        break
                                                    }
                                                    
                                                    // Method D: Fallback - Match by slotIndex in id (some ROMs use slotIndex e.g. "0" or "1")
                                                    if (accountId == slotIndex.toString()) {
                                                        matchedAccount = account
                                                        Log.d("CallService", "Matched PhoneAccountHandle via slotIndex string: $account")
                                                        break
                                                    }
                                                }
                                            }
                                            
                                            if (matchedAccount != null) {
                                                callIntent.putExtra("android.telecom.extra.PHONE_ACCOUNT_HANDLE", matchedAccount)
                                                Log.d("CallService", "Successfully set android.telecom.extra.PHONE_ACCOUNT_HANDLE: $matchedAccount")
                                            } else {
                                                Log.w("CallService", "Could not find a matching PhoneAccountHandle for subId $subId / slotIndex $slotIndex")
                                            }
                                        }
                                    }
                                    break
                                }
                            }
                        }
                    }
                } catch (e: Exception) {
                    Log.w("CallService", "Error setting subId or PhoneAccountHandle: ${e.message}")
                }
            }

            startActivity(callIntent)
        } catch (e: Exception) {
            Log.e("CallService", "Error starting background call: ${e.message}")
        }
    }

    private fun createNotification(phoneNumber: String): Notification {
        val intent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Auto Call Task")
            .setContentText("Calling $phoneNumber in 10 seconds...")
            .setSmallIcon(R.mipmap.ic_launcher) // ✅ Use app's actual launcher icon
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_MAX) // ✅ Set to Max priority for maximum visibility
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Call Service Channel",
                NotificationManager.IMPORTANCE_HIGH // ✅ Change to High importance to pop up on screen
            ).apply {
                description = "Automated call tasks in progress"
                enableVibration(true)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        handler?.removeCallbacksAndMessages(null)
        super.onDestroy()
    }
}
