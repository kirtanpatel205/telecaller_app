import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

class AppTheme {
  const AppTheme._();

  static List<ThemeData> themesList = [theme, darkTheme];

  static ThemeData get theme {
    final FlexSchemeColor _schemeLight = FlexSchemeColor.from(
      primary: AppColors.lightThemeColor.primaryColor,
      secondary: AppColors.lightThemeColor.textSecondaryColor,
      brightness: Brightness.light,
    );
    return FlexThemeData.light(
        scheme: FlexScheme.blue,
        colors: _schemeLight,
        scaffoldBackground: AppColors.lightThemeColor.bgColor,
        fontFamily: AppFonts.POPPINS);
  }

  static ThemeData get darkTheme {
    final FlexSchemeColor _schemeDark = FlexSchemeColor.from(
      primary: AppColors.darkThemeColor.primaryColor,
      secondary: AppColors.darkThemeColor.textSecondaryColor,
      brightness: Brightness.dark,
    );

    return FlexThemeData.dark(
        scheme: FlexScheme.blue,
        colors: _schemeDark,
        scaffoldBackground: AppColors.darkThemeColor.bgColor,
        fontFamily: AppFonts.POPPINS);
  }
}
