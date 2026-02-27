import 'dart:async';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'package:telecaller_app/constants/app_pages.dart';
import 'package:telecaller_app/constants/app_routes.dart';
import 'package:telecaller_app/constants/app_strings.dart';
import 'package:telecaller_app/constants/app_theme.dart';
import 'package:telecaller_app/firebase_options.dart';
import 'package:telecaller_app/ui/views/splash/splash_binding.dart';
import 'package:telecaller_app/ui/views/splash/splash_page.dart';
import 'package:telecaller_app/core/services/background_service_manager.dart';
import 'package:telecaller_app/core/services/fcm_service.dart';
import 'core/helpers/initializer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
final logger = Logger();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ==================== FIREBASE INIT ====================
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  // Register FCM background handler at the very top
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // ==================== BACKGROUND SERVICE ====================
  try {
    await BackgroundServiceManager.initializeService();
    logger.i("✅ Background service initialized");
  } catch (e) {
    logger.e("❌ Background service error: $e");
  }

  // ==================== GESTURE RESAMPLING ====================
  GestureBinding.instance.resamplingEnabled = true;

  // ==================== LOCAL STORAGE ====================
  try {
    await GetStorage.init();
    logger.i("✅ Local storage initialized");
  } catch (e) {
    logger.e("❌ Local storage error: $e");
  }

  // ==================== KEEP SCREEN ON ====================
  try {
    await KeepScreenOn.turnOn();
    logger.i("✅ Keep screen on enabled");
  } catch (e) {
    logger.e("❌ Keep screen on error: $e");
  }

  // ==================== SAFE APP START ====================
  Initializer.instance.init(() {
    runApp(MyApp());
  });
}

// ==================== MAIN APP ====================
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    logger.i("🎯 MyApp initialized");
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return ScreenUtilInit(
      designSize: Size(size.width, size.height),
      builder:
          (context, child) => GetMaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            initialRoute: AppPages.INITIAL,
            getPages: AppPages.routes,
            unknownRoute: GetPage(
              name: Paths.SPLASH,
              page: () => SplashPage(),
              binding: SplashBinding(),
            ),
            home: child,
          ),
    );
  }
}
