package com.digibulkmarketing.telecaller_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import id.flutter.flutter_background_service.BackgroundService

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED || 
            intent.action == "android.intent.action.QUICKBOOT_POWERON" ||
            intent.action == "com.htc.intent.action.QUICKBOOT_POWERON") {
            
            try {
                // ✅ Check if the user is logged in (has an active session token)
                val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                val token = prefs.getString("flutter.auth_token", null)
                
                if (!token.isNullOrEmpty()) {
                    Log.d("BootReceiver", "User is logged in. Starting background service...")
                    val serviceIntent = Intent(context, BackgroundService::class.java)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        context.startForegroundService(serviceIntent)
                    } else {
                        context.startService(serviceIntent)
                    }
                } else {
                    Log.d("BootReceiver", "Skipping background service start: User is not logged in.")
                }
            } catch (e: Exception) {
                Log.e("BootReceiver", "Error checking login status or starting background service: ${e.message}", e)
            }
        }
    }
}
