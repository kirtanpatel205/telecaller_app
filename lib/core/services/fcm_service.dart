import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:telecaller_app/constants/app_constants.dart';
import 'package:telecaller_app/core/helpers/storage.dart';
import 'package:telecaller_app/firebase_options.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:permission_handler/permission_handler.dart';

import 'api_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize notifications for background
  final FlutterLocalNotificationsPlugin localNotif =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await localNotif.initialize(initializationSettings);

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );
  await localNotif
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  print('Handling a background message ${message.messageId}');
  _handleNotificationPayload(message, localNotif, channel);
}

void _handleNotificationPayload(
  RemoteMessage message, [
  FlutterLocalNotificationsPlugin? localNotif,
  AndroidNotificationChannel? channel,
]) {
  print('Processing message: ${message.messageId}');
  final data = message.data;
  final notification = message.notification;

  print('Message Data: $data');

  String title = notification?.title ?? data['title'] ?? 'Auto Call';
  String body = notification?.body ?? data['body'] ?? 'Incoming Auto Call Task';

  // Extract from 'message' key if it's a map or JSON string
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

  // Show notification if we have the plugin (usually in background)
  if (localNotif != null && channel != null) {
    localNotif.show(
      message.messageId.hashCode,
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
          ongoing: true,
          autoCancel: true,
        ),
      ),
    );
  }

  String? phoneNumber;

  // 1. Try common keys in a flat map
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

  // 2. If not found, check if there's a nested 'message' object (like in user's example)
  if (phoneNumber == null && data.containsKey('message')) {
    try {
      var messageContent = data['message'];
      if (messageContent is String) {
        // Try parsing as JSON if it's a string
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

  // 3. Fallback: Search ALL values in data map for something that looks like a phone number
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

  // 4. Fallback: Search notification body
  if (phoneNumber == null && notification?.body != null) {
    RegExp phoneRegex = RegExp(r'\+?[0-9]{10,15}');
    Match? match = phoneRegex.firstMatch(notification!.body!);
    if (match != null) {
      phoneNumber = match.group(0);
      print('Extracted phone number from notification body: $phoneNumber');
    }
  }

  if (phoneNumber != null && phoneNumber.isNotEmpty) {
    print('Starting 10-second auto-call countdown for $phoneNumber');

    Timer(const Duration(seconds: 10), () async {
      print('Initiating auto-call to $phoneNumber now');
      try {
        if (Platform.isAndroid) {
          // Check permissions first
          final callStatus = await Permission.phone.status;
          final alertStatus = await Permission.systemAlertWindow.status;
          print('Permissions: CALL_PHONE=$callStatus, SYSTEM_ALERT_WINDOW=$alertStatus');

          print('Launching translucent CallActivity for background call');
          final intent = AndroidIntent(
            action: 'android.intent.action.MAIN',
            package: 'com.digibulkmarketing.telecaller_app',
            componentName: 'com.digibulkmarketing.telecaller_app.CallActivity',
            arguments: <String, dynamic>{
              'phoneNumber': phoneNumber,
            },
            flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
          );
          await intent.launch();
          print('CallActivity intent sent successfully');
        } else {
          bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber!);
          print('Call initiated result: $res');
        }
      } catch (e) {
        print('Error launching CallActivity: $e');
        // Final fallback to direct caller if proxy fails
        try {
          print('Attempting fallback to FlutterPhoneDirectCaller');
          await FlutterPhoneDirectCaller.callNumber(phoneNumber!);
        } catch (e2) {
          print('Final fallback failed: $e2');
        }
      }
    });
  } else {
    print('No phone number found anywhere in message payload');
  }
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
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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

    // Always attempt to save to API if we have an auth token
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
    OneSignal.Notifications.requestPermission(true);
    OneSignal.Notifications.clearAll();

    OneSignal.User.pushSubscription.addObserver((state) {
      print("OneSignal Subscription: ${state.current.jsonRepresentation()}");
    });

    OneSignal.Notifications.addPermissionObserver((state) {
      print("Notification Permission: $state");
    });

    OneSignal.Notifications.addClickListener((event) {
      print('Notification Clicked: ${event.notification.jsonRepresentation()}');
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
    ) {
      if (message != null) {
        print("Initial Message: ${message.messageId}");
        _handleNotificationPayload(message);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground Message: ${message.messageId}');
      _handleNotificationPayload(message);
      showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message Opened App: ${message.data}');
      _handleNotificationPayload(message);
    });

    Stream<String> tokenStream = FirebaseMessaging.instance.onTokenRefresh;
    tokenStream.listen(setToken);

    _initialized = true;
  }

  void showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    if (notification == null) return;

    flutterLocalNotificationsPlugin!.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel!.id,
          channel!.name,
          channelDescription: channel!.description,
          icon: 'ic_launcher',
        ),
      ),
    );
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
      fcmToken = await Storage.getValue(AppConstants.FCM_TOKEN);
      await setToken(fcmToken);
    }
  }
}
