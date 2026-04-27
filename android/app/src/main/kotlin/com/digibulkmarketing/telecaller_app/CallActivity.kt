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
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class CallActivity : Activity() {
    private var callInitiated = false
    private var hasBeenPaused = false

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

        Log.d("CallActivity", "handleIntent - wakeOnly: $wakeOnly, isLocked: $isLocked")

        // ✅ 1. Apply lock screen flags immediately so any UI (Dialer/Activity) can show over lock screen
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                        WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                        WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
        }

        // ✅ 2. Handle wake-only request
        if (wakeOnly) {
            if (isLocked) {
                Log.d("CallActivity", "Waking screen only (Locked). Applying flags and staying alive to keep lock screen open.")
                // App opening removed as per user request
            } else {
                Log.d("CallActivity", "Waking screen only (Unlocked). Applying flags and staying alive to keep screen on.")
                // No need to launch MainActivity if screen is already unlocked
            }
            // DO NOT finish() here. Stay alive so the system keeps the screen awake and lock-screen dismissed.
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
        Log.d("CallActivity", "Waiting 1000ms for MainActivity to settle before dialer...")
        window.decorView.postDelayed({
            if (!isFinishing) {
                initiateCall(finalNumber)
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