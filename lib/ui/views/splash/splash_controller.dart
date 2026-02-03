import 'dart:async';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_constants.dart';
import 'package:telecaller_app/constants/app_routes.dart';
import 'package:telecaller_app/core/controllers/auth_controller.dart';
import 'package:telecaller_app/core/helpers/storage.dart';

class SplashController extends GetxController {
  final AuthController authController = AuthController.to;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  @override
  void onReady() {
    super.onReady();
    startTime();
  }

  startTime() async {
    var _duration = Duration(milliseconds: 2000);
    return Timer(_duration, timeOut);
  }

  Future<void> timeOut() async {
    print(
      "isSignedIn: ${authController.isSignedIn}, "
          "hasUserId: ${Storage.hasData(AppConstants.USER_ID)}",
    );

    // Small delay (optional – splash smooth banava mate)
    await Future.delayed(const Duration(milliseconds: 500));

    // Case 1: User signed in + USER_ID exists
    if (authController.isSignedIn &&
        Storage.hasData(AppConstants.USER_ID)) {
      Get.offAllNamed(Routes.HOME);
      return;
    }

    // Case 2: Signed in but USER_ID missing (corrupt session)
    if (authController.isSignedIn &&
        !Storage.hasData(AppConstants.USER_ID)) {
      await authController.signOut();
      Get.offAllNamed(Routes.WELCOME);
      return;
    }

    // Case 3: User not signed in
    Get.offAllNamed(Routes.WELCOME);
  }
}