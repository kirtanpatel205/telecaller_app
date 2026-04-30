import 'package:bounce/bounce.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_constants.dart';
import 'package:telecaller_app/constants/app_routes.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/ui/views/home/home_controller.dart';

class DashboardAppBar extends StatelessWidget {
  final HomeController controller;

  const DashboardAppBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      leadingWidth: 72.w,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      backgroundColor: AppColors.themeColor.scaffoldBackgroundColor,
      leading: Center(
        child: Padding(
          padding: EdgeInsets.only(left: 12.w),
          child: Bounce(
            onTap: () => Get.toNamed(Routes.EDITPROFILE),
            child: Obx(
              () => Container(
                padding: EdgeInsets.all(1.5.w), // Thinner outer ring
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.themeColor.primaryColor,
                      AppColors.themeColor.primaryColor.withOpacity(0.4),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.themeColor.primaryColor.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Container(
                  padding: EdgeInsets.all(1.5.w), // Thinner inner ring
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    height: 42.h,
                    width: 42.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: controller.authController.profile.value?.profile?.isNotEmpty == true
                        ? CachedNetworkImage(
                            imageUrl: "${AppConstants.BASE_URL}${controller.authController.profile.value!.profile!}",
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.themeColor.primaryColor.withOpacity(0.1),
                              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          )
                        : Container(
                            color: AppColors.themeColor.primaryColor.withOpacity(0.1),
                            child: Center(
                              child: Text(
                                controller.authController.profile.value?.name?.isNotEmpty == true
                                    ? controller.authController.profile.value!.name![0].toUpperCase()
                                    : "N",
                                style: AppTextStyle.bold8.copyWith(
                                  fontSize: 20.sp,
                                  color: AppColors.themeColor.primaryColor,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      title: Obx(
        () => InkWell(
          onTap: () => Get.toNamed(Routes.EDITPROFILE),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.authController.profile.value?.name?.isNotEmpty == true
                    ? controller.authController.profile.value!.name!
                    : "no_name".tr,
                style: AppTextStyle.bold8.copyWith(
                  color: AppColors.themeColor.textPrimaryColor,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'how_are_you_today'.tr,
                style: AppTextStyle.regular6.copyWith(
                  color: AppColors.themeColor.textSecondaryColor,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: Bounce(
            onTap: () => Get.toNamed(Routes.NOTIFICATION),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.themeColor.primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.notifications_none_outlined,
                    color: AppColors.themeColor.primaryColor,
                    size: 26.sp,
                  ),
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 10,
                        minHeight: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
