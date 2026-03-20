import 'package:animated_theme_switcher/animated_theme_switcher.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_constants.dart';
import 'package:telecaller_app/constants/app_theme.dart';
import 'package:telecaller_app/core/helpers/storage.dart';


class ThemeService extends GetxService {
  RxBool isDarkMode = true.obs;
  RxBool inProgress = false.obs;


  void init() async {
    isDarkMode.value =
        Storage.getValue<bool>(AppConstants.IS_DARK_MODE) ?? true;
  }

  Future<bool> toggleTheme(BuildContext context) async {
    if (!inProgress.value) {
      inProgress.value = true;

      //isDarkMode.value = Storage.getValue<bool>(AppConstants.IS_DARK_MODE) ?? true;
      isDarkMode.toggle();

      await Storage.saveValue(AppConstants.IS_DARK_MODE, isDarkMode.value);
      final theme = isDarkMode.value ? AppTheme.darkTheme : AppTheme.theme;
      ThemeSwitcher.of(context).changeTheme(
        theme: theme,
      );
      Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
      getCurrentStatusNavigationBarColor();

      await Future.delayed(Duration(milliseconds: 1500));
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