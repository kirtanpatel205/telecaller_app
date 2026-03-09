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
        if (intent.action == TelephonyManager.ACTION_PHONE_STATE_CHANGED) {
            val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
            val incomingNumber = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)

            Log.d("PhoneStateReceiver", "📞 Native Call Event: $state | Number: $incomingNumber")

            try {
                val data = mutableMapOf<String, Any?>()
                data["state"] = state
                data["number"] = incomingNumber
                
                // Direct MethodChannel communication to the background engine
                val engineIds = listOf("flutter_background_service", "id.flutter.flutter_background_service.BackgroundService")
                
                var sent = false
                for (id in engineIds) {
                    val engine = FlutterEngineCache.getInstance().get(id)
                    if (engine != null) {
                        MethodChannel(engine.dartExecutor.binaryMessenger, "id.flutter.flutter_background_service").invokeMethod("native_phone_state", data)
                        Log.d("PhoneStateReceiver", "✅ Sent event to engine: $id")
                        sent = true
                        break
                    }
                }

                // Fallback: Write to SharedPreferences for background service to poll
                // This works even when FlutterJNI is detached and no engine is in cache
                if (!sent) {
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
}
