package com.digibulkmarketing.telecaller_app

import android.annotation.SuppressLint
import android.content.Context
import android.os.Build
import android.telephony.SubscriptionInfo
import android.telephony.SubscriptionManager
import android.telephony.TelephonyManager
import android.util.Log
import java.lang.reflect.Method

class SimDetectionHelper(private val context: Context) {

    companion object {
        private const val TAG = "SimDetectionHelper"
    }

    /**
     * Retrieves detailed information about all active SIM cards.
     * Implements multiple strategies to find phone numbers.
     */
    @SuppressLint("HardwareIds")
    fun getSimInfo(): List<Map<String, Any?>> {
        val simInfoList = mutableListOf<Map<String, Any?>>()
        Log.d(TAG, "Starting SIM detection. Android Version: ${Build.VERSION.SDK_INT}")

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
                val subscriptionManager = context.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
                val activeSubscriptionInfoList = try {
                    subscriptionManager.activeSubscriptionInfoList
                } catch (e: SecurityException) {
                    Log.e(TAG, "Permission denied for activeSubscriptionInfoList: ${e.message}")
                    null
                }

                if (activeSubscriptionInfoList.isNullOrEmpty()) {
                    Log.w(TAG, "No active subscriptions found via SubscriptionManager")
                    // Fallback to TelephonyManager for single SIM detection
                    val tm = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
                    if (tm.simState != TelephonyManager.SIM_STATE_ABSENT) {
                        simInfoList.add(getLegacySimInfo(tm))
                    }
                } else {
                    Log.d(TAG, "Found ${activeSubscriptionInfoList.size} active subscriptions")
                    for (info in activeSubscriptionInfoList) {
                        simInfoList.add(processSubscriptionInfo(info, subscriptionManager))
                    }
                }
            } else {
                Log.d(TAG, "Using legacy SIM detection for API < 22")
                val tm = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
                simInfoList.add(getLegacySimInfo(tm))
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error during SIM detection: ${e.message}", e)
        }

        Log.d(TAG, "SIM detection completed. Total detected: ${simInfoList.size}")
        return simInfoList
    }

    private fun processSubscriptionInfo(info: SubscriptionInfo, subscriptionManager: SubscriptionManager): Map<String, Any?> {
        val slotIndex = info.simSlotIndex
        val subId = info.subscriptionId
        val carrierName = info.carrierName?.toString() ?: "Unknown"
        val displayName = info.displayName?.toString() ?: "Unknown"
        
        // Robust ICCID retrieval
        var iccId: String? = null
        try {
            iccId = info.iccId
            if (iccId.isNullOrEmpty()) {
                val getIccIdMethod = info.javaClass.getDeclaredMethod("getIccId")
                iccId = getIccIdMethod.invoke(info) as? String
            }
        } catch (e: Exception) {
            // Silently fail
        }
        val finalIccId = iccId ?: "Unknown"
        
        Log.d(TAG, "--- Processing SIM Slot $slotIndex (SubID: $subId) ---")
        Log.d(TAG, "Carrier: $carrierName, Display Name: $displayName, ICCID: $finalIccId")

        var phoneNumber: String? = null
        var methodUsed = "None"

        // Strategy 1: Android 13+ (API 33) getPhoneNumber API
        if (Build.VERSION.SDK_INT >= 33) {
            try {
                phoneNumber = subscriptionManager.getPhoneNumber(subId)
                if (!phoneNumber.isNullOrEmpty()) {
                    methodUsed = "SubscriptionManager.getPhoneNumber()"
                    Log.d(TAG, "Strategy 1 Success: $phoneNumber")
                }
            } catch (e: Exception) {
                Log.w(TAG, "Strategy 1 failed: ${e.message}")
            }
        }

        // Strategy 2: TelephonyManager.getLine1Number() for specific subId
        if (phoneNumber.isNullOrEmpty()) {
            try {
                val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
                val subTM = telephonyManager.createForSubscriptionId(subId)
                phoneNumber = subTM.line1Number
                if (!phoneNumber.isNullOrEmpty()) {
                    methodUsed = "TelephonyManager.line1Number (subId)"
                    Log.d(TAG, "Strategy 2 Success: $phoneNumber")
                }
            } catch (e: Exception) {
                Log.w(TAG, "Strategy 2 failed: ${e.message}")
            }
        }

        // Strategy 3: SubscriptionInfo.number (Deprecated but still works on some older devices/ROMs)
        if (phoneNumber.isNullOrEmpty()) {
            try {
                // info.number is often null on modern Android, but worth checking
                val getNumberMethod = info.javaClass.getDeclaredMethod("getNumber")
                phoneNumber = getNumberMethod.invoke(info) as? String
                if (!phoneNumber.isNullOrEmpty()) {
                    methodUsed = "SubscriptionInfo.getNumber() (Reflection)"
                    Log.d(TAG, "Strategy 3 Success: $phoneNumber")
                }
            } catch (e: Exception) {
                // Silently fail as this is common
            }
        }

        // Strategy 4: System Properties (Common in Chinese OEMs like Xiaomi/Oppo)
        if (phoneNumber.isNullOrEmpty()) {
            try {
                val propKey = if (slotIndex == 0) "gsm.sim.line1.number" else "gsm.sim.line1.number.$slotIndex"
                val getPropMethod = Class.forName("android.os.SystemProperties").getMethod("get", String::class.java)
                val propValue = getPropMethod.invoke(null, propKey) as? String
                if (!propValue.isNullOrEmpty()) {
                    phoneNumber = propValue
                    methodUsed = "SystemProperties ($propKey)"
                    Log.d(TAG, "Strategy 4 Success: $phoneNumber")
                }
            } catch (e: Exception) {
                // Silently fail
            }
        }

        // Strategy 5: Fallback to global TelephonyManager if it's the only SIM or primary
        if (phoneNumber.isNullOrEmpty() && slotIndex == 0) {
            try {
                val tm = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
                phoneNumber = tm.line1Number
                if (!phoneNumber.isNullOrEmpty()) {
                    methodUsed = "Global TelephonyManager.line1Number"
                    Log.d(TAG, "Strategy 5 Success: $phoneNumber")
                }
            } catch (e: Exception) {}
        }

        return mapOf(
            "slotIndex" to slotIndex,
            "subscriptionId" to subId,
            "carrierName" to carrierName,
            "displayName" to displayName,
            "number" to phoneNumber,
            "iccId" to finalIccId,
            "methodUsed" to methodUsed,
            "simState" to getSimStateLabel(slotIndex),
            "isAvailable" to !phoneNumber.isNullOrEmpty()
        )
    }

    @SuppressLint("HardwareIds")
    private fun getLegacySimInfo(tm: TelephonyManager): Map<String, Any?> {
        Log.d(TAG, "Processing Legacy SIM")
        val number = try { tm.line1Number } catch (e: Exception) { null }
        return mapOf(
            "slotIndex" to 0,
            "subscriptionId" to 0,
            "carrierName" to tm.networkOperatorName,
            "displayName" to tm.simOperatorName,
            "number" to number,
            "iccId" to (try { tm.simSerialNumber } catch (e: Exception) { "Unknown" }),
            "methodUsed" to "Legacy TelephonyManager",
            "simState" to getSimStateLabel(0),
            "isAvailable" to !number.isNullOrEmpty()
        )
    }

    private fun getSimStateLabel(slotIndex: Int): String {
        val tm = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        val state = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            tm.getSimState(slotIndex)
        } else {
            tm.simState
        }

        return when (state) {
            TelephonyManager.SIM_STATE_ABSENT -> "ABSENT"
            TelephonyManager.SIM_STATE_NETWORK_LOCKED -> "NETWORK_LOCKED"
            TelephonyManager.SIM_STATE_PIN_REQUIRED -> "PIN_REQUIRED"
            TelephonyManager.SIM_STATE_PUK_REQUIRED -> "PUK_REQUIRED"
            TelephonyManager.SIM_STATE_READY -> "READY"
            TelephonyManager.SIM_STATE_UNKNOWN -> "UNKNOWN"
            else -> "OTHER ($state)"
        }
    }
}
