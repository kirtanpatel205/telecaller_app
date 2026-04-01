import 'dart:developer';

import 'package:flutter_background_service/flutter_background_service.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl_phone_field2/phone_number.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telecaller_app/constants/app_constants.dart';
import 'package:telecaller_app/constants/app_routes.dart';
import 'package:telecaller_app/core/models/login_response_entity.dart';
import 'package:telecaller_app/ui/widgets/Permission_Status_Screen_Permission.dart';

import '../controllers/socket_controller.dart';
import '../helpers/storage.dart';
import '../services/api_service.dart';

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

  Future<void> checkUserManually(LoginResponseEntity entity) async {
    if (entity.status == true) {
      log("login success - ${entity.token}");
      Storage.saveValue(AppConstants.USER_ID, entity.profile?.id);
      Storage.saveValue(AppConstants.FIRE_USER_ID, entity.profile?.id);
      await Storage.saveToken(entity.token!);
      Storage.saveValue(AppConstants.PHONE, entity.profile?.phone);
      profile.value = entity.profile;

      bool permissionsShown = Storage.getValue('permissions_shown') ?? false;

      if (!permissionsShown) {
        print("Showing permissions screen for first time");
        // ✅ Don't fall through — return after navigating
        Get.to(() => PermissionStatusScreen());  // also fixed the GETX warning
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

  Future<void> signOut() async {
    //   print("🔴 Signing out...");
    //   try {
    //     // ✅ Server par logout call karo
    //     try {
    //       final apiResponse = await api.sessionLogout();
    //       if (apiResponse.status == true) {
    //         print("✅ Server logout successful");
    //       } else {
    //         print("⚠️ Server logout failed: ${apiResponse.message}");
    //       }
    //     } catch (e) {
    //       // Token invalid ho to bhi continue karo local cleanup ke sath
    //       print("⚠️ Server logout request failed (token might be invalid): $e");
    //     }
    //
    //     // ✅ Local cleanup karo (server call successful ho ya fail)
    //     // await Storage.clearStorage();
    //     Storage.removeValue(AppConstants.USER_ID);
    //     Storage.removeValue(AppConstants.FIRE_USER_ID);
    //     Storage.removeValue(AppConstants.TOKEN);
    //     Storage.removeValue(AppConstants.PHONE);
    //     Storage.removeValue("notification_setup");
    //     Storage.removeValue("backgroundService_setup");
    //
    //     Storage.saveToSharedPrefs(AppConstants.ISLOGGING, false);
    //     final prefs = await SharedPreferences.getInstance();
    //     await prefs.clear();
    //
    //     // Stop background service
    //     final service = FlutterBackgroundService();
    //     bool isRunning = await service.isRunning();
    //     if (isRunning) {
    //       service.invoke("stop");
    //       print("🛑 Background service stopped");
    //       await Future.delayed(const Duration(milliseconds: 800));
    //     }
    //
    //     await NativeServiceBridge.stopOverlay();
    //     bool isLoggedIn = await prefs.getBool(AppConstants.ISLOGGING) ?? false;
    //     print("isLoggedIn after signout: $isLoggedIn");
    //     print("✅ User logged out successfully");
    //   } catch (e) {
    //     print("❌ SignOut Error: $e");
    //   } finally {
    //     // Always navigate to welcome screen
    //     Get.offAllNamed(Routes.WELCOME);
    //   }
    // }
  }
}
