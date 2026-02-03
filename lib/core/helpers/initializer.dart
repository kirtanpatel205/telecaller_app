

// import 'package:dbm_emp/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';


import 'package:firebase_core/firebase_core.dart';
import 'package:telecaller_app/core/controllers/auth_controller.dart';
import 'package:telecaller_app/core/helpers/storage.dart';
import 'package:telecaller_app/core/services/api_service.dart';

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


      printInfo(info: '✅ All services ready');
    } catch (err) {
      printInfo(info: '❌ Init error: $err');
      rethrow;
    }
  }
}
