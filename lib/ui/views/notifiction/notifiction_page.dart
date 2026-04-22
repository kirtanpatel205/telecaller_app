import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/ui/views/home/home_controller.dart';
import 'package:telecaller_app/constants/app_dimens.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/constants/app_colors.dart';

class NotifictionPage extends GetView<HomeController>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.themeColor.scaffoldBackgroundColor,
      body: Center(
        child: Text(
          "notification_page".tr,
          style: AppTextStyle.medium7.copyWith(
            fontSize: AppDimens.fontSize16,
            color: AppColors.themeColor.textSecondaryColor,
          ),
        ),
      ),
    );
  }
}