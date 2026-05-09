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
        val phoneNumber = intent?.getStringExtra("phoneNumber")
        val slotIndex = intent?.getIntExtra("slotIndex", -1) ?: -1

        if (phoneNumber.isNullOrEmpty()) {
            stopSelf()
            return START_NOT_STICKY
        }

        val notification = createNotification(phoneNumber)
        startForeground(NOTIFICATION_ID, notification)

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
                                    break
                                }
                            }
                        }
                    }
                } catch (e: Exception) {
                    Log.w("CallService", "Error setting subId: ${e.message}")
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
            .setSmallIcon(android.R.drawable.ic_menu_call)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Call Service Channel",
                NotificationManager.IMPORTANCE_DEFAULT
            )
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
