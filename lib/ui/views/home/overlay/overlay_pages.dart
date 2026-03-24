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
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: Colors.black.withOpacity(0.4),
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
        color: AppColors.themeColor.cardBgColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
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
                    "CALL SUMMARY",
                    style: TextStyle(
                      color: AppColors.themeColor.primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                        controller.lastCalledName.value.isNotEmpty
                            ? controller.lastCalledName.value
                            : "Unknown Contact",
                        style: TextStyle(
                          color: AppColors.themeColor.textPrimaryColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      )),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.themeColor.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.phone_callback_rounded, color: AppColors.themeColor.primaryColor, size: 24),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── stats row ───────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.themeColor.scaffoldBackgroundColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.themeColor.bordercolror.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                _buildStatItem(
                  Icons.timer_outlined,
                  "Duration",
                  Obx(() => Text(
                        controller.formattedCallLogDuration.value,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.themeColor.textPrimaryColor,
                        ),
                      )),
                ),
                Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.2)),
                _buildStatItem(
                  Icons.phone_android_rounded,
                  "Number",
                  Obx(() => Text(
                        controller.lastCalledNumber.value,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.themeColor.textPrimaryColor,
                        ),
                      )),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── What happened ───────────────────────────────
          Text(
            "CALL DISPOSITION",
            style: TextStyle(
              color: AppColors.themeColor.textSecondaryColor,
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
                  label: "REDIAL",
                  icon: Icons.refresh_rounded,
                  colors: [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => _buildGradientButton(
                      onTap: () => controller.isPaused.value ? controller.resumeCountdown() : controller.pauseCountdown(),
                      label: controller.isPaused.value ? "RESUME" : "PAUSE",
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
              label: controller.callDropdownValue.value.isEmpty ? "NEXT IN ${controller.countdown.value}s" : "CALL NEXT",
              icon: Icons.skip_next_rounded,
              colors: [const Color(0xFF10B981), const Color(0xFF047857)],
              isFullWidth: true,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, Widget valueWidget) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.themeColor.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: AppColors.themeColor.textSecondaryColor, fontWeight: FontWeight.bold),
                ),
                valueWidget,
              ],
            ),
          ),
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
          "PICK DATE",
          style: TextStyle(
            color: AppColors.themeColor.textSecondaryColor,
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
              color: AppColors.themeColor.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.themeColor.bordercolror.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                      controller.rescheduleDate.value.isEmpty
                          ? DateFormat('dd MMM, yyyy').format(DateTime.now().add(const Duration(days: 1)))
                          : DateFormat('dd MMM, yyyy').format(DateFormat('yyyy-MM-dd').parse(controller.rescheduleDate.value)),
                      style: TextStyle(color: AppColors.themeColor.textPrimaryColor, fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Text(
            "UP NEXT: ",
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
          ),
          Expanded(
            child: Text(
              next["name"] ?? "Unknown",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 12),
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: isFullWidth ? double.infinity : null,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
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
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close_rounded, color: Colors.white70),
      ),
    );
  }
}