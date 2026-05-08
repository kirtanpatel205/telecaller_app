import 'dart:async';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telecaller_app/constants/app_constants.dart';
import 'package:telecaller_app/constants/app_routes.dart';
import 'package:telecaller_app/core/controllers/auth_controller.dart';
import 'package:telecaller_app/core/helpers/storage.dart';
import 'package:telecaller_app/ui/widgets/Permission_Status_Screen_Permission.dart';
import 'package:telecaller_app/ui/widgets/optimization_guide_dialog.dart';
import 'package:flutter/services.dart';
import 'package:telecaller_app/core/services/background_service_manager.dart';

class SplashController extends GetxController {
  static const _channel = MethodChannel('com.digibulkmarketing.telecaller_app/lockscreen');
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
    // Pre-fetch SIM info as early as possible if permission is already granted

    startTime();
  }



  startTime() async {
    var _duration = Duration(milliseconds: 2000);
    return Timer(_duration, timeOut);
  }

  // ✅ Check if all required permissions are still granted
  Future<bool> _areAllPermissionsGranted() async {
    try {
      final requiredPermissions = [
        Permission.phone,
        Permission.notification,
        Permission.systemAlertWindow,
        Permission.ignoreBatteryOptimizations,
      ];

      for (var permission in requiredPermissions) {
        final status = await permission.status;
        if (!status.isGranted) {
          print("❌ Permission denied: ${permission.toString()}");
          return false;
        }
      }
      print("✅ All permissions are granted");
      return true;
    } catch (e) {
      print("⚠️ Error checking permissions: $e");
      return false;
    }
  }

  Future<void> timeOut() async {
    print(
      "isSignedIn: ${authController.isSignedIn}, "
      "hasUserId: ${Storage.hasData(AppConstants.USER_ID)}",
    );

    await Future.delayed(const Duration(milliseconds: 500));

    // Read setup flags
    final bool permissionsShown =
        Storage.getValue('permissions_shown') ?? false;

    // ✅ Check actual permissions
    final bool allPermissionsGranted = await _areAllPermissionsGranted();

    print(
      "permissionsShown: $permissionsShown, allPermissionsGranted: $allPermissionsGranted",
    );

    // ✅ Case 1: Fully logged in + all permissions → HOME
    if (authController.isSignedIn &&
        Storage.hasData(AppConstants.USER_ID) &&
        permissionsShown &&
        allPermissionsGranted) {
      print("✅ Case 1: Checking for Xiaomi Optimizations then HOME");
      
      try {
        final bool isXiaomi = await _channel.invokeMethod('isXiaomi');
        if (isXiaomi) {
          final bool optimizationShown = Storage.getValue('xiaomi_optimization_shown') ?? false;
          if (!optimizationShown) {
            await Get.dialog(
              const OptimizationGuideDialog(isXiaomi: true),
              barrierDismissible: false,
            );
            await Storage.saveValue('xiaomi_optimization_shown', true);
          }
        }
      } catch (e) {
        print("Error checking Xiaomi in Splash: $e");
      }

      Get.offAllNamed(Routes.HOME);
      return;
    }

    // ✅ Case 2: Logged in but permission revoked → Back to permission screen
    if (authController.isSignedIn &&
        Storage.hasData(AppConstants.USER_ID) &&
        permissionsShown &&
        !allPermissionsGranted) {
      print("⚠️ Case 2: Permissions revoked, going to Permission Screen");
      await Storage.saveValue('permissions_shown', false);

      // ✅ Extra delay before navigating to permission screen
      await Future.delayed(const Duration(milliseconds: 300));
      Get.offAll(
        () => PermissionStatusScreen(),
        transition: Transition.fadeIn,
        duration: Duration(milliseconds: 500),
      );
      return;
    }

    // ✅ Case 3: Logged in but setup not complete → Permission screen
    if (authController.isSignedIn &&
        Storage.hasData(AppConstants.USER_ID) &&
        !permissionsShown) {
      print("⚠️ Case 3: Setup not done, going to Permission Screen");

      // ✅ Extra delay before showing permission screen
      await Future.delayed(const Duration(milliseconds: 300));
      Get.offAll(
        () => PermissionStatusScreen(),
        transition: Transition.fadeIn,
        duration: Duration(milliseconds: 500),
      );
      return;
    }

    // ✅ Case 4: Logged in but USER_ID missing → Logout
    if (authController.isSignedIn && !Storage.hasData(AppConstants.USER_ID)) {
      print("❌ Case 4: USER_ID missing, logging out");
      await authController.signOut();
      Get.offAllNamed(Routes.WELCOME);
      return;
    }

    // ✅ Case 5: Not logged in → Welcome
    print("⚠️ Case 5: Not signed in, going to WELCOME");
    Get.offAllNamed(Routes.WELCOME);
  }
}
