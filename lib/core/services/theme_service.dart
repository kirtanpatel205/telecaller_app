

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_constants.dart';
import 'package:telecaller_app/constants/app_theme.dart';
import 'package:telecaller_app/core/helpers/storage.dart';


class ThemeService extends GetxService {
  RxBool isDarkMode = false.obs;
  RxBool inProgress = false.obs;
  RxString primaryColorUpdateTrigger = ''.obs;


  void init() async {
    isDarkMode.value =
        Storage.getValue<bool>(AppConstants.IS_DARK_MODE) ?? false;
    primaryColorUpdateTrigger.value = Storage.getValue('theme_primary_color') ?? '';
  }

  void notifyPrimaryColorChange(String colorStr) {
    primaryColorUpdateTrigger.value = colorStr;
  }

  Future<bool> toggleTheme(BuildContext context, {bool? isDark}) async {
    if (!inProgress.value) {
      inProgress.value = true;

      if (isDark != null) {
        isDarkMode.value = isDark;
      } else {
        isDarkMode.toggle();
      }

      await Storage.saveValue(AppConstants.IS_DARK_MODE, isDarkMode.value);
      Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
      getCurrentStatusNavigationBarColor();

      await Future.delayed(const Duration(milliseconds: 500));
      inProgress.value = false;

      return true;
    } else {
      return false;
    }
  }

  getCurrentStatusNavigationBarColor() {
    if (!isDarkMode.value) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFFFFFFF),
        systemNavigationBarIconBrightness: Brightness.dark,
      ));
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF26242e),
        systemNavigationBarIconBrightness: Brightness.light,
      ));
    }
  }
}