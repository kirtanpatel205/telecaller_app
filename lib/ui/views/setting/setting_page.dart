import 'dart:developer';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_dimens.dart';
import 'package:telecaller_app/constants/app_routes.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/core/helpers/storage.dart';
import 'package:telecaller_app/core/services/background_service_manager.dart';
import '../home/home_controller.dart';

class SettingPage extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        log("refreshing_settings_page".tr);
      },
      child: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          MultiSliver(
            children: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 200.h,
                titleSpacing: 0,
                collapsedHeight: 200.h,
                leadingWidth: 0,
                backgroundColor: AppColors.themeColor.primaryColor,
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppDimens.radius40),
                    bottomRight: Radius.circular(AppDimens.radius40),
                  ),
                  borderSide: BorderSide.none,
                ),
                toolbarHeight: 180.h,
                title: Container(
                  height: 180.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimens.radius40),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "settings".tr,
                        style: AppTextStyle.bold7.copyWith(
                          color: AppColors.themeColor.cardColor,
                          fontSize: AppDimens.fontSize15,
                        ),
                      ),
                      Obx(
                        () => Row(
                          children: [
                            SizedBox(width: 20.w),
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.themeColor.primaryColor,
                                      width: 3.0,
                                    ),
                                  ),
                                  child: InkWell(
                                    child: Container(
                                      width: 80.w,
                                      height: 80.h,
                                      decoration: BoxDecoration(
                                        color: AppColors.themeColor.bgColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: 2,
                                        ),
                                      ),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: controller.authController.profile.value?.profile?.isNotEmpty == true
                                            ? Image.network(
                                                "https://api-test.digibulkmarketing.com${controller.authController.profile.value!.profile!}",
                                                fit: BoxFit.cover,
                                              )
                                            : Center(
                                                child: Text(
                                                  controller.authController.profile.value?.name?.substring(0, 1).toUpperCase() ?? "U",
                                                  style: AppTextStyle.bold15.copyWith(color: AppColors.themeColor.primaryColor),
                                                ),
                                              ),
                                      ).paddingAll(1.w),
                                    ),
                                    onTap: () {
                                      Get.toNamed(Routes.EDITPROFILE);
                                    },
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(4.w),
                                    decoration: BoxDecoration(
                                      color: AppColors.themeColor.primaryColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: Icon(Icons.edit, color: Colors.white, size: 12.sp),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 10.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.authController.profile.value?.name ?? "no_name".tr,
                                  style: AppTextStyle.bold9.copyWith(
                                    color: AppColors.themeColor.cardColor,
                                    fontSize: AppDimens.fontSize18,
                                  ),
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  controller.authController.profile.value?.phone ?? "",
                                  style: AppTextStyle.bold7.copyWith(
                                    color: AppColors.themeColor.cardColor,
                                    fontSize: AppDimens.fontSize11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Obx(() {
                  controller.isDarkMode.value;
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
                        Text(
                          "background_reliability".tr,
                          style: AppTextStyle.bold7.copyWith(
                            fontSize: AppDimens.fontSize14,
                            color: AppColors.themeColor.textPrimaryColor,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Card(
                          elevation: 0,
                          color: AppColors.themeColor.cardBgColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Column(
                              children: [
                                Text(
                                  "to_ensure_24_7_auto_calling_works_correctly_please_disable_b".tr,
                                  style: AppTextStyle.regular7.copyWith(fontSize: AppDimens.fontSize12),
                                ),
                                SizedBox(height: 15.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // BackgroundServiceManager.requestBatteryOptimizationExclusion();
                                      },
                                      icon: Icon(Icons.battery_alert, size: 18.sp),
                                      label: Text(
                                        "disable_battery_optimization".tr,
                                        style: TextStyle(fontSize: AppDimens.fontSize10),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.themeColor.primaryColor,
                                        foregroundColor: AppColors.themeColor.cardColor,
                                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                ElevatedButton.icon(
                                  onPressed: () => BackgroundServiceManager.openManufacturerSettings(),
                                  icon: Icon(Icons.settings_applications, size: 18.sp),
                                  label: Text(
                                    "open_manufacturer_settings_auto_start".tr,
                                    style: TextStyle(fontSize: AppDimens.fontSize10),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          "appearance".tr,
                          style: AppTextStyle.bold7.copyWith(
                            fontSize: AppDimens.fontSize14,
                            color: AppColors.themeColor.textPrimaryColor,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Card(
                          elevation: 0,
                          color: AppColors.themeColor.cardBgColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8.0.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.nightlight_round, color: AppColors.themeColor.primaryColor, size: 24.sp),
                                    SizedBox(width: 8.w),
                                    Text(
                                      "dark_mode".tr,
                                      style: AppTextStyle.medium7.copyWith(fontSize: AppDimens.fontSize14),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 40.h,
                                  width: 50.w,
                                  child: ThemeSwitcher(
                                    builder: (context) => DayNightSwitcher(
                                      isDarkModeEnabled: controller.isDarkMode.value,
                                      onStateChanged: (value) {
                                        controller.toggleTheme(value, context);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        InkWell(
                          onTap: () {
                            Get.toNamed(Routes.LANGUAGE);
                          },
                          child: Card(
                            elevation: 0,
                            color: AppColors.themeColor.cardBgColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12.w),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.language_outlined, color: AppColors.themeColor.primaryColor, size: 24.sp),
                                      SizedBox(width: 8.w),
                                      Text(
                                        "language".tr,
                                        style: AppTextStyle.medium7.copyWith(fontSize: AppDimens.fontSize14),
                                      ),
                                    ],
                                  ),
                                  Icon(Icons.arrow_forward_ios, size: 15.sp, color: AppColors.themeColor.primaryColor),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        InkWell(
                          onTap: () {
                            Storage.clearStorage();
                            Get.offAllNamed(Routes.WELCOME);
                          },
                          child: Padding(
                            padding: EdgeInsets.all(8.0.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout, color: Colors.red, size: 24.sp),
                                SizedBox(width: 8.w),
                                Text(
                                  "logout".tr,
                                  style: AppTextStyle.bold7.copyWith(
                                    color: Colors.red,
                                    fontSize: AppDimens.fontSize14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
