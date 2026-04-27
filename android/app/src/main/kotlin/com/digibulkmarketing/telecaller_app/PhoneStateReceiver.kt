package com.digibulkmarketing.telecaller_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.TelephonyManager
import android.util.Log
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class PhoneStateReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        Log.d("PhoneStateReceiver", "📡 Received broadcast: $action")

        if (action == "com.digibulkmarketing.telecaller_app.DIALER_CLOSED") {
            handleDialerClosed(context)
            return
        }

        if (action == TelephonyManager.ACTION_PHONE_STATE_CHANGED) {
            val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
            val incomingNumber = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)

            Log.d("PhoneStateReceiver", "📞 Native Call Event: $state | Number: $incomingNumber")

            try {
                val data = mutableMapOf<String, Any?>()
                data["state"] = state
                data["number"] = incomingNumber
                
                // Direct MethodChannel communication to the background engine
                val engineIds = listOf(
                    "flutter_background_service", 
                    "id.flutter.flutter_background_service.BackgroundService",
                    "main_ui_engine",
                    "cached_engine"
                )
                
                var backgroundEngineReached = false
                for (id in engineIds) {
                    val engine = FlutterEngineCache.getInstance().get(id)
                    if (engine != null) {
                        try {
                            MethodChannel(engine.dartExecutor.binaryMessenger, "id.flutter.flutter_background_service").invokeMethod("native_phone_state", data)
                            Log.d("PhoneStateReceiver", "✅ Sent native_phone_state to engine: $id")
                            if (id.contains("background_service")) {
                                backgroundEngineReached = true
                            }
                        } catch (e: Exception) {
                            Log.e("PhoneStateReceiver", "❌ Failed to send native_phone_state to $id: ${e.message}")
                        }
                    }
                }

                // Fallback: Write to SharedPreferences for background service to poll
                if (!backgroundEngineReached) {
                    Log.w("PhoneStateReceiver", "⚠️ No active background engine found in cache.")
                    try {
                        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                        val eventJson = JSONObject()
                        eventJson.put("state", state ?: "")
                        eventJson.put("number", incomingNumber ?: "")
                        eventJson.put("timestamp", System.currentTimeMillis())
                        prefs.edit().putString("flutter.pending_phone_event", eventJson.toString()).apply()
                        Log.d("PhoneStateReceiver", "🗒️ Wrote pending event to SharedPreferences: $state")
                    } catch (spEx: Exception) {
                        Log.e("PhoneStateReceiver", "❌ Failed to write to SharedPreferences: ${spEx.message}")
                    }
                }
            } catch (e: Exception) {
                Log.e("PhoneStateReceiver", "❌ Failed to send event to Flutter: ${e.message}")
            }
        }
    }
    private fun handleDialerClosed(context: Context) {
        Log.d("PhoneStateReceiver", "🏥 Handling dialer_closed event")
        try {
            val engineIds = listOf(
                "flutter_background_service", 
                "id.flutter.flutter_background_service.BackgroundService",
                "main_ui_engine",
                "cached_engine"
            )
            var backgroundEngineReached = false
            for (id in engineIds) {
                val engine = FlutterEngineCache.getInstance().get(id)
                if (engine != null) {
                    try {
                        MethodChannel(engine.dartExecutor.binaryMessenger, "id.flutter.flutter_background_service").invokeMethod("dialer_closed", null)
                        Log.d("PhoneStateReceiver", "✅ Sent dialer_closed to engine: $id")
                        if (id.contains("background_service")) {
                            backgroundEngineReached = true
                        }
                    } catch (e: Exception) {
                        Log.e("PhoneStateReceiver", "❌ Failed to send to engine $id: ${e.message}")
                    }
                }
            }
            if (!backgroundEngineReached) {
                Log.w("PhoneStateReceiver", "⚠️ Background engine not reached. Using SP fallback.")
                val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                val eventJson = JSONObject()
                eventJson.put("action", "dialer_closed")
                eventJson.put("timestamp", System.currentTimeMillis())
                prefs.edit().putString("flutter.pending_dialer_event", eventJson.toString()).apply()
            }
        } catch (e: Exception) {
            Log.e("PhoneStateReceiver", "❌ Error handling dialer_closed: ${e.message}")
        }
    }
}
