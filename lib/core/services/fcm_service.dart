import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:telecaller_app/constants/app_constants.dart';
import 'package:telecaller_app/core/helpers/storage.dart';

import 'api_service.dart';

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
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
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
    if (authToken == null || authToken.isEmpty) {
      print("No auth token available, skipping FCM token save");
      return;
    }
    try {
     await api.saveFCMToken(token);
      print("FCM token saved successfully");
    } catch (e) {
      print("Failed to save FCM token: $e");
    }
  }

  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('Handling a background message ${message.messageId}');
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
      print('Notification Will Display: ${event.notification.jsonRepresentation()}');
      event.notification.display();
    });

    OneSignal.InAppMessages.addClickListener((event) {
      print("In App Message Clicked: ${event.result.jsonRepresentation()}");
    });
    OneSignal.InAppMessages.addWillDisplayListener((event) {
      print("In App Message Will Display: ${event.message.messageId}");
    });
    OneSignal.InAppMessages.addDidDisplayListener((event) {
      print("In App Message Displayed: ${event.message.messageId}");
    });
    OneSignal.InAppMessages.addWillDismissListener((event) {
      print("In App Message Will Dismiss: ${event.message.messageId}");
    });
    OneSignal.InAppMessages.addDidDismissListener((event) {
      print("In App Message Dismissed: ${event.message.messageId}");
    });

    OneSignal.User.addTagWithKey("platform", Platform.isAndroid ? "android" : "ios");
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

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print("Initial Message: ${message.messageId}");
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground Message: ${message.messageId}');
      showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message Opened App: ${message.data}');
    });

    Stream<String> tokenStream = FirebaseMessaging.instance.onTokenRefresh;
    tokenStream.listen(setToken);

    _initialized = true;
  }

  void showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    if (notification == null) return;

    String? image;
    AndroidNotification? android = message.notification?.android;
    AppleNotification? apple = message.notification?.apple;

    if (Platform.isAndroid && android?.imageUrl != null) {
      image = android!.imageUrl;
    } else if (Platform.isIOS && apple?.imageUrl != null) {
      image = apple!.imageUrl;
    }

    flutterLocalNotificationsPlugin!.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel!.id,
          channel!.name,
          channelDescription: channel!.description,
          icon: 'logo',
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
          if (Platform.isIOS) {
            String? apnToken = await FirebaseMessaging.instance.getAPNSToken();
            print("APNs Token: $apnToken");
          }
        }
        if (fcmToken != null) {
          await setToken(fcmToken);
          return;
        } else {
          print("FCM Token not available, retrying (${retryCount + 1}/$maxRetries)");
          retryCount++;
          await Future.delayed(Duration(seconds: 3));
        }
      } catch (e) {
        print("Error fetching FCM token: $e");
        retryCount++;
        if (retryCount >= maxRetries) {
          print("Max retries reached, giving up");
          break;
        }
        await Future.delayed(Duration(seconds: 3));
      }
    }

    if (fcmToken == null && Storage.hasData(AppConstants.FCM_TOKEN)) {
      fcmToken = await Storage.getValue(AppConstants.FCM_TOKEN);
      await setToken(fcmToken);
    }
  }
}