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

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
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
      final List<dynamic>? simInfo = await _channel.invokeMethod('getSimInfo');
      if (simInfo != null) {
        print("📱 [SIM] Fetched native SIM info: $simInfo");
        await GetStorage().write('sim_info_cache', simInfo);
      }
    } catch (e) {
      print("⚠️ [SIM] Error fetching SIM info: $e");
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

Future<void> _syncCallLogs() async {
  try {
    print("📋 [Sync] Starting call log synchronization process...");

    final now = DateTime.now();
    // Increase window to 24 hours to ensure we don't miss calls due to clock sync issues
    final searchWindow = now.subtract(const Duration(hours: 24));

    print(
      "📋 [Sync] Querying system call logs since ${searchWindow.toIso8601String()}",
    );

    // Verify permission inside the isolate
    if (!(await Permission.phone.isGranted)) {
      print("🚫 [Sync] PHONE permission not granted in background isolate.");
      return;
    }

    Iterable<CallLogEntry> entries;
    try {
      entries = await CallLog.query(
        dateFrom: searchWindow.millisecondsSinceEpoch,
      );

      if (entries.isEmpty) {
        print("⚠️ [Sync] No logs found in last 24h. Trying broad fallback...");
        entries = await CallLog.get();
      }
    } catch (e) {
      print("❌ [Sync] Critical Error querying CallLog: $e");
      return;
    }

    // Ensure we have SIM info cached
    final List<dynamic>? cachedSimInfo = GetStorage().read('sim_info_cache');
    if (cachedSimInfo == null) {
      print("⚠️ [Sync] SIM info cache is empty. Attempting immediate fetch...");
      await BackgroundServiceManager.fetchAndSaveSimInfo();
    }

    List<Map<String, dynamic>> logs = [];
    print("📋 [Sync] Found ${entries.length} entries in system log.");

    for (var entry in entries) {
      // SIM identification logic
      bool isTargetSim = false;
      bool isDualSim = (cachedSimInfo != null && cachedSimInfo.length > 1);

      String simDisplayName = (entry.simDisplayName ?? "").toLowerCase();
      String phoneAccountId = entry.phoneAccountId ?? "";

      if (isDualSim) {
        if (simDisplayName.contains("2") ||
            phoneAccountId == "1" ||
            phoneAccountId.contains("_1") ||
            phoneAccountId.toLowerCase().contains("slot1")) {
          isTargetSim = true;
        } else if (cachedSimInfo != null) {
          for (var sim in cachedSimInfo) {
            if (sim['subscriptionId'] == phoneAccountId &&
                sim['slotIndex'] == "1") {
              isTargetSim = true;
              break;
            }
          }
        }
      } else {
        isTargetSim = true; // Single SIM device
      }

      if (!isTargetSim) continue;

      // Map "proper" number
      String properSimNumber =
          entry.simDisplayName ?? entry.phoneAccountId ?? "Unknown";
      if (cachedSimInfo != null && cachedSimInfo.isNotEmpty) {
        String targetSlot = isDualSim ? "1" : "0";
        for (var sim in cachedSimInfo) {
          if (sim['slotIndex'] == targetSlot) {
            String? num = sim['number'];
            if (num != null && num.isNotEmpty) {
              properSimNumber = num;
            } else {
              properSimNumber =
                  sim['displayName'] ?? sim['carrierName'] ?? properSimNumber;
            }
            break;
          }
        }
      }

      String callTypeStr = "unknown";
      switch (entry.callType) {
        case CallType.outgoing:
          callTypeStr = "outgoing_call";
          break;
        case CallType.incoming:
          callTypeStr = "incoming_call";
          break;
        case CallType.missed:
          callTypeStr = "missed_call";
          break;
        case CallType.rejected:
          callTypeStr = "rejected_call";
          break;
        case CallType.blocked:
          callTypeStr = "blocked_call";
          break;
        default:
          callTypeStr = entry.callType.toString().split('.').last;
      }

      logs.add({
        "callType": callTypeStr,
        "name":
            (entry.name == null || entry.name!.isEmpty)
                ? "Unknown"
                : entry.name,
        "duration": entry.duration ?? 0,
        "phone": entry.number ?? "",
        "timeStamp":
            DateTime.fromMillisecondsSinceEpoch(
              entry.timestamp ?? 0,
            ).toIso8601String(),
        "simNumber": properSimNumber,
      });
    }

    if (logs.isNotEmpty) {
      print("🚀 [Sync] Prepared ${logs.length} logs. Sending to API...");
      try {
        if (Get.isRegistered<ApiService>()) {
          final response = await Get.find<ApiService>().syncCallLogs({
            "logs": logs,
          });
          print(
            "✅ [Sync] API Response: ${response.status} - ${response.message}",
          );
        } else {
          print(
            "⚠️ [Sync] ApiService missing in isolate. Creating fallback...",
          );
          final apiService = ApiService();
          await apiService.init();
          await apiService.syncCallLogs({"logs": logs});
        }
      } catch (e) {
        print("❌ [Sync] API Error: $e");
      }
    } else {
      print("ℹ [Sync] No matching call logs found to sync.");
    }
  } catch (e) {
    print("❌ [Sync] General Error: $e");
  }
}
