import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:telecaller_app/constants/app_constants.dart';
import 'package:telecaller_app/core/controllers/socket_controller.dart';
import 'package:telecaller_app/core/services/internetcheck.dart';
import 'package:telecaller_app/core/helpers/storage.dart';
import 'package:telecaller_app/core/helpers/utils.dart';
import 'package:telecaller_app/firebase_options.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:permission_handler/permission_handler.dart';
import 'api_service.dart';
import 'background_service_manager.dart';

// ✅ Platform channel to check lock screen status from native
const _platform = MethodChannel(
  'com.digibulkmarketing.telecaller_app/lockscreen',
);

int? _lastBgNotificationId;
FlutterLocalNotificationsPlugin? _lastBgNotifPlugin;

// ✅ Memory cache for de-duplication within same isolate
final Set<String> _processedIds = {};

/// ✅ Check if device is currently locked
Future<bool> _isScreenLocked() async {
  try {
    final bool isLocked = await _platform.invokeMethod('isScreenLocked');
    return isLocked;
  } catch (e) {
    print('⚠️ Could not check lock state: $e');
    return false; // Assume unlocked if check fails
  }
}

/// ✅ Wake screen — always uses CallActivity directly (MethodChannel is dead in BG isolate)
Future<void> _wakeScreen({bool isBackgroundIsolate = false}) async {
  // Screen wake logic removed as per user request to keep process entirely background/silent.
  print('ℹ️ [FCM] wakeScreen skipped (silent background mode)');
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    print('🔔 [FCM BG] Handling background message: ${message.messageId}');

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await GetStorage.init();

    final FlutterLocalNotificationsPlugin localNotif =
        FlutterLocalNotificationsPlugin();

    // ✅ Robust initialization for background isolate
    bool notifInitialized = false;
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('ic_launcher');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
      await localNotif.initialize(initializationSettings);
      notifInitialized = true;
    } catch (e) {
      print('⚠️ [FCM BG] Failed to initialize with ic_launcher: $e');
      try {
        const AndroidInitializationSettings initializationSettingsAndroid =
            AndroidInitializationSettings('@mipmap/ic_launcher');
        const InitializationSettings initializationSettings =
            InitializationSettings(android: initializationSettingsAndroid);
        await localNotif.initialize(initializationSettings);
        notifInitialized = true;
        print('✅ [FCM BG] Initialized with @mipmap/ic_launcher fallback');
      } catch (e2) {
        print('❌ [FCM BG] All notification initialization attempts failed: $e2');
      }
    }

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'call_tasks_channel',
      'Call Task Notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    if (notifInitialized) {
      await localNotif
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }

    // ✅ CRITICAL FIX: Use await here — do NOT return before the call is launched.
    // Previously a Timer() was used which fires AFTER the handler returns,
    // causing the isolate to be killed before the call could be made.
    await _handleNotificationPayload(
      message,
      notifInitialized ? localNotif : null,
      notifInitialized ? channel : null,
      false,
      true, // isBackgroundIsolate = true
    );

    try {
      if (!Get.isRegistered<NetworkService>()) {
        Get.put(NetworkService());
      }

      if (!Get.isRegistered<SocketController>()) {
        SocketController.isBackground = true;
        final socket = SocketController();
        await socket.initSocket();
        Get.put(socket);
        print('🔌 [FCM BG] SocketController initialized and connecting...');
      } else {
        await Get.find<SocketController>().initSocket();
      }
    } catch (e) {
      print('⚠️ [FCM BG] SocketController init error: $e');
    }
    try {
      final service = FlutterBackgroundService();
      bool isRunning = await service.isRunning();
      if (!isRunning) {
        print('🔔 [FCM BG] Background service not running. Initializing...');
        await BackgroundServiceManager.initializeService();
      }
    } catch (e) {
      print('⚠️ [FCM BG] Failed to ensure background service is running: $e');
    }

  } catch (e, stack) {
    print('❌ [FCM BG] Critical error in background handler: $e');
    print(stack);
  }
}

Future<Map<String, String>> _handleNotificationPayload(
  RemoteMessage message, [
  FlutterLocalNotificationsPlugin? localNotif,
  AndroidNotificationChannel? channel,
  bool immediate = false,
  bool isBackgroundIsolate = false,
]) async {
  final messageId = message.messageId ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}';

  // 1. Memory de-duplication
  if (!immediate && _processedIds.contains(messageId)) {
    print('⏭️ [FCM] Message $messageId already processed in memory. Skipping.');
    return {};
  }
  _processedIds.add(messageId);
  if (_processedIds.length > 50) _processedIds.remove(_processedIds.first);

  // 2. Persistent de-duplication (cross-isolate)
  if (!immediate && await Storage.isEventProcessed('fcm_msg', messageId)) {
    print('⏭️ [FCM] Message $messageId already processed in storage. Skipping.');
    return {};
  }
  if (!immediate) await Storage.markEventProcessed('fcm_msg', messageId);

  print('Processing message: $messageId (immediate: $immediate)');
  final data = message.data;
  final notification = message.notification;

  print('Message Data: $data');

  String title = notification?.title ?? data['title'] ?? 'Auto Call';
  String body = notification?.body ?? data['body'] ?? 'Incoming Auto Call Task';

  if (data.containsKey('message')) {
    try {
      var msgContent = data['message'];
      if (msgContent is String && msgContent.startsWith('{')) {
        var decoded = json.decode(msgContent);
        title = decoded['title'] ?? title;
        body = decoded['body'] ?? body;
      } else if (msgContent is Map) {
        title = msgContent['title'] ?? title;
        body = msgContent['body'] ?? body;
      }
    } catch (e) {
      print('Error parsing message content for display: $e');
    }
  }

  print('Final Notification Title: $title, Body: $body');

  // ✅ Wake screen — pass isolate flag so it skips the dead MethodChannel
  _wakeScreen(isBackgroundIsolate: isBackgroundIsolate);

  if (localNotif != null && channel != null) {
    try {
      final int notificationId =
          message.messageId?.hashCode ??
          DateTime.now().millisecondsSinceEpoch.hashCode;

      try {
        await localNotif.show(
          notificationId,
          title,
          body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              importance: Importance.max,
              priority: Priority.high,
              icon: 'ic_launcher',
              fullScreenIntent: false,
              visibility: NotificationVisibility.public,
              category: AndroidNotificationCategory.call,
              ongoing: true,
              autoCancel: false,
              ticker: 'Incoming Call Task',
            ),
          ),
        );
      } catch (e) {
        print('⚠️ [FCM Payload] Failed show with ic_launcher, trying @mipmap: $e');
        try {
          await localNotif.show(
            notificationId,
            title,
            body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                importance: Importance.max,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
                fullScreenIntent: false,
                visibility: NotificationVisibility.public,
                category: AndroidNotificationCategory.call,
                ongoing: true,
                autoCancel: false,
                ticker: 'Incoming Call Task',
              ),
            ),
          );
        } catch (e2) {
          print('❌ [FCM Payload] Final show failed: $e2');
        }
      }
      _lastBgNotificationId = notificationId;
      _lastBgNotifPlugin = localNotif;
      print('✅ [FCM BG] Notification display triggered for $notificationId');
    } catch (e) {
      print('❌ [FCM BG] Failed to show notification: $e');
    }
  }

  String? phoneNumber;

  List<String> keys = [
    'phone_number',
    'phoneNumber',
    'phone',
    'number',
    'mobile',
  ];
  for (var key in keys) {
    if (data.containsKey(key)) {
      phoneNumber = data[key]?.toString();
      break;
    }
  }

  if (phoneNumber == null && data.containsKey('message')) {
    try {
      var messageContent = data['message'];
      if (messageContent is String) {
        var decoded = json.decode(messageContent);
        if (decoded is Map) {
          phoneNumber =
              (decoded['phoneNumber'] ??
                      decoded['phone_number'] ??
                      decoded['phone'])
                  ?.toString();
        }
      } else if (messageContent is Map) {
        phoneNumber =
            (messageContent['phoneNumber'] ??
                    messageContent['phone_number'] ??
                    messageContent['phone'])
                ?.toString();
      }
    } catch (e) {
      print('Error parsing nested message data: $e');
    }
  }

  if (phoneNumber == null) {
    RegExp phoneRegex = RegExp(r'\+?[0-9]{10,15}');
    for (var value in data.values) {
      String valStr = value.toString();
      Match? match = phoneRegex.firstMatch(valStr);
      if (match != null) {
        phoneNumber = match.group(0);
        print('Extracted phone number from data value "$valStr": $phoneNumber');
        break;
      }
    }
  }

  if (phoneNumber == null && notification?.body != null) {
    RegExp phoneRegex = RegExp(r'\+?[0-9]{10,15}');
    Match? match = phoneRegex.firstMatch(notification!.body!);
    if (match != null) {
      phoneNumber = match.group(0);
      print('Extracted phone number from notification body: $phoneNumber');
    }
  }

  if (phoneNumber != null && phoneNumber.isNotEmpty) {
    String? leadId = data['leadContactId'] ?? data['leadId'] ?? data['lead_id'];
    String? callSessionId = data['callSessionId'] ?? data['call_session_id'];

    if ((leadId == null || callSessionId == null) &&
        data.containsKey('message')) {
      try {
        var messageContent = data['message'];
        Map? decoded;
        if (messageContent is String && messageContent.startsWith('{')) {
          decoded = json.decode(messageContent) as Map?;
        } else if (messageContent is Map) {
          decoded = messageContent;
        }

        if (decoded != null) {
          leadId ??=
              (decoded['leadContactId'] ??
                      decoded['leadId'] ??
                      decoded['lead_id'])
                  ?.toString();
          callSessionId ??=
              (decoded['callSessionId'] ?? decoded['call_session_id'])
                  ?.toString();
        }
      } catch (e) {
        print('Error parsing leadId/callSessionId from nested message: $e');
      }
    }

    try {
      if (Get.isRegistered<SocketController>()) {
        final SocketController socket = Get.find<SocketController>();
        socket.emitNotificationReceived(
          leadContactId: leadId,
          callSessionId: callSessionId,
          phoneNumber: phoneNumber,
        );
      }
    } catch (e) {
      print('❌ Socket notification emission error: $e');
    }

    // ✅ CRITICAL FIX: Use await Future.delayed instead of Timer().
    // Timer() schedules a callback and returns immediately — when used inside
    // firebaseMessagingBackgroundHandler, the handler returns before the Timer
    // fires, the isolate is destroyed by Android, and the call NEVER happens.
    // await Future.delayed keeps the handler alive until the call is launched.
    // 10-second delay is now handled inside the native CallService for maximum reliability across OEMs.
    // We trigger the broadcast immediately.
    print('⏳ [FCM] Triggering background CallReceiver for $phoneNumber...');


    print('📞 Initiating auto-call to $phoneNumber now (immediate: $immediate)');

    // Cancel the "incoming" notification before launching dialer
    try {
      if (_lastBgNotificationId != null && _lastBgNotifPlugin != null) {
        await _lastBgNotifPlugin!.cancel(_lastBgNotificationId!);
        print('🔕 [FCM BG] Cancelled notification $_lastBgNotificationId');
        _lastBgNotificationId = null;
        _lastBgNotifPlugin = null;
      }
    } catch (e) {
      print('⚠️ [FCM BG] Failed to cancel notification: $e');
    }

    if (leadId != null || callSessionId != null) {
      FlutterBackgroundService().invoke('set_lead_info', {
        'leadId': leadId,
        'callSessionId': callSessionId,
        'phoneNumber': phoneNumber,
      });
    }

    // 🚨 REDUNDANT EMISSION REMOVED:
    // The call-start event is now handled exclusively by PhoneStatusService
    // which includes a 2-second debounce timer to filter out SIM selection
    // cancellations on Dual SIM devices.

    try {
      if (Platform.isAndroid) {
        final callStatus = await Permission.phone.status;
        final alertStatus = await Permission.systemAlertWindow.status;
        print(
          'Permissions: CALL_PHONE=$callStatus, SYSTEM_ALERT_WINDOW=$alertStatus',
        );

        print('🚀 Sending broadcast to CallReceiver for background call');
        
        // Fetch pre-selected SIM slot index
        final int? slotIndex = await Storage.getFromSharedPrefs<int>('selected_sim_slot_index');
        print('📱 [FCM BG] Using SIM slot: ${slotIndex ?? "default"}');

        final intent = AndroidIntent(
          action: 'com.digibulkmarketing.telecaller_app.ACTION_START_CALL',
          package: 'com.digibulkmarketing.telecaller_app',
          arguments: <String, dynamic>{
            'phoneNumber': phoneNumber,
            'slotIndex': slotIndex ?? -1,
          },
        );
        await intent.sendBroadcast();
        print('✅ Call broadcast sent successfully');
      } else {
        await Utils.makeDirectCall(phoneNumber!);
      }
    } catch (e) {
      print('❌ Error launching CallActivity: $e');
      try {
        print('Attempting fallback to Utils.makeDirectCall');
        await Utils.makeDirectCall(phoneNumber!);
      } catch (e2) {
        print('Final fallback failed: $e2');
      }
    }
  } else {
    print('No phone number found anywhere in message payload');
  }

  return {'title': title, 'body': body};
}

class FCMService extends GetxService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool _initialized = false;
  AndroidNotificationChannel? channel;
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  final ApiService api = Get.find();

  Future<void> init() async {
    await _initOneSignal();
    await findToken();
    initFCM();
    initLocalNotification();
  }

  void initLocalNotification() async {
    channel = const AndroidNotificationChannel(
      'call_tasks_channel',
      'Call Task Notifications',
      description: 'This channel is used for important call transitions.',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _lastBgNotifPlugin = flutterLocalNotificationsPlugin;

    await flutterLocalNotificationsPlugin!
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel!);
  }

  Future<void> setToken(String? token) async {
    if (token == null) {
      print("FCM Token is null, skipping");
      return;
    }
    print('FCM Token: $token');
    await Storage.saveValue(AppConstants.FCM_TOKEN, token);

    String? authToken = await Storage.getValue(AppConstants.TOKEN);
    if (authToken != null && authToken.isNotEmpty) {
      try {
        await api.saveFCMToken(token);
        print("FCM token saved successfully to API");
      } catch (e) {
        print("Failed to save FCM token to API: $e");
      }
    } else {
      print("Auth token missing, FCM token saved locally only");
    }
  }

  Future<void> _initOneSignal() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.debug);
    OneSignal.initialize(AppConstants.ONE_SIGNAL_APP_KEY);
    
    // ✅ CRITICAL FIX for Xiaomi/Redmi Background Crashes:
    // This disables the hidden WebView used for In-App Messages.
    // This WebView is frequently killed by the OS in background, causing the whole app to crash.
    OneSignal.InAppMessages.paused(true);

    OneSignal.Notifications.requestPermission(true);
    OneSignal.Notifications.clearAll();

    OneSignal.User.pushSubscription.addObserver((state) {
      print("OneSignal Subscription: ${state.current.jsonRepresentation()}");
    });

    OneSignal.Notifications.addPermissionObserver((state) {
      print("Notification Permission: $state");
    });

    OneSignal.Notifications.addClickListener((event) {
      print('OneSignal Notification Clicked: ${event.notification.jsonRepresentation()}');
      // No immediate call for OneSignal yet, just logging
    });

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      print(
        'Notification Will Display: ${event.notification.jsonRepresentation()}',
      );
      event.notification.display();
    });

    OneSignal.User.addTagWithKey(
      "platform",
      Platform.isAndroid ? "android" : "ios",
    );
  }

  void initFCM() async {
    if (_initialized) return;

    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission();
    }

    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) async {
      if (message != null) {
        print("Initial Message: ${message.messageId}");
        final strings = await _handleNotificationPayload(message);
        showNotification(message, strings['title'], strings['body']);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Foreground Message: ${message.messageId}');
      final strings = await _handleNotificationPayload(message);
      showNotification(message, strings['title'], strings['body']);
    });

    // ✅ FIX: onMessageOpenedApp — Trigger immediate call on click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print('Message Opened App (Notification Tapped): ${message.data}');

      final bool locked = await _isScreenLocked();
      if (locked) {
        print('📵 Screen is locked — Processing payload immediately without app launch');
        await _handleNotificationPayload(message, null, null, true);
        return;
      }

      // Screen unlocked — process immediately
      await _handleNotificationPayload(message, null, null, true);
    });

    Stream<String> tokenStream = FirebaseMessaging.instance.onTokenRefresh;
    tokenStream.listen(setToken);

    _initialized = true;
  }

  void showNotification(
    RemoteMessage message, [
    String? title,
    String? body,
  ]) async {
    RemoteNotification? notification = message.notification;

    String finalTitle = title ?? notification?.title ?? 'Auto Call';
    String finalBody = body ?? notification?.body ?? 'Incoming Task';

    // ✅ Wake screen without opening app immediately
    _wakeScreen();

    final int notificationId = message.messageId.hashCode;
    _lastBgNotificationId = notificationId;
    // _lastBgNotifPlugin is already set in initLocalNotification

    try {
      await flutterLocalNotificationsPlugin!.show(
        notificationId,
        finalTitle,
        finalBody,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel!.id,
            channel!.name,
            channelDescription: channel!.description,
            icon: 'ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
            visibility: NotificationVisibility.public,
            category: AndroidNotificationCategory.call,
            playSound: true,
            enableVibration: true,
            fullScreenIntent: false,
            ongoing: true,
            autoCancel: false,
          ),
        ),
      );
    } catch (e) {
      print('⚠️ [FCM] Failed to show with ic_launcher, trying @mipmap/ic_launcher: $e');
      try {
        await flutterLocalNotificationsPlugin!.show(
          notificationId,
          finalTitle,
          finalBody,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel!.id,
              channel!.name,
              channelDescription: channel!.description,
              icon: '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
              visibility: NotificationVisibility.public,
              category: AndroidNotificationCategory.call,
              playSound: true,
              enableVibration: true,
              fullScreenIntent: false,
              ongoing: true,
              autoCancel: false,
            ),
          ),
        );
      } catch (e2) {
        print('❌ [FCM] Final showNotification failed: $e2');
      }
    }
  }

  void fcmSubscribe() {
    _firebaseMessaging.subscribeToTopic('jto');
  }

  void fcmUnSubscribe() {
    _firebaseMessaging.unsubscribeFromTopic('jto');
  }

  Future<void> findToken() async {
    String? fcmToken;
    const maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        if (Platform.isAndroid || Platform.isIOS) {
          fcmToken = await FirebaseMessaging.instance.getToken();
        }
        if (fcmToken != null) {
          await setToken(fcmToken);
          return;
        } else {
          print(
            "FCM Token not available, retrying (${retryCount + 1}/$maxRetries)",
          );
          retryCount++;
          await Future.delayed(Duration(seconds: 3));
        }
      } catch (e) {
        print("Error fetching FCM token: $e");
        retryCount++;
        await Future.delayed(Duration(seconds: 3));
      }
    }

    if (fcmToken == null && Storage.hasData(AppConstants.FCM_TOKEN)) {
      fcmToken = Storage.getValue(AppConstants.FCM_TOKEN);
      await setToken(fcmToken);
    }
  }
}
