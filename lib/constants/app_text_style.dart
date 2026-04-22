
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimens.dart';

class AppTextStyle {
  AppTextStyle._();

// ------------------- Poopins - Bold -------------------------------///

  // static TextStyle get poppinTextStyle => TextStyle(
  //     fontFamily: AppFonts.POPPINS,
  //     color: AppColors.themeColor.textPrimaryColor
  // );

  static TextStyle get appBarTitleStyle => TextStyle(
      fontSize: AppDimens.fontSize18,
      fontWeight: FontWeight.bold,
      color: AppColors.themeColor.textPrimaryColor);

  static TextStyle get buttonTextStyle => TextStyle(
        fontSize: AppDimens.fontSize16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get bodyTextStyle => TextStyle(
      fontSize: AppDimens.fontSize14,
      fontWeight: FontWeight.w400,
      color: AppColors.themeColor.textPrimaryColor);

  static TextStyle get subTitleStyle => TextStyle(
      fontSize: AppDimens.fontSize12,
      fontWeight: FontWeight.w400,
      color: AppColors.themeColor.textSecondaryColor);

  static TextStyle get bold1 => TextStyle(fontSize: AppDimens.fontSize6, fontWeight: FontWeight.w100);
  static TextStyle get bold2 => TextStyle(fontSize: AppDimens.fontSize7, fontWeight: FontWeight.w200);
  static TextStyle get bold3 => TextStyle(fontSize: AppDimens.fontSize8, fontWeight: FontWeight.w300);
  static TextStyle get bold5 => TextStyle(fontSize: AppDimens.fontSize9, fontWeight: FontWeight.w400);
  static TextStyle get bold6 => TextStyle(fontSize: AppDimens.fontSize10, fontWeight: FontWeight.w500);
  static TextStyle get bold7 => TextStyle(fontSize: AppDimens.fontSize11, fontWeight: FontWeight.w600);
  static TextStyle get bold8 => TextStyle(fontSize: AppDimens.fontSize12, fontWeight: FontWeight.w700);
  static TextStyle get bold9 => TextStyle(fontSize: AppDimens.fontSize13, fontWeight: FontWeight.w800);
  static TextStyle get bold10 => TextStyle(fontSize: AppDimens.fontSize15, fontWeight: FontWeight.w900);
  static TextStyle get bold11 => TextStyle(fontSize: AppDimens.fontSize16, fontWeight: FontWeight.w900);
  static TextStyle get boldhome => TextStyle(fontSize: AppDimens.fontSize16, fontWeight: FontWeight.w600);
  static TextStyle get bold12 => TextStyle(fontSize: AppDimens.fontSize18, fontWeight: FontWeight.w500);
  static TextStyle get bold13 => TextStyle(fontSize: AppDimens.fontSize15, fontWeight: FontWeight.w500);
  static TextStyle get bold14 => TextStyle(fontSize: AppDimens.fontSize21, fontWeight: FontWeight.w700);
  static TextStyle get bold15 => TextStyle(fontSize: AppDimens.fontSize22, fontWeight: FontWeight.w600);
  static TextStyle get bold16 => TextStyle(fontSize: AppDimens.fontSize24, fontWeight: FontWeight.w300);
  static TextStyle get bold17 => TextStyle(fontSize: AppDimens.fontSize26, fontWeight: FontWeight.w700);
  static TextStyle get bold18 => TextStyle(fontSize: AppDimens.fontSize28, fontWeight: FontWeight.w500);
  static TextStyle get bold20 => TextStyle(fontSize: AppDimens.fontSize32, fontWeight: FontWeight.w800);

  static TextStyle get regular1 => TextStyle(fontSize: AppDimens.fontSize6, fontWeight: FontWeight.w100);
  static TextStyle get regular2 => TextStyle(fontSize: AppDimens.fontSize7, fontWeight: FontWeight.w200);
  static TextStyle get regular3 => TextStyle(fontSize: AppDimens.fontSize8, fontWeight: FontWeight.w300);
  static TextStyle get regular5 => TextStyle(fontSize: AppDimens.fontSize9, fontWeight: FontWeight.w400);
  static TextStyle get regular6 => TextStyle(fontSize: AppDimens.fontSize10, fontWeight: FontWeight.w500);
  static TextStyle get regular7 => TextStyle(fontSize: AppDimens.fontSize11, fontWeight: FontWeight.w600);
  static TextStyle get regular10 => TextStyle(fontSize: AppDimens.fontSize15, fontWeight: FontWeight.w900);
  static TextStyle get regular11 => TextStyle(fontSize: AppDimens.fontSize16, fontWeight: FontWeight.w900);
  static TextStyle get regular12 => TextStyle(fontSize: AppDimens.fontSize18, fontWeight: FontWeight.w500);
  static TextStyle get regular13 => TextStyle(fontSize: AppDimens.fontSize20, fontWeight: FontWeight.w600);
  static TextStyle get regular14 => TextStyle(fontSize: AppDimens.fontSize21, fontWeight: FontWeight.w700);
  static TextStyle get regular15 => TextStyle(fontSize: AppDimens.fontSize22, fontWeight: FontWeight.w600);
  static TextStyle get regular16 => TextStyle(fontSize: AppDimens.fontSize24, fontWeight: FontWeight.w300);
  static TextStyle get regular17 => TextStyle(fontSize: AppDimens.fontSize26, fontWeight: FontWeight.w700);
  static TextStyle get regular18 => TextStyle(fontSize: AppDimens.fontSize28, fontWeight: FontWeight.w500);
  static TextStyle get regular19 => TextStyle(fontSize: AppDimens.fontSize30, fontWeight: FontWeight.w700);
  static TextStyle get regular20 => TextStyle(fontSize: AppDimens.fontSize32, fontWeight: FontWeight.w800);

  static TextStyle get semiBold1 => TextStyle(fontSize: AppDimens.fontSize6, fontWeight: FontWeight.w100);
  static TextStyle get semiBold3 => TextStyle(fontSize: AppDimens.fontSize8, fontWeight: FontWeight.w300);
  static TextStyle get semiBold5 => TextStyle(fontSize: AppDimens.fontSize9, fontWeight: FontWeight.w400);
  static TextStyle get semiBold6 => TextStyle(fontSize: AppDimens.fontSize10, fontWeight: FontWeight.w500);
  static TextStyle get semiBold8 => TextStyle(fontSize: AppDimens.fontSize12, fontWeight: FontWeight.w700);
  static TextStyle get semiBold9 => TextStyle(fontSize: AppDimens.fontSize13, fontWeight: FontWeight.w800);
  static TextStyle get semiBold10 => TextStyle(fontSize: AppDimens.fontSize15, fontWeight: FontWeight.w900);
  static TextStyle get semiBold11 => TextStyle(fontSize: AppDimens.fontSize16, fontWeight: FontWeight.w900);
  static TextStyle get semiBold12 => TextStyle(fontSize: AppDimens.fontSize18, fontWeight: FontWeight.w500);
  static TextStyle get semiBold13 => TextStyle(fontSize: AppDimens.fontSize20, fontWeight: FontWeight.w600);
  static TextStyle get semiBold14 => TextStyle(fontSize: AppDimens.fontSize21, fontWeight: FontWeight.w700);
  static TextStyle get semiBold15 => TextStyle(fontSize: AppDimens.fontSize22, fontWeight: FontWeight.w600);
  static TextStyle get semiBold16 => TextStyle(fontSize: AppDimens.fontSize24, fontWeight: FontWeight.w300);
  static TextStyle get semiBold17 => TextStyle(fontSize: AppDimens.fontSize26, fontWeight: FontWeight.w700);
  static TextStyle get semiBold18 => TextStyle(fontSize: AppDimens.fontSize28, fontWeight: FontWeight.w500);
  static TextStyle get semiBold19 => TextStyle(fontSize: AppDimens.fontSize30, fontWeight: FontWeight.w700);
  static TextStyle get semiBold20 => TextStyle(fontSize: AppDimens.fontSize32, fontWeight: FontWeight.w800);

  static TextStyle get medium => TextStyle(fontSize: AppDimens.fontSize10, fontWeight: FontWeight.w100);
  static TextStyle get medium2 => TextStyle(fontSize: AppDimens.fontSize7, fontWeight: FontWeight.w200);
  static TextStyle get medium3 => TextStyle(fontSize: AppDimens.fontSize8, fontWeight: FontWeight.w300);
  static TextStyle get medium5 => TextStyle(fontSize: AppDimens.fontSize9, fontWeight: FontWeight.w400);
  static TextStyle get medium7 => TextStyle(fontSize: AppDimens.fontSize11, fontWeight: FontWeight.w600);
  static TextStyle get medium8 => TextStyle(fontSize: AppDimens.fontSize14, fontWeight: FontWeight.w500);
  static TextStyle get medium11 => TextStyle(fontSize: AppDimens.fontSize16, fontWeight: FontWeight.w900);
  static TextStyle get medium13 => TextStyle(fontSize: AppDimens.fontSize20, fontWeight: FontWeight.w600);
  static TextStyle get medium14 => TextStyle(fontSize: AppDimens.fontSize21, fontWeight: FontWeight.w700);
  static TextStyle get medium15 => TextStyle(fontSize: AppDimens.fontSize22, fontWeight: FontWeight.w600);
  static TextStyle get medium16 => TextStyle(fontSize: AppDimens.fontSize24, fontWeight: FontWeight.w300);
  static TextStyle get medium17 => TextStyle(fontSize: AppDimens.fontSize26, fontWeight: FontWeight.w700);
  static TextStyle get medium18 => TextStyle(fontSize: AppDimens.fontSize28, fontWeight: FontWeight.w500);
  static TextStyle get medium19 => TextStyle(fontSize: AppDimens.fontSize30, fontWeight: FontWeight.w700);
  static TextStyle get medium20 => TextStyle(fontSize: AppDimens.fontSize32, fontWeight: FontWeight.w800);

  static TextStyle get extraBold1 => TextStyle(fontSize: AppDimens.fontSize6, fontWeight: FontWeight.w100);
  static TextStyle get extraBold2 => TextStyle(fontSize: AppDimens.fontSize7, fontWeight: FontWeight.w200);
  static TextStyle get extraBold3 => TextStyle(fontSize: AppDimens.fontSize8, fontWeight: FontWeight.w300);
  static TextStyle get extraBold5 => TextStyle(fontSize: AppDimens.fontSize9, fontWeight: FontWeight.w400);
  static TextStyle get extraBold6 => TextStyle(fontSize: AppDimens.fontSize10, fontWeight: FontWeight.w500);
  static TextStyle get extraBold7 => TextStyle(fontSize: AppDimens.fontSize11, fontWeight: FontWeight.w600);
  static TextStyle get extraBold8 => TextStyle(fontSize: AppDimens.fontSize12, fontWeight: FontWeight.w700);
  static TextStyle get extraBold9 => TextStyle(fontSize: AppDimens.fontSize13, fontWeight: FontWeight.w800);
  static TextStyle get extraBold10 => TextStyle(fontSize: AppDimens.fontSize15, fontWeight: FontWeight.w900);
  static TextStyle get extraBold11 => TextStyle(fontSize: AppDimens.fontSize16, fontWeight: FontWeight.w900);
  static TextStyle get extraBold12 => TextStyle(fontSize: AppDimens.fontSize18, fontWeight: FontWeight.w500);
  static TextStyle get extraBold13 => TextStyle(fontSize: AppDimens.fontSize20, fontWeight: FontWeight.w600);
  static TextStyle get extraBold14 => TextStyle(fontSize: AppDimens.fontSize21, fontWeight: FontWeight.w700);
  static TextStyle get extraBold15 => TextStyle(fontSize: AppDimens.fontSize22, fontWeight: FontWeight.w600);
  static TextStyle get extraBold16 => TextStyle(fontSize: AppDimens.fontSize24, fontWeight: FontWeight.w300);
  static TextStyle get extraBold17 => TextStyle(fontSize: AppDimens.fontSize26, fontWeight: FontWeight.w700);
  static TextStyle get extraBold18 => TextStyle(fontSize: AppDimens.fontSize28, fontWeight: FontWeight.w500);
  static TextStyle get extraBold19 => TextStyle(fontSize: AppDimens.fontSize30, fontWeight: FontWeight.w700);
  static TextStyle get extraBold20 => TextStyle(fontSize: AppDimens.fontSize32, fontWeight: FontWeight.w800);
}
