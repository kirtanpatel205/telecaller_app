// import 'package:dbm_emp/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:telecaller_app/constants/app_constants.dart';
import 'package:telecaller_app/core/controllers/auth_controller.dart';
import 'package:telecaller_app/core/helpers/storage.dart';
import 'package:telecaller_app/core/services/api_service.dart';
import 'package:telecaller_app/core/services/fcm_service.dart';
import 'package:telecaller_app/core/services/phone_status_service.dart';
import 'package:telecaller_app/core/services/background_service_manager.dart';
import 'package:telecaller_app/core/controllers/socket_controller.dart';

class Initializer {
  static final Initializer instance = Initializer._internal();

  factory Initializer() => instance;

  Initializer._internal();

  bool _firebaseInitialized = false;

  Future<void> init(VoidCallback runApp) async {
    // ✅ Future<void> રાખો
    printInfo(info: 'Initializer: started');

    WidgetsFlutterBinding.ensureInitialized();

    // ✅ Services initialize કરો
    await _initServices();

    printInfo(info: '✅ All services initialized');

    // ✅ Finally, run app
    runApp();
  }

  Future<void> _initServices() async {
    try {
      await GetStorage.init();

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      await Get.put<ApiService>(ApiService()).init();
      await Get.putAsync<AuthController>(() async => AuthController());
      await Get.putAsync<FCMService>(() async => FCMService());
      Get.put(SocketController());

      // await Get.putAsync<FCMService>(() async => FCMService());
      await Get.putAsync<PhoneStatusService>(
        () async => await PhoneStatusService().init(),
      );

      // Request background reliability permissions
      await BackgroundServiceManager.requestBatteryOptimizationExclusion();

      // Sync token to background service if it exists
      try {
        final token = await Storage.getToken();
        if (token != null && token.isNotEmpty) {
          print("🔑 Initializer: Syncing token to background service...");
          FlutterBackgroundService().invoke('set_token', {'token': token});
        }
      } catch (e) {
        print("⚠️ Initializer: Could not sync token to background service: $e");
      }

      printInfo(info: '✅ All services ready');
    } catch (err) {
      printInfo(info: '❌ Init error: $err');
      rethrow;
    }
  }
}
