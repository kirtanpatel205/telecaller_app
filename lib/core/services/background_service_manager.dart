import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
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

@pragma('vm:entry-point')
class BackgroundServiceManager {
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    /// OPTIONAL, use custom notification channel id
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'my_foreground', // id
      'MY FOREGROUND SERVICE', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.low,
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
  }

  static Future<void> requestBatteryOptimizationExclusion() async {
    if (Platform.isAndroid) {
      var status = await Permission.ignoreBatteryOptimizations.status;
      if (status.isDenied) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    }
  }

  static Future<void> openManufacturerSettings() async {
    if (Platform.isAndroid) {
      // Common OEM settings intents
      final intents = [
        // Xiaomi
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
  if (!Get.isRegistered<SocketController>()) {
    SocketController.isBackground = true; // Mark as background isolate
    SocketController.backgroundServiceInstance = service; // Provide service instance for communication
    final socket = SocketController();
    Get.put(socket);
  }


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
      Get.find<SocketController>().ensureConnected(); // This also broadcasts status
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
        final service = Get.find<PhoneStatusService>();
        if (event['leadId'] != null) {
          service.currentLeadId = event['leadId'];
          print("✅ Background currentLeadId updated: ${event['leadId']}");
        }
        if (event['callSessionId'] != null) {
          service.setExternalCallSessionId(event['callSessionId']);
          print(
            "✅ Background callSessionId updated: ${event['callSessionId']}",
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
      
      if (Get.isRegistered<SocketController>()) {
        Get.find<SocketController>().connectWithToken(newToken);
      }
    }
  });

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Diagnostic Heartbeat
  Timer.periodic(const Duration(seconds: 30), (timer) {
    print("💓 Background Service Heartbeat: ${DateTime.now()}");
    if (Get.isRegistered<SocketController>()) {
      final socket = Get.find<SocketController>();
      print("🔌 Background Socket Connected: ${socket.isConnected.value}");
      if (!socket.isConnected.value) {
        print("🔄 Attempting background socket reconnect...");
        socket.ensureConnected();
      }
    }
  });

  // Poll SharedPreferences for native phone events (from PhoneStateReceiver fallback)
  Timer.periodic(const Duration(seconds: 3), (timer) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload(); // Force fresh read
      final pendingEvent = prefs.getString('pending_phone_event');
      if (pendingEvent != null && pendingEvent.isNotEmpty) {
        print("📥 [SharedPrefs Bridge] Found pending phone event: $pendingEvent");
        final event = json.decode(pendingEvent);
        final timestamp = event['timestamp'] as int? ?? 0;
        // Only process if recent (< 30 seconds old)
        if (DateTime.now().millisecondsSinceEpoch - timestamp < 30000) {
          if (Get.isRegistered<PhoneStatusService>()) {
            Get.find<PhoneStatusService>().handleNativeEvent(
              state: event['state'],
              number: event['number'],
            );
            print("✅ [SharedPrefs Bridge] Processed event: ${event['state']}");
          }
        } else {
          print("⏰ [SharedPrefs Bridge] Stale event (>30s), discarding");
        }
        // Clear the pending event
        await prefs.remove('pending_phone_event');
      }
    } catch (e) {
      // Silent — don't spam logs on every tick
    }
  });

  // Bring to foreground (checking if still foreground)
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        // service.setAsForegroundService();
      }
    }
  });
}
