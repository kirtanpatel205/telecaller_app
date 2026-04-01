import 'dart:developer';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:get_storage/get_storage.dart';
import 'package:getwidget/getwidget.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:telecaller_app/constants/app_colors.dart';
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
        log("Refreshing Settings Page");
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
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  borderSide: BorderSide.none,
                ),
                // floating: true,
                toolbarHeight: 180.h,
                title: Container(
                  height: 180.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    // color: Colors.black,
                    // gradient: RadialGradient(
                    //   center: Alignment(0.0, 0.0), // near the top right
                    //   radius: 1.5,
                    //   colors: [
                    //     AppColors.themeColor.primaryColor,
                    //     AppColors.themeColor.bgColor,
                    //   ],
                    //   stops: [0.4, 1],
                    // ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "settings".tr,
                        style: AppTextStyle.bold7.copyWith(
                          color: AppColors.themeColor.cardColor,
                          fontSize: 15,
                        ),
                      ),
                      Obx(
                        () => Row(
                          children: [
                            SizedBox(width: 20),
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          AppColors
                                              .themeColor
                                              .primaryColor, // Border color
                                      width: 3.0, // Border width
                                    ),
                                  ),
                                  child: InkWell(
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: AppColors.themeColor.bgColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: 2,
                                        ),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          // border: Border.all(
                                          //   color: AppColors.themeColor.primaryColor,
                                          //   width: 2.0,
                                          // ),
                                        ),
                                        // padding: EdgeInsets.all(2),
                                        clipBehavior: Clip.antiAlias,
                                        // ensures child respects circle shape
                                        child:
                                            controller
                                                        .authController
                                                        .profile
                                                        .value
                                                        ?.profile
                                                        ?.isNotEmpty ==
                                                    true
                                                ? Image.network(
                                                  "https://api-test.digibulkmarketing.com${controller.authController.profile.value!.profile!}",
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return const Icon(
                                                      Icons.error,
                                                    );
                                                  },
                                                )
                                                : Center(
                                                  child: Text(
                                                    controller
                                                                .authController
                                                                .profile
                                                                .value
                                                                ?.name
                                                                ?.isNotEmpty ==
                                                            true
                                                        ? controller
                                                            .authController
                                                            .profile
                                                            .value!
                                                            .name![0]
                                                        : "N",
                                                    style: AppTextStyle
                                                        .regular12
                                                        .copyWith(
                                                          fontSize: 40,
                                                          color:
                                                              AppColors
                                                                  .themeColor
                                                                  .primaryColor,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                  ),
                                                ),
                                      ).paddingAll(1),
                                    ),
                                    onTap: () {
                                      Get.toNamed(Routes.EDITPROFILE);
                                    },
                                  ),
                                  // ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color:
                                            AppColors.themeColor.bordercolror,
                                        width: 3,
                                      ),
                                      borderRadius: BorderRadius.circular(50),
                                      color: AppColors.themeColor.bgColor,
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        Get.toNamed(Routes.EDITPROFILE);
                                      },
                                      child: Icon(
                                        Icons.edit,
                                        color:
                                            AppColors.themeColor.bordercolror,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller
                                              .authController
                                              .profile
                                              .value
                                              ?.name
                                              ?.isNotEmpty ==
                                          true
                                      ? controller
                                          .authController
                                          .profile
                                          .value!
                                          .name
                                          .toString()
                                      : "No Name",
                                  style: AppTextStyle.bold9.copyWith(
                                    color: AppColors.themeColor.cardColor,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  controller
                                              .authController
                                              .profile
                                              .value
                                              ?.phone
                                              ?.isNotEmpty ==
                                          true
                                      ? controller
                                          .authController
                                          .profile
                                          .value!
                                          .phone
                                          .toString()
                                      : "",
                                  style: AppTextStyle.bold7.copyWith(
                                    color: AppColors.themeColor.cardColor,
                                    fontSize: 11,
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

              Obx(() {
                controller.isDarkMode.value; // Access observable to register dependency
                return Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    SizedBox(height: 20),
                    Text(
                      "Background Reliability",
                      style: AppTextStyle.bold7.copyWith(
                        color: AppColors.themeColor.primaryColor,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.themeColor.primaryColor.withOpacity(
                          0.1,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: AppColors.themeColor.primaryColor.withOpacity(
                            0.3,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "To ensure 24/7 auto-calling works correctly, please disable battery optimization and enable 'Auto-start' for this app.",
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed:
                                    () {
                                      // BackgroundServiceManager.requestBatteryOptimizationExclusion(),

                                    },
                                icon: Icon(Icons.battery_alert, size: 18),
                                label: Text(
                                  "Disable Battery Optimization",
                                  style: TextStyle(fontSize: 10),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppColors.themeColor.primaryColor,
                                  foregroundColor:
                                      AppColors.themeColor.cardColor,
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed:
                                () =>
                                    BackgroundServiceManager.openManufacturerSettings(),
                            icon: Icon(Icons.settings_applications, size: 18),
                            label: Text(
                              "Open Manufacturer Settings (Auto-start)",
                              style: TextStyle(fontSize: 10),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    InkWell(
                      onTap: () {
                        // Optional: Add onTap if needed
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 2.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.nightlight_round,
                                    color: AppColors.themeColor.primaryColor,
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    "dark mode".tr,
                                    style: AppTextStyle.medium9.copyWith(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Container(
                                height: 40,
                                width: 50,
                                child: ThemeSwitcher(
                                  builder:
                                      (context) => DayNightSwitcher(
                                        isDarkModeEnabled:
                                            controller.isDarkMode.value,
                                        onStateChanged: (value) {
                                          controller.toggleTheme(
                                            value,
                                            context,
                                          );
                                        },
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        Storage.clearStorage();
                        Get.offAllNamed(Routes.WELCOME);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              "logout".tr,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 10),
                  ],
                ),
              );
            }),
            ],
          ),
        ],
      ),
    );
  }
}
