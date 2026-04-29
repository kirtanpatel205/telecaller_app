import 'dart:developer';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_dimens.dart';
import 'package:telecaller_app/constants/app_routes.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/core/helpers/storage.dart';
import '../home/home_controller.dart';

class SettingPage extends GetView<HomeController> {
  const SettingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.themeColor.bgColor,
      body: Obx(() {
        controller.isDarkMode.value;
        return RefreshIndicator(
          onRefresh: () async {
            await controller.authController.refreshProfile();
            log("profile refreshed");
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ─── Profile Header ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: _ProfileHeader(controller: controller),
              ),

              // ─── Menu Items ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24.h),

                      // ── Account Section ─────────────────────────────────
                      _SectionLabel(label: "account".tr),
                      SizedBox(height: 10.h),
                      _MenuCard(
                        children: [
                          _MenuItem(
                            icon: Icons.person_outline_rounded,
                            label: "editProfile".tr,
                            onTap: () => Get.toNamed(Routes.EDITPROFILE),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      // ── Appearance Section ───────────────────────────────
                      _SectionLabel(label: "appearance".tr),
                      SizedBox(height: 10.h),
                      _MenuCard(
                        children: [
                          // Dark Mode Toggle
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 4.h),
                            child: Row(
                              children: [
                                Container(
                                  width: 40.w,
                                  height: 40.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.themeColor.primaryColor
                                        .withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Icon(
                                    Icons.nightlight_round,
                                    color: AppColors.themeColor.primaryColor,
                                    size: 20.sp,
                                  ),
                                ),
                                SizedBox(width: 14.w),
                                Expanded(
                                  child: Text(
                                    "dark_mode".tr,
                                    style: AppTextStyle.medium7.copyWith(
                                      fontSize: AppDimens.fontSize14,
                                      color:
                                          AppColors.themeColor.textPrimaryColor,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 36.h,
                                  width: 46.w,
                                  child: ThemeSwitcher(
                                    builder: (ctx) => DayNightSwitcher(
                                      isDarkModeEnabled:
                                          controller.isDarkMode.value,
                                      onStateChanged: (value) {
                                        controller.toggleTheme(value, context);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _Divider(),
                          _MenuItem(
                            icon: Icons.language_outlined,
                            label: "language".tr,
                            onTap: () => Get.toNamed(Routes.LANGUAGE),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      // ── Legal Section ────────────────────────────────────
                      _SectionLabel(label: "legal".tr),
                      SizedBox(height: 10.h),
                      _MenuCard(
                        children: [
                          _MenuItem(
                            icon: Icons.privacy_tip_outlined,
                            label: "privacy_policy".tr,
                            onTap: () => Get.toNamed(Routes.PRIVACY_POLICY),
                          ),
                          _Divider(),
                          _MenuItem(
                            icon: Icons.description_outlined,
                            label: "terms_conditions".tr,
                            onTap: () =>
                                Get.toNamed(Routes.TERMS_CONDITIONS),
                          ),
                        ],
                      ),

                      SizedBox(height: 28.h),

                      // ── Logout ───────────────────────────────────────────
                      _LogoutButton(),

                      SizedBox(height: 32.h),

                      // App version tag
                      Center(
                        child: Text(
                          "v1.0.0",
                          style: AppTextStyle.regular7.copyWith(
                            fontSize: AppDimens.fontSize11,
                            color: AppColors.themeColor.textSecondaryColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─── Profile Header Widget ─────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final HomeController controller;
  const _ProfileHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final profile = controller.authController.profile.value;
      final name = profile?.name ?? "User";
      final phone = profile?.phone ?? "";
      final role = profile?.role ?? "";
      final initial =
          name.isNotEmpty ? name[0].toUpperCase() : "U";
      final hasPhoto = profile?.profile?.isNotEmpty == true;
      final photoUrl =
          "https://api-test.digibulkmarketing.com${profile?.profile ?? ''}";

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.themeColor.primaryColor,
              AppColors.themeColor.primaryColor.withOpacity(0.75),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32.r),
            bottomRight: Radius.circular(32.r),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 28.h),
            child: Column(
              children: [
                // Title
                Text(
                  "settings".tr,
                  style: AppTextStyle.bold7.copyWith(
                    fontSize: AppDimens.fontSize15,
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 20.h),
                // Avatar
                GestureDetector(
                  onTap: () => Get.toNamed(Routes.EDITPROFILE),
                  child: Stack(
                    children: [
                      Container(
                        width: 88.w,
                        height: 88.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white, width: 3.w),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: hasPhoto
                            ? Image.network(
                                photoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _InitialCircle(initial: initial),
                              )
                            : _InitialCircle(initial: initial),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(5.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                              )
                            ],
                          ),
                          child: Icon(
                            Icons.edit_rounded,
                            size: 13.sp,
                            color:
                                AppColors.themeColor.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
                // Name
                Text(
                  name,
                  style: AppTextStyle.bold9.copyWith(
                    fontSize: AppDimens.fontSize18,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                // Phone
                if (phone.isNotEmpty)
                  Text(
                    phone,
                    style: AppTextStyle.bold7.copyWith(
                      fontSize: AppDimens.fontSize12,
                      color: Colors.white70,
                    ),
                  ),
                // Role badge
                if (role.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      role.capitalizeFirst ?? role,
                      style: AppTextStyle.bold7.copyWith(
                        fontSize: AppDimens.fontSize11,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _InitialCircle extends StatelessWidget {
  final String initial;
  const _InitialCircle({required this.initial});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white24,
      child: Center(
        child: Text(
          initial,
          style: AppTextStyle.bold15.copyWith(
            color: Colors.white,
            fontSize: AppDimens.fontSize30,
          ),
        ),
      ),
    );
  }
}

// ─── Section Label ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTextStyle.bold7.copyWith(
        fontSize: AppDimens.fontSize11,
        color: AppColors.themeColor.textSecondaryColor,
        letterSpacing: 1.1,
      ),
    );
  }
}

// ─── Menu Card ─────────────────────────────────────────────────────────────

class _MenuCard extends StatelessWidget {
  final List<Widget> children;
  const _MenuCard({required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.themeColor.cardBgColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

// ─── Menu Item ─────────────────────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem(
      {required this.icon,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.themeColor.primaryColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                label,
                style: AppTextStyle.medium7.copyWith(
                  fontSize: AppDimens.fontSize14,
                  color: AppColors.themeColor.textPrimaryColor,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.sp,
              color: AppColors.themeColor.textSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Divider ────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: AppColors.themeColor.textSecondaryColor.withOpacity(0.18),
      ),
    );
  }
}

// ─── Logout Button ─────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.defaultDialog(
          title: "logout".tr,
          middleText: "logout_confirm".tr,
          textConfirm: "yes".tr,
          textCancel: "cancel".tr,
          confirmTextColor: Colors.white,
          buttonColor: Colors.red,
          onConfirm: () {
            Storage.clearStorage();
            Get.offAllNamed(Routes.WELCOME);
          },
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.red.withOpacity(0.25), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.red, size: 20.sp),
            SizedBox(width: 10.w),
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
    );
  }
}
