package com.digibulkmarketing.telecaller_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import android.os.Build

class CallReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val phoneNumber = intent.getStringExtra("phoneNumber")
        val slotIndex = intent.getIntExtra("slotIndex", -1)

        Log.d("CallReceiver", "Received broadcast for $phoneNumber (slot: $slotIndex)")

        if (phoneNumber != null) {
            val serviceIntent = Intent(context, CallService::class.java).apply {
                putExtra("phoneNumber", phoneNumber)
                putExtra("slotIndex", slotIndex)
            }
            
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(serviceIntent)
                } else {
                    context.startService(serviceIntent)
                }
                Log.d("CallReceiver", "Successfully started CallService")
            } catch (e: Exception) {
                Log.e("CallReceiver", "Failed to start CallService: ${e.message}")
            }
        }
    }
}
