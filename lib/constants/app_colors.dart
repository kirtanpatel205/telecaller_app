import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:get/get_core/src/get_main.dart';

class AppColors {
  const AppColors._();

  static ThemeColor get themeColor =>
      Get.isDarkMode ? darkThemeColor : lightThemeColor;

  static ThemeColor get lightThemeColor => new ThemeColor(
    scaffoldBackgroundColor: Color(0xFFF7F7F7),
        primaryColor: Color(0xff0084FE),
        textPrimaryColor: Color(0xff000000),
        textSecondaryColor: Color(0xff676767),
        otpRightColor: Color(0xFF00C853),
        otpWrongColor: Color(0xFFD50000),
        cardColor: Color(0xFFFFFFFF),
        callPendingColor: Color(0xFFFF9871),
        closeLeadsColor: Color(0xFF029A95),
        totalOrderColor: Color(0xFFFFB64D),
        sellerColor: Color(0xFFFF5C00),
        resellerColor: Color(0xFF8C39C3),
        rebrandColor: Color(0xFF39c38D),
        pendingColor: Color(0xFFF50057),
        cancelColor: Color(0xFFFF6D00),
        completeColor: Color(0xFF28A745),
        bgColor: Color(0xFFF7F7F7),
        bordercolror: Color(0xFFD9D9D9),
        orderPendingColor: Color(0xFFFF0076),
        orderPendingBgColor: Color(0xFFF6B6D4),
        deletecardcolor: Color(0xFFFF3333),
        couponPercentageColor: Color(0xFF73BBFE),
        completedColor: Color(0xFF28A745),
        completedBgColor: Color(0xFFD1FFDB),
        cancleorderColor: Color(0xFF6D00),
        cancelBgColor: Color(0xFFFFEAD1),
        failColor: Color(0xFFEB0C04),
        failBgColor: Color(0xFFFFD1D1),
        totalkeyColor: Color(0xffeee5f3),
        totalkeyiconColor: Color(0xff915EFE),
        avilablekeyColor: Color(0xffdae9ff),
        availablekeyiconColor: Color(0xff45A6FF),
        activekeyColor: Color(0xfff9f2e5),
        activekeyiconColor: Color(0xffE59700),
        expairekeyColor: Color(0xfff4e8e7),
        expairekeyiconColor: Color(0xffF58274),
      );

  static ThemeColor get darkThemeColor => new ThemeColor(
        scaffoldBackgroundColor: Color(0xFF171617),
        primaryColor: Color(0xff3298CC),
        couponPercentageColor: Color(0xFF73BBFE),
        textPrimaryColor: Color(0xffffffff),
        textSecondaryColor: Color(0x67676767),
        otpRightColor: Color(0xFF00C853),
        otpWrongColor: Color(0xFFD50000),
        cardColor: Color(0xFF000000),
        callPendingColor: Color(0xFFFF9871),
        closeLeadsColor: Color(0xFF029A95),
        totalOrderColor: Color(0xFFFFB64D),
        sellerColor: Color(0xFFFF5C00),
        resellerColor: Color(0xFF8C39C3),
        rebrandColor: Color(0xFF39c38D),
        pendingColor: Color(0xFFF50057),
        cancelColor: Color(0xFFFF6D00),
        completeColor: Color(0xFF28A745),
        bgColor: Color(0x171617),
        bordercolror: Color(0xFFD9D9D9),
        orderPendingColor: Color(0xFFFF0076),
        orderPendingBgColor: Color(0xFFF6B6D4),
        deletecardcolor: Color(0xFFFF3333),
        completedColor: Color(0xFF28A745),
        completedBgColor: Color(0xFFD1FFDB),
        cancleorderColor: Color(0xFF6D00),
        cancelBgColor: Color(0xFFFFEAD1),
        failColor: Color(0xFFEB0C04),
        failBgColor: Color(0xFFFFD1D1),
        totalkeyColor: Color(0xffdae9ff),
        totalkeyiconColor: Color(0xff915EFE),
        avilablekeyColor: Color(0xffdae9ff),
        availablekeyiconColor: Color(0xff45A6FF),
        activekeyColor: Color(0xfff9f2e5),
        activekeyiconColor: Color(0xffE59700),
        expairekeyColor: Color(0xfff4e8e7),
        expairekeyiconColor: Color(0xffF58274),
      );
}

class ThemeColor {
  Color primaryColor;
  Color textPrimaryColor;
  Color textSecondaryColor;
  Color otpRightColor;
  Color otpWrongColor;
  Color cardColor;
  Color totalOrderColor;
  Color closeLeadsColor;
  Color callPendingColor;
  Color sellerColor;
  Color resellerColor;
  Color rebrandColor;
  Color pendingColor;
  Color orderPendingColor;
  Color orderPendingBgColor;
  Color bgColor;
  Color cancelColor;
  Color completeColor;
  Color bordercolror;
  Color deletecardcolor;
  Color couponPercentageColor;

  Color completedColor;
  Color completedBgColor;
  Color cancleorderColor;
  Color cancelBgColor;
  Color failColor;
  Color failBgColor;
  Color totalkeyColor;
  Color avilablekeyColor;
  Color activekeyColor;
  Color expairekeyColor;
  Color totalkeyiconColor;
  Color availablekeyiconColor;
  Color activekeyiconColor;
  Color expairekeyiconColor;
  Color scaffoldBackgroundColor;

  ThemeColor({
    required this.primaryColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
    required this.otpRightColor,
    required this.otpWrongColor,
    required this.cardColor,
    required this.bgColor,
    required this.callPendingColor,
    required this.closeLeadsColor,
    required this.totalOrderColor,
    required this.sellerColor,
    required this.resellerColor,
    required this.rebrandColor,
    required this.pendingColor,
    required this.orderPendingColor,
    required this.orderPendingBgColor,
    required this.cancelColor,
    required this.completeColor,
    required this.bordercolror,
    required this.deletecardcolor,
    required this.couponPercentageColor,
    required this.cancleorderColor,
    required this.cancelBgColor,
    required this.completedColor,
    required this.completedBgColor,
    required this.failColor,
    required this.failBgColor,
    required this.totalkeyColor,
    required this.avilablekeyColor,
    required this.activekeyColor,
    required this.expairekeyColor,
    required this.totalkeyiconColor,
    required this.availablekeyiconColor,
    required this.activekeyiconColor,
    required this.expairekeyiconColor, required this.scaffoldBackgroundColor,
  });
}
