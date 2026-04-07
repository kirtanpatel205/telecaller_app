// import 'package:dbm_emp/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telecaller_app/constants/app_constants.dart';
import 'package:telecaller_app/core/controllers/auth_controller.dart';
import 'package:telecaller_app/core/helpers/storage.dart';
import 'package:telecaller_app/core/services/api_service.dart';
import 'package:telecaller_app/core/services/fcm_service.dart';
import 'package:telecaller_app/core/services/internetcheck.dart';
import 'package:telecaller_app/core/services/lang_service.dart';
import 'package:telecaller_app/core/services/phone_status_service.dart';
import 'package:telecaller_app/core/services/background_service_manager.dart';
import 'package:telecaller_app/core/controllers/socket_controller.dart';
import 'package:telecaller_app/core/services/theme_service.dart';
import 'package:telecaller_app/main.dart';

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
      await Get.put<LangService>(LangService()).init();


      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      await Get.put<ApiService>(ApiService()).init();
      await Get.putAsync<AuthController>(() async => AuthController());
      await Get.putAsync<NetworkService>(() async => NetworkService());
      Get.put(SocketController());
      await Get.putAsync<ThemeService>(() async {
        final service = ThemeService();
        service.init();
        return service;
      });

      bool isNotificationSetup = Storage.getValue('notification_setup') == true;
      bool isBackgroundServiceSetup =
          Storage.getValue('backgroundService_setup') == true;
      print('Notification setup done: $isNotificationSetup');
      print('BackgroundService setup done: $isBackgroundServiceSetup');

      // ✅ Initialize services only if phone permission is granted

      if (isNotificationSetup) {
        var phonePermission = await Permission.phone.status;
        if (phonePermission.isGranted) {
          if (!Get.isRegistered<FCMService>()) {
            Get.put<FCMService>(FCMService(), permanent: true);
            await Get.find<FCMService>().init();
          }

          if (!Get.isRegistered<PhoneStatusService>()) {
            await Get.putAsync<PhoneStatusService>(
              () async => await PhoneStatusService().init(),
              permanent: true,
            );
          }
        }
      } else {
        logger.i("app not a found fcm ");
      }

      if (isBackgroundServiceSetup) {
        var phonePermission = await Permission.phone.status;

        if (phonePermission.isGranted) {
          await BackgroundServiceManager.initializeService();
          try {
            final token = await Storage.getToken();
            if (token != null && token.isNotEmpty) {
              print("🔑 Initializer: Syncing token to background service...");
              FlutterBackgroundService().invoke('set_token', {'token': token});
            }
          } catch (e) {
            print("⚠️ Initializer: Could not sync token: $e");
          }
        } else {
          logger.i("Phone permission not granted yet");
        }
      }
    } catch (err) {
      printInfo(info: '❌ Init error: $err');
      rethrow;
    }
  }
}
