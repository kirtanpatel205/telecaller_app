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
import 'package:telecaller_app/core/helpers/utils.dart';
import 'package:sim_card_code/sim_card_code.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    BackgroundServiceManager.setIsBackgroundIsolate(true);
    WidgetsFlutterBinding.ensureInitialized();
    await GetStorage.init();
    print("🛠️ [Workmanager] Background task started: $task");
    
    try {
      // ✅ Check if logged in first (token is valid)
      final String? token = await Storage.getToken();
      if (token == null || token.isEmpty) {
        print("🛠️ [Workmanager] User is not logged in. Skipping background tasks and canceling work.");
        try {
          await Workmanager().cancelAll();
        } catch (e) {
          print("⚠️ [Workmanager] Error canceling all tasks: $e");
        }
        return Future.value(true);
      }

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
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  BackgroundServiceManager.setIsBackgroundIsolate(true);
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  // ✅ FORCED FOREGROUND for Xiaomi/HyperOS
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  // Initialize storage
  await GetStorage.init();

  // ✅ Check if logged in first!
  final String? token = await Storage.getToken();
  if (token == null || token.isEmpty) {
    print("🛑 [Background] User is not logged in. Stopping service immediately.");
    service.stopSelf();
    return;
  }

  // For firebase messaging in background service
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize NetworkService
  if (!Get.isRegistered<NetworkService>()) {
    Get.put(NetworkService());
  }

  // Initialize SocketController
  SocketController.isBackground = true;
  SocketController.backgroundServiceInstance = service;
  final socket = SocketController();
  Get.put(socket);

  // Initialize ApiService
  if (!Get.isRegistered<ApiService>()) {
    final apiService = ApiService();
    await apiService.init();
    Get.put<ApiService>(apiService);

    // Refresh SIM info inside the background isolate
    await BackgroundServiceManager.fetchAndSaveSimInfo();
  }

  // Register this Master isolate's SendPort
  final ReceivePort socketPort = ReceivePort();
  IsolateNameServer.removePortNameMapping('socket_master_port');
  IsolateNameServer.registerPortWithName(socketPort.sendPort, 'socket_master_port');

  socketPort.listen((message) {
    if (message is Map) {
      final event = message['event'] as String?;
      final data = message['data'] as Map<String, dynamic>?;
      if (event != null && data != null) {
        socket.socket?.emit(event, data);
      }
    }
  });

  try {
    if (!Get.isRegistered<PhoneStatusService>()) {
      final phoneService = PhoneStatusService();
      await phoneService.init(isBackground: true);
      Get.put<PhoneStatusService>(phoneService);
    }
  } catch (e) {
    print("❌ Background initialization error: $e");
  }

  // Native phone state listeners
  service.on('native_phone_state').listen((event) {
    if (event != null && Get.isRegistered<PhoneStatusService>()) {
      final phoneService = Get.find<PhoneStatusService>();
      phoneService.handleNativeEvent(state: event['state'] as String?, number: event['number'] as String?);
    }
  });

  service.on('dialer_closed').listen((_) {
    if (Get.isRegistered<PhoneStatusService>()) {
      Get.find<PhoneStatusService>().handleDialerClosed();
    }
  });

  service.on('socket_emit').listen((event) {
    if (event != null && Get.isRegistered<SocketController>()) {
      final socket = Get.find<SocketController>();
      final String? eventName = event['event'];
      final Map<String, dynamic>? data = event['data'];
      if (eventName != null && data != null) {
        socket.socket?.emit(eventName, data);
      }
    }
  });

  service.on('set_lead_info').listen((event) {
    if (event != null && Get.isRegistered<PhoneStatusService>()) {
      final phoneStatusService = Get.find<PhoneStatusService>();
      if (event['leadId'] != null) phoneStatusService.currentLeadId = event['leadId'];
      if (event['leadContactId'] != null) phoneStatusService.currentLeadContactId = event['leadContactId'];
      if (event['callSessionId'] != null) phoneStatusService.setExternalCallSessionId(event['callSessionId']);
      if (event['phoneNumber'] != null) phoneStatusService.targetPhoneNumber.value = Utils.normalizePhoneNumber(event['phoneNumber']);
    }
  });

  service.on('set_token').listen((event) async {
    if (event != null && event['token'] != null) {
      final String newToken = event['token'];
      await Storage.saveToken(newToken);
      if (Get.isRegistered<SocketController>()) {
        Get.find<SocketController>().connectWithToken(newToken);
      }
    }
  });

  Timer? syncLogsTimer;
  Timer? pendingEventsTimer;

  service.on('stopService').listen((_) {
    syncLogsTimer?.cancel();
    pendingEventsTimer?.cancel();
    service.stopSelf();
  });
  service.on('stop').listen((_) {
    syncLogsTimer?.cancel();
    pendingEventsTimer?.cancel();
    service.stopSelf();
  });

  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(title: "Telecaller Service", content: "Service is active");
  }

  // Periodic tasks
  syncLogsTimer = Timer.periodic(const Duration(minutes: 15), (timer) async => await _syncCallLogs());
  pendingEventsTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final pendingEvent = prefs.getString('pending_phone_event');
      if (pendingEvent != null && Get.isRegistered<PhoneStatusService>()) {
        final event = json.decode(pendingEvent);
        Get.find<PhoneStatusService>().handleNativeEvent(state: event['state'], number: event['number']);
        await prefs.remove('pending_phone_event');
      }
    } catch (e) {}
  });
}

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

  static bool _isBackgroundIsolate = false;

  static void setIsBackgroundIsolate(bool value) {
    _isBackgroundIsolate = value;
    print("📱 [Background] _isBackgroundIsolate set to: $value (Isolate: ${Isolate.current.debugName})");
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

  static Future<void> fetchAndSaveSimInfo({bool forceNative = false}) async {
    try {
      // ✅ Simple background detection
      final bool isBackground = _isBackgroundIsolate;

      // ✅ In background isolates, native plugins often fail due to lack of Activity context.
      if (isBackground && !forceNative) {
        print("📱 [Background] Using cached SIM info to avoid native crash.");
        final cachedSims = await Storage.getSimInfo();
        if (cachedSims != null && cachedSims.isNotEmpty) {
          print("✅ [Background] Loaded ${cachedSims.length} SIMs from cache.");
        }
        return;
      }

      print("📱 [SIM] Fetching fresh SIM metadata...");

      final phonePermission = await Permission.phone.status;
      
      if (!phonePermission.isGranted) {
        if (isBackground) return;
        
        // Request permissions if in UI isolate
        Map<Permission, PermissionStatus> statuses = await [
          Permission.phone,
        ].request();
        
        if (statuses[Permission.phone] != PermissionStatus.granted) {
          return;
        }
      }

      List<Map<String, dynamic>> simInfoList = [];

      // 1. Try NEW Robust Native Implementation first
      try {
        final List<dynamic>? nativeSims = await _channel.invokeMethod('getSimInfo');
        if (nativeSims != null && nativeSims.isNotEmpty) {
          print("✅ [SIM] Fetched ${nativeSims.length} SIM slots via NEW native method.");
          simInfoList = nativeSims.map<Map<String, dynamic>>((sim) {
            final map = Map<String, dynamic>.from(sim as Map);
            return {
              'slotIndex': map['slotIndex'],
              'displayName': map['displayName'] ?? map['carrierName'] ?? "SIM ${map['slotIndex'] + 1}",
              'carrierName': map['carrierName'] ?? "Unknown",
              'number': Utils.normalizePhoneNumber(map['number']?.toString() ?? ""),
              'subscriptionId': map['subscriptionId'],
              'iccId': map['iccId'],
            };
          }).toList();
        }
      } catch (e) {
        print("⚠️ [SIM] New native method failed: $e. Falling back to plugin.");
      }

      // 2. Fallback to existing plugin if native failed or returned no results
      if (simInfoList.isEmpty) {
        try {
          final List<SimCardInfo> simCards = await SimCardManager.allSimInfo;
          if (simCards.isNotEmpty) {
            simInfoList = simCards.map<Map<String, dynamic>>((sim) => {
              'slotIndex': sim.slotIndex,
              'displayName': sim.displayName,
              'carrierName': sim.carrierName,
              'number': Utils.normalizePhoneNumber(sim.phoneNumber ?? ""),
              'subscriptionId': sim.subscriptionId,
            }).toList();
            print("📱 [SIM] Successfully fetched ${simInfoList.length} SIM slots via plugin fallback.");
          }
        } catch (e) {
          print("❌ [SIM] Plugin fallback also failed: $e");
        }
      }

      if (simInfoList.isNotEmpty) {
        await GetStorage().write('sim_info_cache', simInfoList);
        await Storage.saveSimInfo(simInfoList);
        print("💾 [SIM] SIM info persisted to storage.");
      } else {
        print("⚠️ [SIM] No SIM info could be detected by any method.");
      }
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains("NullPointerException") || errorStr.contains("null object reference")) {
        print("⚠️ [SIM] Plugin failed due to missing Context (expected in background).");
      } else {
        print("! [SIM] Error fetching SIM info: $e");
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

// Entry points moved to top of file

// ============================================================
//  _syncCallLogs  –  Production-grade SIM detection
//  Fixes: hardcoded SIM2, unknown SIM inclusion, duplicates,
//         SIM number reliability, pattern mismatch, weak exclusion,
//         performance loops, logging, empty fields, cache issues
// ============================================================

Future<void> _syncCallLogs() async {
  try {
    print("📋 [Sync] ══════════════ START ══════════════");

    // ── Check if logged in first ─────────────────────────────────────────────
    final String? token = await Storage.getToken();
    if (token == null || token.isEmpty) {
      print("🚫 [Sync] User is not logged in (no token). Aborting.");
      return;
    }

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
        accountId:       accountId,
        simName:         simName,
        targetSlotIndex: targetSlot,
        targetFp:        targetFp,
        allFingerprints: fpMap,
      );

      if (!isTarget) {
        print("⏭️ [Sync] Skip (not target SIM${targetSlot + 1}): "
            "accountId='$accountId' simName='$simName'");
        continue;
      }

      newKeys.add(callKey);

      logs.add({
        "callType":  _mapCallType(entry.callType),
        "name":      _safeStr(entry.name,   fallback: "Unknown"),
        "duration":  entry.duration ?? 0,
        "phone":     Utils.normalizePhoneNumber(_safeStr(entry.number, fallback: "")),
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
  required String                    accountId,
  required String                    simName,
  required int                       targetSlotIndex,
  required _SimFingerprint           targetFp,
  required Map<int, _SimFingerprint> allFingerprints,
}) {

  // ── L1: Hard exclusion — confirmed other SIM entry ────────────────────────
  // Check FIRST to prevent any false positives downstream
  for (final entry in allFingerprints.entries) {
    if (entry.key == targetSlotIndex) continue;
    
    final otherFp = entry.value;
    if (accountId.isNotEmpty && otherFp.accountIds.contains(accountId)) {
      print("🚫 [Sync] L1 exclusion: '$accountId' belongs to SIM${entry.key + 1}");
      return false;
    }
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

  // ── L4: OEM accountId patterns (Conditional based on slot) ────────────────
  if (accountId.isNotEmpty) {
    // SIM 2 specific patterns
    if (targetSlotIndex == 1) {
      for (final p in _kSim2Patterns) {
        if (p.hasMatch(accountId)) {
          print("✅ [Sync] L4 SIM2 OEM accountId pattern: '$accountId'");
          return true;
        }
      }
    }
    // SIM 1 specific patterns (usually "0" or just blank)
    if (targetSlotIndex == 0) {
      if (accountId == "0" || accountId == "sim1" || accountId == "slot0") {
        print("✅ [Sync] L4 SIM1 OEM accountId: '$accountId'");
        return true;
      }
    }
  }

  // ── L5: OEM simDisplayName patterns ──────────────────────────────────────
  if (simName.isNotEmpty) {
    if (targetSlotIndex == 1) {
      for (final p in _kSim2Patterns) {
        if (p.hasMatch(simName)) {
          print("✅ [Sync] L5 SIM2 OEM simName pattern: '$simName'");
          return true;
        }
      }
    }
    if (targetSlotIndex == 0) {
       if (simName == "sim1" || simName == "slot0" || simName == "sim 1") {
         print("✅ [Sync] L5 SIM1 OEM simName: '$simName'");
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
  if (number != null && number.isNotEmpty) {
    return Utils.normalizePhoneNumber(number);
  }
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
