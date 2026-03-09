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

class CallActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // ✅ Check if screen is locked
        val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        val isLocked = keyguardManager.isKeyguardLocked

        if (isLocked) {
            // Screen is locked: initiate call silently, do NOT unlock or show app
            Log.d("CallActivity", "Screen is locked — initiating call without unlocking")

            val phoneNumber = intent.getStringExtra("phoneNumber")
            Log.d("CallActivity", "phoneNumber from intent: $phoneNumber")

            if (phoneNumber != null && phoneNumber.isNotEmpty()) {
                initiateCall(phoneNumber)
            } else {
                val dataUri = intent.data
                if (dataUri != null && dataUri.scheme == "tel") {
                    val num = dataUri.schemeSpecificPart
                    Log.d("CallActivity", "Extracted number from data URI: $num")
                    initiateCall(num)
                } else {
                    Log.e("CallActivity", "No phone number found")
                }
            }

            // Finish immediately — stay hidden behind lockscreen
            finish()
            return
        }

        // ✅ Screen is NOT locked — normal flow
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                        WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                        WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
        }

        val phoneNumber = intent.getStringExtra("phoneNumber")
        Log.d("CallActivity", "onCreate - phoneNumber from intent: $phoneNumber")

        if (phoneNumber != null && phoneNumber.isNotEmpty()) {
            initiateCall(phoneNumber)
        } else {
            Log.e("CallActivity", "Phone number is null or empty in intent extras")
            val dataUri = intent.data
            if (dataUri != null && dataUri.scheme == "tel") {
                val num = dataUri.schemeSpecificPart
                Log.d("CallActivity", "Extracted number from data URI: $num")
                initiateCall(num)
            } else {
                Log.e("CallActivity", "No phone number found in extras or data URI")
            }
        }

        window.decorView.postDelayed({
            Log.d("CallActivity", "Finishing CallActivity")
            finish()
        }, 800)
    }

    private fun initiateCall(phoneNumber: String) {
        try {
            Log.d("CallActivity", "Initiating ACTION_CALL to $phoneNumber")
            val callIntent = Intent(Intent.ACTION_CALL)
            callIntent.data = Uri.parse("tel:$phoneNumber")
            callIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
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