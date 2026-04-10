import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:telecaller_app/constants/app_colors.dart';
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
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),
            
            Center(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildOverlayCard(context),
                      const SizedBox(height: 20),
                      if (controller.isAutoCallMode.value) _buildNextLeadPreview(),
                      const SizedBox(height: 10),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black.withOpacity(0.08), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 35,
            offset: const Offset(0, 15),
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
                  Text(
                    "call_summary".tr,
                    style: TextStyle(
                      color: AppColors.themeColor.primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                        controller.lastCalledName.value.isNotEmpty
                            ? controller.lastCalledName.value
                            : "unknown_contact".tr,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          letterSpacing: -0.5,
                        ),
                      )),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.themeColor.primaryColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.themeColor.primaryColor.withOpacity(0.1)),
                ),
                child: Icon(Icons.phone_paused_rounded, color: AppColors.themeColor.primaryColor, size: 24),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── stats row ───────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                _buildStatItem(
                  Icons.av_timer_rounded,
                  "duration".tr,
                  Obx(() => Text(
                        controller.formattedCallLogDuration.value,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.black,
                          fontFamily: 'Poppins',
                        ),
                      )),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 1, 
                  height: 30, 
                  color: Colors.black.withOpacity(0.1)
                ),
                _buildStatItem(
                  Icons.phone_android_rounded,
                  "number".tr,
                  Obx(() => Text(
                        controller.lastCalledNumber.value,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.black,
                          fontFamily: 'Poppins',
                        ),
                      )),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── What happened ───────────────────────────────
          Text(
            "call_disposition".tr,
            style: TextStyle(
              color: Colors.black.withOpacity(0.6),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          CustomDropdown(
            selectedValue: controller.callDropdownValue,
            items: controller.leadOptions,
            onChanged: (value) => controller.onDropdownChange(value),
          ),

          // ── Reschedule ──────────────────────────────────
          Obx(() => controller.callDropdownValue.value == "reschedule" ? _buildReschedulePicker(context) : const SizedBox.shrink()),

          const SizedBox(height: 24),

          // ── ACTION BUTTONS ──────────────────────────────
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
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => _buildGradientButton(
                      onTap: () => controller.isPaused.value ? controller.resumeCountdown() : controller.pauseCountdown(),
                      label: controller.isPaused.value ? "resume".tr : "pause".tr,
                      icon: controller.isPaused.value ? Icons.play_arrow_rounded : Icons.pause_rounded,
                      colors: controller.isPaused.value ? [const Color(0xFF10B981), const Color(0xFF059669)] : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                    )),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── NEXT CALL BUTTON ────────────────────────────
          Obx(() {
            if (!controller.isAutoCallMode.value) return const SizedBox.shrink();
            return _buildGradientButton(
              onTap: () => controller.onNextCallTapped(),
              label: controller.callDropdownValue.value.isEmpty ? "${"next_in".tr} ${controller.countdown.value}s" : "call_next".tr,
              icon: Icons.skip_next_rounded,
              colors: [AppColors.themeColor.primaryColor, AppColors.themeColor.primaryColor.withBlue(210)],
              isFullWidth: true,
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
              Icon(icon, size: 14, color: AppColors.themeColor.primaryColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9, 
                  color: Colors.black.withOpacity(0.5), 
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          valueWidget,
        ],
      ),
    );
  }

  Widget _buildReschedulePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          "pick_date".tr,
          style: TextStyle(
            color: Colors.black.withOpacity(0.6),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => controller.pickDate(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                      controller.rescheduleDate.value.isEmpty
                          ? DateFormat('dd MMM, yyyy').format(DateTime.now().add(const Duration(days: 1)))
                          : DateFormat('dd MMM, yyyy').format(DateFormat('yyyy-MM-dd').parse(controller.rescheduleDate.value)),
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                    )),
                Icon(Icons.calendar_month_rounded, color: AppColors.themeColor.primaryColor, size: 20),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.themeColor.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "up_next".tr,
              style: TextStyle(color: AppColors.themeColor.primaryColor, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              next["name"] ?? "Unknown",
              style: TextStyle(color: Colors.black.withOpacity(0.8), fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'Poppins'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Colors.black.withOpacity(0.3), size: 18),
        ],
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
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: isFullWidth ? double.infinity : null,
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors, 
            begin: Alignment.topLeft, 
            end: Alignment.bottomRight
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.w700, 
                fontSize: 14, 
                letterSpacing: 1,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return IconButton(
      onPressed: () {
        controller.stopCountdown();
        Get.back();
      },
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.close_rounded, color: Colors.black.withOpacity(0.4)),
      ),
    );
  }
}