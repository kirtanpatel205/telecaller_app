import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_routes.dart';
import 'package:telecaller_app/core/controllers/auth_controller.dart';
import 'package:telecaller_app/core/controllers/call_form_controller.dart';
import 'package:telecaller_app/core/services/fcm_service.dart';
import 'package:telecaller_app/ui/views/auto_dialer/autodialer_controller.dart';
import 'package:telecaller_app/ui/views/dashboard/dashboard_controller.dart';
import 'package:telecaller_app/ui/views/leads/leads_controller.dart';
import 'package:telecaller_app/ui/views/setting/setting_controller.dart';
import 'package:telecaller_app/core/services/theme_service.dart';
import 'package:flutter/material.dart';

class HomeController extends GetxController {
  RxInt currentTab = 0.obs;
  AuthController authController = Get.find();
  FCMService fcmService = Get.find();


  LeadsController leadsController = Get.put(LeadsController());
  AutoDialerController autoDialerController = Get.put(AutoDialerController());
  SettingController settingController = Get.put(SettingController());
  DashboardController dashboardController = Get.put(DashboardController());
  CallFormController callFormController = Get.put(CallFormController());

  // Theme support
  final ThemeService themeService = Get.find();
  RxBool get isDarkMode => themeService.isDarkMode;

  Future<void> toggleTheme(bool value, BuildContext context) async {
    // value is from DayNightSwitcher, but we use ThemeService to toggle
    // Context is needed for AnimatedThemeSwitcher
    await themeService.toggleTheme(context);
  }
  // FCMService fcmService = Get.put(FCMService().init());

  // FCMService FcmToken = Get.find();




  @override
  void onInit() async {
    super.onInit();
    await Get.put<FCMService>(FCMService()).init();
  }



  @override
  void onReady() {
    // TODO: implement onReady
    // authController.refreshProfile();
    super.onReady();
  }

  void onBottomTabChange(int index) {
    currentTab.value = index;
  }
}
