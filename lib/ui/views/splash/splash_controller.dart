import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
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
  static const _channel = MethodChannel(
    'com.digibulkmarketing.telecaller_app/lockscreen',
  );
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
        Permission.location,
        Permission.camera,
        Permission.systemAlertWindow,
        Permission.ignoreBatteryOptimizations,
      ];

      for (var permission in requiredPermissions) {
        final status = await permission.status;
        if (!status.isGranted) {
          print("❌ Splash: Permission denied: ${permission.toString()}");
          return false;
        }
      }
      print("✅ Splash: All 6 permissions are granted");
      return true;
    } catch (e) {
      print("⚠️ Splash: Error checking permissions: $e");
      return false;
    }
  }

  Future<void> timeOut() async {
    print(
      "isSignedIn: ${authController.isSignedIn}, "
      "hasUserId: ${Storage.hasData(AppConstants.USER_ID)}",
    );

    await Future.delayed(const Duration(milliseconds: 500));

    // ✅ Check actual OS permissions
    final bool allPermissionsGranted = await _areAllPermissionsGranted();

    // ✅ Case 1: Fully logged in + all permissions → Setup and HOME
    if (authController.isSignedIn &&
        Storage.hasData(AppConstants.USER_ID) &&
        allPermissionsGranted) {
      print(
        "✅ Case 1: Permissions fully granted. Setting up background service & HOME",
      );

      // Auto-save setup flags to bypass setup screen next time
      await Storage.saveValue('permissions_shown', true);
      await Storage.saveValue('notification_setup', true);
      await Storage.saveValue('backgroundService_setup', true);

      // Pre-fetch SIM info and startup service
      if (await Permission.phone.isGranted) {
        await BackgroundServiceManager.fetchAndSaveSimInfo();
      }
      try {
        await BackgroundServiceManager.initializeService();
        final service = FlutterBackgroundService();
        if (await service.isRunning()) {
          service.invoke("syncNow");
        }
      } catch (e) {
        print("❌ Splash: Background service startup error: $e");
      }

      // Xiaomi optimizations check
      try {
        final bool isXiaomi = await _channel.invokeMethod('isXiaomi');
        if (isXiaomi) {
          final bool optimizationShown =
              Storage.getValue('xiaomi_optimization_shown') ?? false;
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

    // ✅ Case 2: Logged in but missing some permissions → Permission Screen
    if (authController.isSignedIn &&
        Storage.hasData(AppConstants.USER_ID) &&
        !allPermissionsGranted) {
      print(
        "⚠️ Case 2: Permissions missing or revoked, going to Permission Screen",
      );
      await Storage.saveValue('permissions_shown', false);

      await Future.delayed(const Duration(milliseconds: 300));
      Get.offAll(
        () => PermissionStatusScreen(),
        transition: Transition.fadeIn,
        duration: Duration(milliseconds: 500),
      );
      return;
    }

    // ✅ Case 3: Logged in but USER_ID missing → Force Logout
    if (authController.isSignedIn && !Storage.hasData(AppConstants.USER_ID)) {
      print("❌ Case 3: USER_ID missing, logging out");
      await authController.signOut();
      Get.offAllNamed(Routes.WELCOME);
      return;
    }

    // ✅ Case 4: Not logged in → Welcome
    print("⚠️ Case 4: Not signed in, going to WELCOME");
    Get.offAllNamed(Routes.WELCOME);
  }
}
