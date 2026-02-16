import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_routes.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/ui/views/overlay/overlay_pages.dart';

import '../home/home_controller.dart';
import '../notifiction/notifiction_page.dart';

class DashboardPage extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,

        // 👉 PROFILE IMAGE
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Bounce(
            onTap: () {
              Get.toNamed(Routes.EDITPROFILE);
            },
            child: Obx(() => Container(
              height: 40,
              width: 40,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: controller.authController.profile.value?.profile
                  ?.isNotEmpty ==
                  true
                  ? Image.network(
                "https://api-test.digibulkmarketing.com${controller.authController.profile.value!.profile!}",
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.error),
              )
                  : Center(
                child: Text(
                  controller.authController.profile.value?.name
                      ?.isNotEmpty ==
                      true
                      ? controller
                      .authController.profile.value!.name![0]
                      : "N",
                  style: AppTextStyle.regular12.copyWith(
                    fontSize: 20,
                    color:
                    AppColors.themeColor.primaryColor,
                  ),
                ),
              ),
            )),
          ),
        ),

        // 👉 NAME + SUBTITLE
        title: Obx(() => InkWell(
          onTap: () {
            Get.toNamed(Routes.EDITPROFILE);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.authController.profile.value?.name ??
                    "No Name",
                style: AppTextStyle.semiBold8.copyWith(
                  fontSize: 12,
                  color:
                  AppColors.themeColor.textPrimaryColor,
                ),
              ),
              Text(
                'How Are You Today',
                style: AppTextStyle.regular6.copyWith(
                  color:
                  AppColors.themeColor.textPrimaryColor,
                ),
              ),
            ],
          ),
        )),

        // 👉 NOTIFICATION ICON
        actions: [
          Bounce(
            onTap: () async{
              await Get.dialog(
                OverlayPages(),
                barrierDismissible: false,
              );
               // Get.to(NotifictionPage());
            },
            child: GFAvatar(
              radius: 18,
              backgroundColor:
              AppColors.themeColor.primaryColor,
              child: const Icon(
                Icons.notifications_none_outlined,
                color: Colors.white,
              ),
            ).paddingAll(10),
          ),
        ],
      ),

      // 👉 PAGE BODY
      body: const Center(
        child: Text("Dashboard Page"),
      ),
    );
  }
}
