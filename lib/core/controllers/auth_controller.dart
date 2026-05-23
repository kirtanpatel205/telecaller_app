import 'dart:developer';

import 'package:flutter_background_service/flutter_background_service.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl_phone_field2/phone_number.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telecaller_app/constants/app_constants.dart';
import 'package:telecaller_app/constants/app_routes.dart';
import 'package:telecaller_app/core/helpers/utils.dart';
import 'package:telecaller_app/core/models/login_response_entity.dart';
import 'package:telecaller_app/ui/widgets/Permission_Status_Screen_Permission.dart';

import '../controllers/socket_controller.dart';
import '../helpers/storage.dart';
import '../services/api_service.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:telecaller_app/core/services/background_service_manager.dart';
import 'package:telecaller_app/core/services/fcm_service.dart';
import 'package:telecaller_app/core/services/phone_status_service.dart';
import 'package:workmanager/workmanager.dart';

class AuthController extends GetxController {
  static AuthController to = Get.find();

  bool get isSignedIn =>
      Storage.hasData(AppConstants.USER_ID) &&
      GetStorage().hasData(AppConstants.TOKEN);

  ApiService api = Get.find();

  Rx<PhoneNumber> phoneNumber = Rx<PhoneNumber>(
    PhoneNumber(countryISOCode: 'IN', countryCode: '+91', number: ''),
  );

  void storePhoneNumber(PhoneNumber phoneNumber) {
    this.phoneNumber.value = phoneNumber;
    GetStorage().write(AppConstants.PHONE, {
      'countryISOCode': phoneNumber.countryISOCode,
      'countryCode': phoneNumber.countryCode,
      'number': phoneNumber.number,
    });
  }

  Rx<LoginResponseProfile?> profile = Rx<LoginResponseProfile?>(
    LoginResponseProfile(),
  );

  @override
  void onInit() {
    super.onInit();
    print("AuthController onInit");
    // profile.value = null;
  }

  @override
  void onReady() {
    print("AuthController onReady");
    super.onReady();
  }

  @override
  void onClose() {
    print("AuthController onClose");
    super.onClose();
  }

  Future<bool> _areAllPermissionsGranted() async {
    final permissions = [
      Permission.phone,
      Permission.notification,
      Permission.location,
      Permission.camera,
      Permission.systemAlertWindow,
      Permission.ignoreBatteryOptimizations,
    ];
    for (var perm in permissions) {
      try {
        final status = await perm.status;
        if (!status.isGranted) {
          print("❌ Auth: Permission ${perm.toString()} is not granted");
          return false;
        }
      } catch (e) {
        print("⚠️ Auth: Error checking permission $perm: $e");
        return false;
      }
    }
    print("✅ Auth: All permissions are already granted at OS level");
    return true;
  }

  Future<void> _setupBackgroundServices() async {
    try {
      await Storage.saveValue('permissions_shown', true);
      await Storage.saveValue('notification_setup', true);
      await Storage.saveValue('backgroundService_setup', true);

      // Fetch SIM info
      if (await Permission.phone.isGranted) {
        await BackgroundServiceManager.fetchAndSaveSimInfo();
      }

      // Initialize background service
      try {
        await BackgroundServiceManager.initializeService();
        print("✅ Background service initialized");
      } catch (e) {
        print("❌ Background service error: $e");
      }

      final service = FlutterBackgroundService();
      final isServiceRunning = await service.isRunning();
      if (isServiceRunning) {
        try {
          await Future.delayed(Duration(milliseconds: 500));
          service.invoke("syncNow");
        } catch (e) {
          print("❌ BackgroundService invoke error: $e");
        }
      }

      try {
        if (!Get.isRegistered<FCMService>()) {
          final fcm = FCMService();
          Get.put<FCMService>(fcm, permanent: true);
          await fcm.init();
        }
        if (!Get.isRegistered<PhoneStatusService>()) {
          await Get.putAsync<PhoneStatusService>(
            () async => await PhoneStatusService().init(),
            permanent: true,
          );
        }
      } catch (e) {
        print("⚠️ Service initialization error: $e");
      }
    } catch (e) {
      print("❌ Error in background service setup: $e");
    }
  }

  Future<void> checkUserManually(LoginResponseEntity entity) async {
    if (entity.status == true) {
      log("login success - ${entity.token}");
      Storage.saveValue(AppConstants.USER_ID, entity.profile?.id);
      Storage.saveValue(AppConstants.FIRE_USER_ID, entity.profile?.id);
      await Storage.saveToken(entity.token!);
      Storage.saveValue(AppConstants.PHONE, entity.profile?.phone);
      profile.value = entity.profile;

      // Check if all permissions are already granted at OS level
      bool allGranted = await _areAllPermissionsGranted();

      if (allGranted) {
        print("All permissions already granted. Performing background setup...");
        await _setupBackgroundServices();
        
        if (Get.isRegistered<SocketController>()) {
          Get.find<SocketController>().connectWithToken(entity.token!);
        }

        try {
          FlutterBackgroundService().invoke('set_token', {'token': entity.token!});
          print('🔑 Auth: Token synced to background service');
        } catch (e) {
          print('⚠️ Auth: Failed to sync token to background service: $e');
        }

        // Navigate directly to Home and bypass Permission screen!
        Get.offAllNamed(Routes.HOME);
        return;
      }

      bool permissionsShown = Storage.getValue('permissions_shown') ?? false;

      if (!permissionsShown) {
        print("Showing permissions screen for first time");
        Get.to(() => PermissionStatusScreen());
        return;
      }

      await Future.delayed(Duration(seconds: 2));

      if (Get.isRegistered<SocketController>()) {
        Get.find<SocketController>().connectWithToken(entity.token!);
      }

      try {
        FlutterBackgroundService().invoke('set_token', {'token': entity.token!});
        print('🔑 Auth: Token synced to background service');
      } catch (e) {
        print('⚠️ Auth: Failed to sync token to background service: $e');
      }
    }

    // ✅ Only reaches here when NOT showing permissions screen
    print("Permissions already shown, going to Home");
    Get.offAllNamed(Routes.HOME);
  }

  Future refreshProfile() async {
    LoginResponseProfile profileEntity = await api.profile();


    if (profileEntity != null) {
      profile.value = profileEntity;
      print("refresh profile ${profileEntity.name}");
    }
  }

  Future<void> signOut({bool localOnly = false}) async {
    print("🔴 Signing out (localOnly: $localOnly)...");
    try {
      // 1. Server-side logout (Best effort)
      if (!localOnly) {
        try {
          final apiResponse = await api.sessionLogout();
          if (apiResponse.status == true) {
            Utils.showSnackbar(apiResponse.message);
            print("✅ Server logout successful");
          } else {
            print("⚠️ Server logout failed: ${apiResponse.message}");
          }
        } catch (e) {
          print("⚠️ Server logout request failed (token might be invalid or network error): $e");
        }
      } else {
        print("⏭️ Skipping server logout (localOnly)");
      }

      // 2. Stop Background Service
      try {
        final service = FlutterBackgroundService();
        bool isRunning = await service.isRunning();
        if (isRunning) {
          service.invoke("stopService");
          service.invoke("stop"); // invoke both to be extremely safe
          print("🛑 Background service stop/stopService signal sent");
        }
      } catch (e) {
        print("⚠️ Failed to stop background service: $e");
      }

      // 3. Cancel all Workmanager background tasks
      try {
        await Workmanager().cancelAll();
        print("🛑 Workmanager watchdog tasks cancelled");
      } catch (e) {
        print("⚠️ Failed to cancel Workmanager: $e");
      }

      // 4. Clear Local Storage (GetStorage & SharedPreferences)
      await Storage.clearStorage();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      print("✅ Local session cleared");

    } catch (e) {
      print("❌ SignOut Error: $e");
    } finally {
      // 5. Always navigate to welcome screen
      Get.offAllNamed(Routes.WELCOME);
    }
  }
}

