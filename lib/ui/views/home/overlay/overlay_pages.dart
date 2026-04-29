import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_dimens.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/core/controllers/overlay_controller.dart';
import 'package:telecaller_app/ui/widgets/custom_dropdown_call.dart';

class OverlayPages extends StatelessWidget {
  final OverlayController controller = Get.find<OverlayController>();

  OverlayPages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Glassmorphic background
            GestureDetector(
              onTap: () {
                // Prevent closing on tap outside if auto mode
                if (!controller.isAutoCallMode.value) {
                  controller.stopCountdown();
                  Get.back();
                }
              },
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.6), // Clean, premium dark glass tint
                ),
              ),
            ),
            
            Center(
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
                  width: double.infinity,
                  constraints: BoxConstraints(maxWidth: 400.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildOverlayCard(context),
                      SizedBox(height: 20.h),
                      Obx(() => controller.isAutoCallMode.value ? _buildNextLeadPreview() : const SizedBox.shrink()),
                      SizedBox(height: 10.h),
                      _buildCloseButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.themeColor.cardBgColor,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: Colors.black.withOpacity(0.08), width: 1.5.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 35.r,
            offset: Offset(0, 15.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "call_summary".tr,
                        style: AppTextStyle.bold7.copyWith(
                          color: AppColors.themeColor.primaryColor,
                          fontSize: AppDimens.fontSize10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.themeColor.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Obx(() => Text(
                          "${controller.currentQueueIndex.value + 1} / ${controller.callQueue.length}",
                          style: TextStyle(
                            fontSize: AppDimens.fontSize9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.themeColor.primaryColor,
                          ),
                        )),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Obx(() => Text(
                        controller.lastCalledName.value.isNotEmpty
                            ? controller.lastCalledName.value
                            : "unknown_contact".tr,
                        style: AppTextStyle.bold8.copyWith(
                          color: AppColors.themeColor.textPrimaryColor,
                          fontSize: AppDimens.fontSize22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      )),
                ],
              ),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.themeColor.primaryColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.themeColor.primaryColor.withOpacity(0.1)),
                ),
                child: Icon(Icons.phone_paused_rounded, color: AppColors.themeColor.primaryColor, size: 24.sp),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // ── stats row ───────────────────────────────────
          Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: AppColors.themeColor.scaffoldBackgroundColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                _buildStatItem(
                  Icons.av_timer_rounded,
                  "duration".tr,
                  Obx(() => Text(
                        controller.formattedCallLogDuration.value,
                        style: AppTextStyle.bold7.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: AppDimens.fontSize14,
                          color: AppColors.themeColor.textPrimaryColor,
                        ),
                      )),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 12.w),
                  width: 1.w, 
                  height: 30.h, 
                  color: Colors.black.withOpacity(0.1)
                ),
                _buildStatItem(
                  Icons.phone_android_rounded,
                  "number".tr,
                  Obx(() => Text(
                        controller.lastCalledNumber.value,
                        style: AppTextStyle.bold7.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: AppDimens.fontSize14,
                          color: AppColors.themeColor.textPrimaryColor,
                        ),
                      )),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // ── What happened ───────────────────────────────
          Text(
            "call_disposition".tr,
            style: AppTextStyle.bold7.copyWith(
              color: AppColors.themeColor.textPrimaryColor.withOpacity(0.6),
              fontSize: AppDimens.fontSize10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 12.h),
          CustomDropdown(
            selectedValue: controller.callDropdownValue,
            items: controller.leadOptions,
            onChanged: (value) => controller.onDropdownChange(value),
          ),

          // ── Reschedule ──────────────────────────────────
          Obx(() => controller.callDropdownValue.value == "reschedule" ? _buildReschedulePicker(context) : const SizedBox.shrink()),

          SizedBox(height: 24.h),

          // ── ACTION BUTTONS ──────────────────────────────
          Obx(() {
            if (!controller.isAutoCallMode.value) return const SizedBox.shrink();
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildGradientButton(
                        onTap: () => controller.redialLastCall(),
                        label: "redial".tr,
                        icon: Icons.refresh_rounded,
                        colors: [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildGradientButton(
                        onTap: () => controller.isPaused.value ? controller.resumeCountdown() : controller.pauseCountdown(),
                        label: controller.isPaused.value ? "resume".tr : "pause".tr,
                        icon: controller.isPaused.value ? Icons.play_arrow_rounded : Icons.pause_rounded,
                        colors: controller.isPaused.value ? [const Color(0xFF10B981), const Color(0xFF059669)] : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
              ],
            );
          }),

          SizedBox(height: 12.h),

          // ── NEXT CALL BUTTON ────────────────────────────
          Obx(() {
            final isLastCall = controller.nextLead == null;
            
            String buttonLabel = "call_next".tr;
            if (isLastCall) {
              buttonLabel = "submit".tr;
            } else if (controller.isAutoCallMode.value && controller.countdown.value > 0) {
              buttonLabel = "${"next_in".tr} ${controller.countdown.value}s";
            }

            return Column(
              children: [
                _buildGradientButton(
                  onTap: () => controller.onNextCallTapped(),
                  label: buttonLabel,
                  icon: isLastCall ? Icons.check_circle_rounded : Icons.skip_next_rounded,
                  colors: [AppColors.themeColor.primaryColor, AppColors.themeColor.primaryColor.withBlue(210)],
                  isFullWidth: true,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, Widget valueWidget) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.sp, color: AppColors.themeColor.primaryColor),
              SizedBox(width: 6.w),
              Text(
                label,
                style: AppTextStyle.bold7.copyWith(
                  fontSize: AppDimens.fontSize9, 
                  color: AppColors.themeColor.textPrimaryColor.withOpacity(0.5), 
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          valueWidget,
        ],
      ),
    );
  }

  Widget _buildReschedulePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        Text(
          "pick_date".tr,
          style: AppTextStyle.bold7.copyWith(
            color: AppColors.themeColor.textPrimaryColor.withOpacity(0.6),
            fontSize: AppDimens.fontSize10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: () => controller.pickDate(context),
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.themeColor.scaffoldBackgroundColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.black.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                      controller.rescheduleDate.value.isEmpty
                          ? DateFormat('dd MMM, yyyy').format(DateTime.now().add(const Duration(days: 1)))
                          : DateFormat('dd MMM, yyyy').format(DateFormat('yyyy-MM-dd').parse(controller.rescheduleDate.value)),
                      style: AppTextStyle.bold7.copyWith(color: AppColors.themeColor.textPrimaryColor, fontWeight: FontWeight.w600, fontSize: AppDimens.fontSize14),
                    )),
                Icon(Icons.calendar_month_rounded, color: AppColors.themeColor.primaryColor, size: 20.sp),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextLeadPreview() {
    final next = controller.nextLead;
    if (next == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              "up_next".tr.toUpperCase(),
              style: AppTextStyle.bold7.copyWith(color: Colors.white, fontWeight: FontWeight.w900, fontSize: AppDimens.fontSize9, letterSpacing: 1),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              next["name"] ?? "Unknown",
              style: AppTextStyle.bold7.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: AppDimens.fontSize13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.fast_forward_rounded, color: Colors.white.withOpacity(0.5), size: 16.sp),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return InkWell(
      onTap: () {
        controller.stopCountdown();
        Get.back();
      },
      borderRadius: BorderRadius.circular(30.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
        ),
        child: Icon(Icons.close_rounded, color: Colors.white, size: 24.sp),
      ),
    );
  }

  Widget _buildGradientButton({
    required VoidCallback onTap,
    required String label,
    required IconData icon,
    required List<Color> colors,
    bool isFullWidth = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        width: isFullWidth ? double.infinity : null,
        height: 52.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors, 
            begin: Alignment.topLeft, 
            end: Alignment.bottomRight
          ),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.35),
              blurRadius: 12.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: AppTextStyle.bold7.copyWith(
                color: Colors.white, 
                fontWeight: FontWeight.w700, 
                fontSize: AppDimens.fontSize14, 
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }


}