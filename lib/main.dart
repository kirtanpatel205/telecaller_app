import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
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

import 'core/helpers/utils.dart';
import 'core/services/lang_service.dart';
import 'core/services/theme_service.dart';
final logger = Logger();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ==================== FIREBASE INIT ====================
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  // Register FCM background handler at the very top
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);



  // ==================== GESTURE RESAMPLING ====================
  GestureBinding.instance.resamplingEnabled = true;

  // ==================== LOCAL STORAGE ====================
  try {
    await GetStorage.init();
    logger.i("✅ Local storage initialized");
  } catch (e) {
    logger.e("❌ Local storage error: $e");
  }
  // ==================== LOAD LANGUAGE JSON ====================
  String langDataString = await Utils.loadJsonData("assets/lang/lang.json");
  final List<dynamic> jsonData = json.decode(langDataString);
  logger.i("✅ Language data loaded");

  // String langDataString = await Utils.loadJsonData("assets/lang/lang.json");
  // final List<dynamic> jsonData = json.decode(langDataString);
  logger.i("✅ Language data loaded");


  // ==================== KEEP SCREEN ON ====================
  try {
    await KeepScreenOn.turnOn();
    logger.i("✅ Keep screen on enabled");
  } catch (e) {
    logger.e("❌ Keep screen on error: $e");
  }

  // ==================== SAFE APP START ====================
  Initializer.instance.init(() {
    runApp(MyApp(jsonData: jsonData));
  });
}

// ==================== MAIN APP ====================
class MyApp extends StatefulWidget {
  final List<dynamic>? jsonData;

  const MyApp({super.key,this.jsonData});

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
    final ThemeService themeService = Get.find();
    final LangService langService = Get.find();

    return ThemeProvider(
      initTheme: themeService.isDarkMode.value ? AppTheme.darkTheme : AppTheme.theme,
      builder: (context, theme) {
        return ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => Obx(
            () => GetMaterialApp(
              title: AppStrings.appName,
              debugShowCheckedModeBanner: false,
              theme: theme, // Use theme from ThemeProvider
              locale: Locale(langService.selectedLang.value),
              darkTheme: AppTheme.darkTheme,
              themeMode: themeService.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
              initialRoute: AppPages.INITIAL,
              getPages: AppPages.routes,
              unknownRoute: GetPage(
                name: Paths.SPLASH,
                page: () => SplashPage(),
                binding: SplashBinding(),
              ),
              home: child,
            ),
          ),
        );
      },
    );
  }
}
