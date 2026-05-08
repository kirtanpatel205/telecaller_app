import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:telecaller_app/constants/app_constants.dart';
import 'package:telecaller_app/core/controllers/socket_controller.dart';
import 'package:telecaller_app/core/helpers/storage.dart';
import 'package:telecaller_app/firebase_options.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:telecaller_app/core/services/phone_status_service.dart';
import 'package:telecaller_app/core/services/internetcheck.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:isolate';
import 'package:call_log/call_log.dart';
import 'package:telecaller_app/core/services/api_service.dart';
import 'package:workmanager/workmanager.dart';
import 'package:sim_card_code/sim_card_code.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    await GetStorage.init();
    print("🛠️ [Workmanager] Background task started: $task");
    
    try {
      // 1. Restart Service if needed
      final service = FlutterBackgroundService();
      bool isRunning = await service.isRunning();
      if (!isRunning) {
        print("🛠️ [Workmanager] Background service not running. Restarting...");
        await BackgroundServiceManager.initializeService();
      }

      // 2. Sync Call Logs if this is a sync task or periodic watchdog
      print("📋 [Workmanager] Triggering call log sync...");
      await _syncCallLogs();
      
    } catch (e) {
      print("❌ [Workmanager] Error in task execution: $e");
    }
    return Future.value(true);
  });
}

@pragma('vm:entry-point')
class BackgroundServiceManager {
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    /// OPTIONAL, use custom notification channel id
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'my_foreground', // id
      'Telecaller Background Service', // title
      description: 'Maintains socket connection for real-time tracking.',
      importance: Importance.max, // High importance for persistent service
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'my_foreground',
        initialNotificationTitle: 'Telecaller Service',
        initialNotificationContent: 'Running in background',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    service.startService();

    // Register Workmanager watchdog
    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );
      await Workmanager().registerPeriodicTask(
        "bg_service_watchdog",
        "bg_service_watchdog_task",
        frequency: const Duration(minutes: 15),
        existingWorkPolicy: ExistingWorkPolicy.keep,
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );
      print("✅ [Background] Workmanager watchdog registered.");
    } catch (e) {
      print("❌ [Background] Workmanager init failed: $e");
    }
  }

  static const _channel = MethodChannel(
    'com.digibulkmarketing.telecaller_app/lockscreen',
  );

  static Future<void> optimizeForXiaomi() async {
    try {
      final bool isXiaomi = await _channel.invokeMethod('isXiaomi');
      if (isXiaomi) {
        // 1. Auto-start screen
        await const AndroidIntent(
          action: 'miui.intent.action.OP_AUTO_START_SETTINGS',
          package: 'com.miui.securitycenter',
        ).launch().catchError((e) => print("Failed to open Auto-start: $e"));

        await Future.delayed(const Duration(seconds: 1));

        // 2. Battery Saver (No restrictions) screen
        await const AndroidIntent(
          action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
          data: 'package:com.digibulkmarketing.telecaller_app',
        ).launch().catchError((e) => print("Failed to open App Details: $e"));

        await Future.delayed(const Duration(seconds: 1));

        // 3. NEW: Xiaomi Other Permissions (Display pop-up windows in background)
        await openXiaomiOtherPermissions();
      }
    } catch (e) {
      print("Error in optimizeForXiaomi: $e");
    }
  }

  static Future<void> fetchAndSaveSimInfo() async {
    try {

      // =========================
      // PHONE PERMISSION CHECK
      // =========================

      final phonePermission =
      await Permission.phone.status;

      if (!phonePermission.isGranted) {

        final result =
        await Permission.phone.request();

        if (!result.isGranted) {
          print("❌ [SIM] Phone permission denied");
          return;
        }
      }

      // =========================
      // FETCH SIM INFO
      // =========================

      final List<SimCardInfo> simCards =
      await SimCardManager.allSimInfo;

      if (simCards.isNotEmpty) {

        final List<Map<String, dynamic>> simInfoList =
        simCards.map<Map<String, dynamic>>((sim) => {

          'slotIndex': sim.slotIndex,
          'displayName': sim.displayName,
          'carrierName': sim.carrierName,
          'number': sim.phoneNumber,
          'subscriptionId': sim.subscriptionId,

        }).toList();

        print(
            "📱 [SIM] Fetched ${simInfoList.length} SIM slots"
        );

        await GetStorage().write(
          'sim_info_cache',
          simInfoList,
        );

        await Storage.saveSimInfo(simInfoList);

      } else {

        print(
            "ℹ️ [SIM] No SIM cards detected."
        );
      }

    } catch (e) {

      final errorStr = e.toString();

      if (errorStr.contains("MissingPluginException") ||
          errorStr.contains("no_implementation")) {

        print(
            "ℹ️ [SIM] Native channel not available."
        );

      } else {

        print(
            "⚠️ [SIM] Error fetching SIM info: $e"
        );
      }
    }
  }
  static Future<void> openXiaomiOtherPermissions() async {
    try {
      await _channel.invokeMethod('openXiaomiPermissions');
    } catch (e) {
      print("Error opening Xiaomi other permissions: $e");
    }
  }

  static Future<void> requestBatteryOptimization() async {
    try {
      await _channel.invokeMethod('requestIgnoreBatteryOptimizations');
    } catch (e) {
      print("Error requesting battery optimization: $e");
    }
  }

  static Future<void> openManufacturerSettings() async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('openAutoStartSettings');
      } catch (e) {
        print("Failed to open auto-start settings via MethodChannel: $e");
        // Fallback to manual intents
        final intents = [
          // Xiaomi Auto-start
          const AndroidIntent(
            action: 'miui.intent.action.OP_AUTO_START_SETTINGS',
            package: 'com.miui.securitycenter',
          ),
          // Generic App Details for Battery Saver
          const AndroidIntent(
            action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
            data: 'package:com.digibulkmarketing.telecaller_app',
          ),
          // General Battery Optimization
          const AndroidIntent(
            action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
          ),
        ];

        for (var intent in intents) {
          try {
            await intent.launch();
            break;
          } catch (e) {
            print("Failed to launch intent: $e");
          }
        }
      }
    }
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  // ✅ FORCED FOREGROUND for Xiaomi/HyperOS
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  // In-memory token cache — survives GetStorage/SharedPrefs race conditions
  String? _cachedToken;

  // Initialize storage for token retrieval
  await GetStorage.init();

  // Diagnostic: Print all keys in default GetStorage
  try {
    final keys = GetStorage().getKeys();
    print("📦 [Background] Storage Keys: $keys");

    final String? token = await Storage.getToken();
    _cachedToken = token;
    print(
      "🔑 [Background] Token found: ${token != null} (length: ${token?.length ?? 0})",
    );
  } catch (e) {
    print("⚠️ [Background] Error probing storage: $e");
  }

  // For firebase messaging in background service
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize NetworkService for connectivity awareness
  if (!Get.isRegistered<NetworkService>()) {
    Get.put(NetworkService());
  }

  // Initialize SocketController for background
  SocketController.isBackground = true;
  SocketController.backgroundServiceInstance = service;
  final socket = SocketController();
  Get.put(socket);

  // Initialize ApiService for background
  if (!Get.isRegistered<ApiService>()) {
    print("🚀 Initializing ApiService in background...");
    final apiService = ApiService();
    await apiService.init();
    Get.put<ApiService>(apiService);

    // Refresh SIM info inside the background isolate to ensure cache is current
    await BackgroundServiceManager.fetchAndSaveSimInfo();
    print("📱 [Background] Native SIM info cached.");
  }

  // Register this Master isolate's SendPort so Satellites can proxy emissions to us
  final ReceivePort socketPort = ReceivePort();
  IsolateNameServer.removePortNameMapping('socket_master_port');
  IsolateNameServer.registerPortWithName(
    socketPort.sendPort,
    'socket_master_port',
  );

  socketPort.listen((message) {
    if (message is Map) {
      final event = message['event'] as String?;
      final data = message['data'] as Map<String, dynamic>?;
      if (event != null && data != null) {
        print(
          "📥 [Background Master] Received proxy emission from SendPort: $event",
        );
        socket.socket?.emit(event, data);
      }
    }
  });

  try {
    // Initialize PhoneStatusService for background tracking
    if (!Get.isRegistered<PhoneStatusService>()) {
      print("🚀 Initializing PhoneStatusService in background...");
      final phoneService = PhoneStatusService();
      await phoneService.init(isBackground: true);
      Get.put<PhoneStatusService>(phoneService);
    }
  } catch (e) {
    print("❌ Background initialization error: $e");
  }

  // Listen for native phone state events from PhoneStateReceiver
  service.on('native_phone_state').listen((event) {
    print("📥 Background native_phone_state received: $event");
    if (event != null && Get.isRegistered<PhoneStatusService>()) {
      final phoneService = Get.find<PhoneStatusService>();
      final state = event['state'] as String?;
      final number = event['number'] as String?;

      phoneService.handleNativeEvent(state: state, number: number);
    }
  });

  service.on('dialer_closed').listen((event) {
    print("📥 Background dialer_closed received");
    if (Get.isRegistered<PhoneStatusService>()) {
      Get.find<PhoneStatusService>().handleDialerClosed();
    }
  });

  // ================= SOCKET PROXY HANDLERS =================
  service.on('socket_emit').listen((event) {
    if (event != null && Get.isRegistered<SocketController>()) {
      final socket = Get.find<SocketController>();
      final String? eventName = event['event'];
      final Map<String, dynamic>? data = event['data'];

      if (eventName != null && data != null) {
        print("📤 Background Socket Proxy Emit: $eventName");
        socket.socket?.emit(eventName, data);
      }
    }
  });

  service.on('get_socket_status').listen((_) {
    if (Get.isRegistered<SocketController>()) {
      Get.find<SocketController>().broadcastStatus();
    }
  });

  service.on('ensure_socket_connected').listen((_) {
    if (Get.isRegistered<SocketController>()) {
      Get.find<SocketController>().ensureConnected();
    }
  });

  // Listen for lead info from foreground
  service.on('set_lead_info').listen((event) {
    print("📥 Background set_lead_info received: $event");
    if (event != null) {
      if (Get.isRegistered<PhoneStatusService>()) {
        final phoneStatusService = Get.find<PhoneStatusService>();
        if (event['leadId'] != null) {
          phoneStatusService.currentLeadId = event['leadId'];
          print("✅ Background currentLeadId updated: ${event['leadId']}");
        }
        if (event['leadContactId'] != null) {
          phoneStatusService.currentLeadContactId = event['leadContactId'];
          print(
            "✅ Background currentLeadContactId updated: ${event['leadContactId']}",
          );
        }
        if (event['callSessionId'] != null) {
          phoneStatusService.setExternalCallSessionId(event['callSessionId']);
          print(
            "✅ Background callSessionId updated: ${event['callSessionId']}",
          );
        }
        if (event['phoneNumber'] != null) {
          // New: Explicitly track the number we are supposed to call
          phoneStatusService.targetPhoneNumber.value = event['phoneNumber'];
          print(
            "✅ Background targetPhoneNumber updated: ${event['phoneNumber']}",
          );
        }
      } else {
        print("⚠️ Background: PhoneStatusService not registered yet");
      }
    }
  });

  // Listen for token sync from foreground
  service.on('set_token').listen((event) async {
    print(
      "🔑 Background set_token received: ${event?['token']?.toString()?.length ?? 0} chars",
    );
    if (event != null && event['token'] != null) {
      final String newToken = event['token'];
      _cachedToken = newToken;

      // Save for future reboots in this isolate using reliable SharedPrefs
      await Storage.saveToken(newToken);
      print("✅ [Background] Token updated in storage for ApiService.");

      // Ensure ApiService is ready and initialized in this isolate
      if (!Get.isRegistered<ApiService>()) {
        print("🚀 [Background] Initializing ApiService after set_token...");
        final apiService = ApiService();
        await apiService.init();
        Get.put<ApiService>(apiService);
      }

      if (Get.isRegistered<SocketController>()) {
        Get.find<SocketController>().connectWithToken(newToken);
      }
    }
  });

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "Telecaller Service",
      content: "Service is active and monitoring tasks",
    );
  }

  // Diagnostic Heartbeat
  print("💓 Background Service Started: ${DateTime.now()}");
  // Sync Call Logs every 15 minutes
  Timer.periodic(const Duration(minutes: 15), (timer) async {
    print("🕒 [Background] Starting periodic call log sync...");
    try {
      await _syncCallLogs();
    } catch (e) {
      print("❌ [Background] Periodic sync failed: $e");
    }
  });
  // Poll SharedPreferences for native phone events (from PhoneStateReceiver fallback)
  // Interval reduced to 500ms for near-instant response to dialer cancellations
  Timer.periodic(const Duration(milliseconds: 500), (timer) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload(); // Force fresh read
      final pendingEvent = prefs.getString('pending_phone_event');
      if (pendingEvent != null && pendingEvent.isNotEmpty) {
        print(
          "📥 [SharedPrefs Bridge] Found pending phone event: $pendingEvent",
        );
        final event = json.decode(pendingEvent);
        final timestamp = event['timestamp'] as int? ?? 0;
        // Only process if recent (< 60 seconds old)
        if (DateTime.now().millisecondsSinceEpoch - timestamp < 60000) {
          if (Get.isRegistered<PhoneStatusService>()) {
            print(
              "🌉 [Bridge] Processing pending event: ${event['state']} for ${event['number']}",
            );
            Get.find<PhoneStatusService>().handleNativeEvent(
              state: event['state'],
              number: event['number'],
            );
            print("✅ [Bridge] Successfully dispatched: ${event['state']}");
          }
        } else {
          print(
            "⏰ [Bridge] Stale event discarded: ${event['state']} (${(DateTime.now().millisecondsSinceEpoch - timestamp) / 1000}s old)",
          );
        }
        // Clear the pending event
        await prefs.remove('pending_phone_event');
      }

      // 🌉 [Bridge] Poll for pending dialer closed events
      final pendingDialerEvent = prefs.getString('pending_dialer_event');
      if (pendingDialerEvent != null && pendingDialerEvent.isNotEmpty) {
        print("📥 [SharedPrefs Bridge] Found pending dialer event");
        final event = json.decode(pendingDialerEvent);
        final timestamp = event['timestamp'] as int? ?? 0;
        if (DateTime.now().millisecondsSinceEpoch - timestamp < 60000) {
          if (Get.isRegistered<PhoneStatusService>()) {
            Get.find<PhoneStatusService>().handleDialerClosed();
          }
        }
        await prefs.remove('pending_dialer_event');
      }
    } catch (e) {
      // Silent — don't spam logs on every tick
    }
  });

  // 🚨 Maintain foreground status silently without updating notification content
  Timer.periodic(const Duration(minutes: 5), (timer) async {
    if (service is AndroidServiceInstance) {
      bool isForeground = await service.isForegroundService();
      if (!isForeground) {
        print("⚠️ [Background] Service lost foreground status! Re-applying...");
        service.setAsForegroundService();
      }
    }
    
    // Ensure socket is still alive
    if (Get.isRegistered<SocketController>()) {
      Get.find<SocketController>().ensureConnected();
    }
  });
}

// ============================================================
//  _syncCallLogs  –  Production-grade SIM detection
//  Fixes: hardcoded SIM2, unknown SIM inclusion, duplicates,
//         SIM number reliability, pattern mismatch, weak exclusion,
//         performance loops, logging, empty fields, cache issues
// ============================================================

Future<void> _syncCallLogs() async {
  try {
    print("📋 [Sync] ══════════════ START ══════════════");

    final now     = DateTime.now();
    final storage = GetStorage();

    // ── Permission check ─────────────────────────────────────────────────────
    if (!(await Permission.phone.isGranted)) {
      print("🚫 [Sync] PHONE permission not granted. Aborting.");
      return;
    }

    // ── Search window ────────────────────────────────────────────────────────
    final int? lastSyncMs = storage.read<int>('last_call_log_sync_timestamp');
    final DateTime searchWindow = lastSyncMs != null
        ? DateTime.fromMillisecondsSinceEpoch(lastSyncMs)
        .subtract(const Duration(minutes: 5))
        : now.subtract(const Duration(days: 30));

    print("📋 [Sync] Window: ${searchWindow.toIso8601String()} → ${now.toIso8601String()}");

    // ── Fetch call log entries (NO full-history fallback) ────────────────────
    Iterable<CallLogEntry> entries;
    try {
      entries = await CallLog.query(
        dateFrom: searchWindow.millisecondsSinceEpoch,
      );
    } catch (e) {
      print("❌ [Sync] CallLog.query failed: $e");
      return;
    }

    if (entries.isEmpty) {
      print("ℹ️ [Sync] No new logs in window. Saving timestamp.");
      await _saveTimestamp(storage, now);
      return;
    }

    print("📋 [Sync] Raw entries fetched: ${entries.length}");

    // ── SIM info cache ───────────────────────────────────────────────────────
    // 1. Try reliable SharedPreferences cache first
    List<dynamic>? cachedSimInfo = await Storage.getSimInfo();
    
    // 2. Fallback to GetStorage cache
    if (cachedSimInfo == null || cachedSimInfo.isEmpty) {
      cachedSimInfo = storage.read<List>('sim_info_cache');
    }

    // 3. If both empty, try to fetch (will only work in UI isolate)
    if (cachedSimInfo == null || cachedSimInfo.isEmpty) {
      print("⚠️ [Sync] SIM cache empty — fetching fresh...");
      await BackgroundServiceManager.fetchAndSaveSimInfo();
      
      // Try reading again after fetch
      cachedSimInfo = await Storage.getSimInfo();
      if (cachedSimInfo == null || cachedSimInfo.isEmpty) {
        cachedSimInfo = storage.read<List>('sim_info_cache');
      }
    }

    if (cachedSimInfo == null || cachedSimInfo.isEmpty) {
      print("❌ [Sync] SIM info unavailable after fetch. Aborting.");
      return;
    }

    print("📋 [Sync] SIM slots available: ${cachedSimInfo.length}");

    // ── Build fingerprint map: slotIndex → _SimFingerprint ───────────────────
    final Map<int, _SimFingerprint> fpMap = _buildFingerprintMap(cachedSimInfo);

    if (fpMap.isEmpty) {
      print("❌ [Sync] Could not build any SIM fingerprint. Aborting.");
      return;
    }

    final int? selectedSlot = await Storage.getFromSharedPrefs<int>('selected_sim_slot_index');
    final bool isDualSim  = fpMap.length > 1;
    final int  targetSlot = selectedSlot ?? (isDualSim ? 1 : 0);

    final _SimFingerprint? targetFp = fpMap[targetSlot];
    if (targetFp == null) {
      print("❌ [Sync] No fingerprint for target slot=$targetSlot. Aborting.");
      return;
    }

    // Pre-compute SIM1 accountIds for O(1) exclusion lookup
    final Set<String> sim1AccountIds = fpMap[0]?.accountIds ?? {};

    print("🎯 [Sync] Target: SIM${targetSlot + 1}  number=${targetFp.displayNumber}");
    print("🎯 [Sync] Known accountIds: ${targetFp.accountIds}");

    // ── Dedup set from previous sync overlap ────────────────────────────────
    // Key = "phone|timestamp" prevents duplicates from the 5-min overlap window
    final Set<String> syncedKeys = Set<String>.from(
      storage.read<List>('last_synced_call_keys') ?? [],
    );
    final Set<String> newKeys = {};

    // ── Process entries ──────────────────────────────────────────────────────
    final List<Map<String, dynamic>> logs = [];

    for (final entry in entries) {

      // Skip entries with no timestamp
      if (entry.timestamp == null) {
        print("⚠️ [Sync] Skip: null timestamp — phone=${entry.number}");
        continue;
      }

      // Dedup check
      final String callKey = "${entry.number ?? ''}|${entry.timestamp}";
      if (syncedKeys.contains(callKey)) {
        print("⏭️ [Sync] Skip duplicate: $callKey");
        continue;
      }

      final String accountId = (entry.phoneAccountId ?? "").trim();
      final String simName   = (entry.simDisplayName  ?? "").toLowerCase().trim();

      // Single SIM: every call is the target SIM — no matching needed
      final bool isTarget = !isDualSim
          ? true
          : _matchesSim(
        accountId:      accountId,
        simName:        simName,
        targetFp:       targetFp,
        sim1AccountIds: sim1AccountIds,
      );

      if (!isTarget) {
        print("⏭️ [Sync] Skip (not SIM${targetSlot + 1}): "
            "accountId='$accountId' simName='$simName'");
        continue;
      }

      newKeys.add(callKey);

      logs.add({
        "callType":  _mapCallType(entry.callType),
        "name":      _safeStr(entry.name,   fallback: "Unknown"),
        "duration":  entry.duration ?? 0,
        "phone":     _safeStr(entry.number, fallback: ""),
        "timeStamp": DateTime.fromMillisecondsSinceEpoch(entry.timestamp!)
            .toIso8601String(),
        "simNumber": targetFp.displayNumber,
      });
    }

    print("📋 [Sync] Matched SIM${targetSlot + 1} logs: ${logs.length}");

    // ── Send to API ──────────────────────────────────────────────────────────
    if (logs.isNotEmpty) {
      print("🚀 [Sync] Sending ${logs.length} logs to API...");
      try {
        final apiService = Get.isRegistered<ApiService>()
            ? Get.find<ApiService>()
            : Get.put(ApiService()..init());

        final response = await apiService.syncCallLogs({"logs": logs});
        print("✅ [Sync] API: ${response.status} — ${response.message}");

        // Persist dedup keys — cap at 500 to prevent unbounded storage growth
        final List<String> merged = [...syncedKeys, ...newKeys];
        await storage.write(
          'last_synced_call_keys',
          merged.length > 500 ? merged.sublist(merged.length - 500) : merged,
        );
      } catch (e) {
        print("❌ [Sync] API error: $e  — timestamp NOT saved, will retry.");
        return; // Do not save timestamp on API failure → retry next cycle
      }
    } else {
      print("ℹ️ [Sync] No SIM${targetSlot + 1} logs matched.");
    }

    await _saveTimestamp(storage, now);
    print("📋 [Sync] ══════════════  END  ══════════════");

  } catch (e, st) {
    print("❌ [Sync] Unhandled error: $e\n$st");
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SIM matching — 5 layers, hard exclusion first
// ─────────────────────────────────────────────────────────────────────────────
bool _matchesSim({
  required String          accountId,
  required String          simName,
  required _SimFingerprint targetFp,
  required Set<String>     sim1AccountIds,
}) {

  // ── L1: Hard exclusion — confirmed SIM1 entry ────────────────────────────
  // Check FIRST to prevent any false positives downstream
  if (accountId.isNotEmpty && sim1AccountIds.contains(accountId)) {
    print("🚫 [Sync] L1 SIM1 exclusion: '$accountId'");
    return false;
  }

  // ── L2: Exact accountId match in target fingerprint ids ──────────────────
  if (accountId.isNotEmpty && targetFp.accountIds.contains(accountId)) {
    print("✅ [Sync] L2 exact match: '$accountId'");
    return true;
  }

  // ── L3: simDisplayName match (min 3 chars to avoid false positives) ───────
  if (simName.isNotEmpty) {
    final c = targetFp.carrierName.toLowerCase();
    final d = targetFp.displayName.toLowerCase();
    final n = targetFp.simNumber.toLowerCase();
    if ((c.length >= 3 && simName.contains(c)) ||
        (d.length >= 3 && simName.contains(d)) ||
        (n.length >= 3 && simName.contains(n))) {
      print("✅ [Sync] L3 simName match: '$simName'");
      return true;
    }
  }

  // ── L4: OEM accountId patterns (pre-compiled, O(n) on pattern count) ─────
  if (accountId.isNotEmpty) {
    for (final p in _kSim2Patterns) {
      if (p.hasMatch(accountId)) {
        print("✅ [Sync] L4 OEM accountId pattern: '$accountId'");
        return true;
      }
    }
  }

  // ── L5: OEM simDisplayName patterns ──────────────────────────────────────
  if (simName.isNotEmpty) {
    for (final p in _kSim2Patterns) {
      if (p.hasMatch(simName)) {
        print("✅ [Sync] L5 OEM simName pattern: '$simName'");
        return true;
      }
    }
  }

  // ── STRICT: No match = exclude. Never include unknown SIM entries. ────────
  return false;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Pre-compiled SIM 2 OEM patterns
//  Only used in dual-SIM mode. Each pattern is SPECIFIC to slot-1/SIM-2.
// ─────────────────────────────────────────────────────────────────────────────
final List<RegExp> _kSim2Patterns = [
  RegExp(r'^1$'),                                    // Xiaomi/Redmi: "1"
  RegExp(r'^sim\s*2$',          caseSensitive: false), // "SIM2" / "sim 2"
  RegExp(r'^slot\s*[_-]?\s*1$', caseSensitive: false), // "slot1","slot_1","slot-1"
  RegExp(r'^slot\s*[_-]?\s*2$', caseSensitive: false), // "slot2" (1-indexed OEMs)
  RegExp(r'[_\-\.]1$'),                              // "_1" / "-1" / ".1"
  RegExp(r':1$'),                                    // "SLOT:1" / "SIM:1"
  RegExp(r'^\bsub\s*1\b$',      caseSensitive: false), // "sub1" (2nd subscription)
  RegExp(r'^phone1$',           caseSensitive: false), // "phone1"
  RegExp(r'^telecom/sim/1$',    caseSensitive: false), // AOSP telecom URI
];

// ─────────────────────────────────────────────────────────────────────────────
//  Build fingerprint map from raw SIM cache list
// ─────────────────────────────────────────────────────────────────────────────
Map<int, _SimFingerprint> _buildFingerprintMap(List<dynamic> simList) {
  final map = <int, _SimFingerprint>{};

  for (int i = 0; i < simList.length; i++) {
    final raw = Map<String, dynamic>.from(simList[i] as Map);
    // Use slotIndex from data; fall back to list position
    final slotIndex = _parseInt(raw['slotIndex'], fallback: i);

    final subId   = _clean(raw['subscriptionId']);
    final iccId   = _clean(raw['iccId']);
    final serial  = _clean(raw['simSerialNumber']);
    final carrier = _clean(raw['carrierName']) ?? "";
    final display = _clean(raw['displayName']) ?? "";
    final number  = _clean(raw['number']);

    final ids = <String>{};
    if (subId != null)  ids.add(subId);
    if (iccId != null) {
      ids.add(iccId);
      if (iccId.length > 6) ids.add(iccId.substring(0, 6)); // issuer prefix
    }
    if (serial != null) ids.add(serial);

    final displayNumber = _resolveDisplayNumber(
      number: number, carrier: carrier, display: display, slotIndex: slotIndex,
    );

    map[slotIndex] = _SimFingerprint(
      slotIndex:     slotIndex,
      accountIds:    ids,
      carrierName:   carrier,
      displayName:   display,
      simNumber:     number ?? "",
      displayNumber: displayNumber,
    );

    print("📱 [Sync] SIM${slotIndex + 1} fingerprint: "
        "accountIds=${ids} displayNumber=$displayNumber");
  }

  return map;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Resolve best display number — actual number > carrier > display > label
// ─────────────────────────────────────────────────────────────────────────────
String _resolveDisplayNumber({
  required String? number,
  required String  carrier,
  required String  display,
  required int     slotIndex,
}) {
  final label = "SIM${slotIndex + 1}";
  if (number != null && number.isNotEmpty) return number;
  if (carrier.isNotEmpty && display.isNotEmpty && carrier != display) {
    return "$label ($carrier / $display)";
  }
  if (carrier.isNotEmpty) return "$label ($carrier)";
  if (display.isNotEmpty) return "$label ($display)";
  return label;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Small helpers
// ─────────────────────────────────────────────────────────────────────────────

Future<void> _saveTimestamp(GetStorage storage, DateTime time) async {
  await storage.write('last_call_log_sync_timestamp', time.millisecondsSinceEpoch);
  print("💾 [Sync] Timestamp saved: $time");
}

String? _clean(dynamic value) {
  final s = value?.toString().trim() ?? "";
  return (s.isEmpty || s.toLowerCase() == "null") ? null : s;
}

String _safeStr(dynamic value, {required String fallback}) =>
    _clean(value) ?? fallback;

int _parseInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? fallback;
}

String _mapCallType(CallType? callType) {
  switch (callType) {
    case CallType.outgoing: return "outgoing_call";
    case CallType.incoming: return "incoming_call";
    case CallType.missed:   return "missed_call";
    case CallType.blocked:  return "not_answered_call";
    default:
      return callType?.toString().split('.').last ?? "unknown_call";
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SIM Fingerprint model
// ─────────────────────────────────────────────────────────────────────────────
class _SimFingerprint {
  final int         slotIndex;
  final Set<String> accountIds;
  final String      carrierName;
  final String      displayName;
  final String      simNumber;
  final String      displayNumber;

  const _SimFingerprint({
    required this.slotIndex,
    required this.accountIds,
    required this.carrierName,
    required this.displayName,
    required this.simNumber,
    required this.displayNumber,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  Backward-compat stub (used elsewhere in codebase)
// ─────────────────────────────────────────────────────────────────────────────
String _resolveSimNumber(Map<String, dynamic>? simInfo) {
  if (simInfo == null) return "SIM2";
  return _resolveDisplayNumber(
    number:    _clean(simInfo['number']),
    carrier:   _clean(simInfo['carrierName']) ?? "",
    display:   _clean(simInfo['displayName']) ?? "",
    slotIndex: 1,
  );
}
