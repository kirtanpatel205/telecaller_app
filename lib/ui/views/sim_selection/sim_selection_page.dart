import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/ui/views/sim_selection/sim_selection_controller.dart';
import 'package:telecaller_app/ui/widgets/app_safe_area.dart';
import 'package:telecaller_app/ui/widgets/custom_button.dart';
import 'package:telecaller_app/ui/widgets/custom-appbar.dart';

class SimSelectionPage extends GetView<SimSelectionController> {
  const SimSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: AppColors.themeColor.bgColor,
        body: Stack(
          children: [
            // Background Decorative Element
            Positioned(
              top: -100.h,
              right: -100.w,
              child: Container(
                width: 300.r,
                height: 300.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.themeColor.primaryColor.withOpacity(0.05),
                ),
              ),
            ),
            
            Column(
              children: [
                // Custom Modern AppBar/Header
                _buildHeader(context),

                // SIM Cards List
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: AppColors.themeColor.primaryColor,
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              "Detecting Active SIMs...",
                              style: AppTextStyle.regular7.copyWith(
                                color: AppColors.themeColor.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    if (controller.simCards.isEmpty) {
                      return _buildEmptyState();
                    }
                    
                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 100.h),
                      physics: const BouncingScrollPhysics(),
                      itemCount: controller.simCards.length,
                      itemBuilder: (context, index) {
                        final sim = controller.simCards[index];
                        return Obx(() => _buildSimTile(index, sim));
                      },
                    );
                  }),
                ),
              ],
            ),

            // Bottom Floating Action Button
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 60.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.themeColor.cardColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32.r),
          bottomRight: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.themeColor.bgColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.arrow_back_ios_new, size: 20.r, color: AppColors.themeColor.textPrimaryColor),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.themeColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security, size: 14.r, color: AppColors.themeColor.primaryColor),
                    SizedBox(width: 4.w),
                    Text(
                      "Secure Login",
                      style: AppTextStyle.bold7.copyWith(fontSize: 10.sp, color: AppColors.themeColor.primaryColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            "Identify Your SIM",
            style: AppTextStyle.bold7.copyWith(fontSize: 28.sp, height: 1.2),
          ),
          SizedBox(height: 8.h),
          Text(
            "We detected multiple active SIM cards. Select the one associated with your account.",
            style: AppTextStyle.regular7.copyWith(
              fontSize: 14.sp,
              color: AppColors.themeColor.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimTile(int index, Map<String, dynamic> sim) {
    bool isSelected = controller.selectedSimIndex.value == index;
    String carrier = sim['carrierName'] ?? "Unknown Carrier";
    String number = sim['number']?.toString() ?? "";
    bool hasNumber = number.isNotEmpty && number != "null";
    
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: GestureDetector(
        onTap: () => controller.selectSim(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          padding: EdgeInsets.all(2.r), // Border thickness
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            gradient: isSelected 
              ? LinearGradient(
                  colors: [
                    AppColors.themeColor.primaryColor,
                    AppColors.themeColor.primaryColor.withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
            color: isSelected ? null : AppColors.themeColor.bordercolror.withOpacity(0.3),
          ),
          child: Container(
            padding: EdgeInsets.all(18.r),
            decoration: BoxDecoration(
              color: AppColors.themeColor.cardColor,
              borderRadius: BorderRadius.circular(22.r),
            ),
            child: Row(
              children: [
                // Premium SIM Icon
                Container(
                  width: 56.r,
                  height: 56.r,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSelected 
                        ? [AppColors.themeColor.primaryColor, AppColors.themeColor.primaryColor.withOpacity(0.7)]
                        : [Colors.grey.shade100, Colors.grey.shade200],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18.r),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: AppColors.themeColor.primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.sim_card_rounded,
                      color: isSelected ? Colors.white : AppColors.themeColor.textSecondaryColor,
                      size: 28.r,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                
                // SIM Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            carrier,
                            style: AppTextStyle.bold7.copyWith(fontSize: 18.sp),
                          ),
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.themeColor.primaryColor.withOpacity(0.1) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              "Slot ${index + 1}",
                              style: AppTextStyle.bold7.copyWith(
                                fontSize: 10.sp, 
                                color: isSelected ? AppColors.themeColor.primaryColor : AppColors.themeColor.textSecondaryColor
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        hasNumber ? number : "Active SIM Detected",
                        style: AppTextStyle.regular7.copyWith(
                          fontSize: 14.sp,
                          color: hasNumber 
                            ? AppColors.themeColor.textPrimaryColor.withOpacity(0.7)
                            : Colors.orange.shade700,
                          fontWeight: hasNumber ? FontWeight.w500 : FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(width: 12.w),
                // Animated Radio Indicator
                Container(
                  width: 24.r,
                  height: 24.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.themeColor.primaryColor : AppColors.themeColor.bordercolror,
                      width: 2,
                    ),
                  ),
                  child: AnimatedScale(
                    scale: isSelected ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      margin: EdgeInsets.all(3.r),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.themeColor.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 30.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.themeColor.bgColor.withOpacity(0),
              AppColors.themeColor.bgColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0, 0.4],
          ),
        ),
        child: Obx(() {
          final bool isEnabled = controller.selectedSimIndex.value != -1;
          return CustomButton(
            onClick: controller.proceed,
            title: "Continue to Login",
            isLoading: controller.isSendingOtp.value,
            enabled: isEnabled,
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.sim_card_alert_rounded, size: 64.r, color: Colors.red.shade400),
            ),
            SizedBox(height: 24.h),
            Text(
              "No SIM Detected",
              style: AppTextStyle.bold7.copyWith(fontSize: 20.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              "Please insert a valid SIM card or ensure you have granted phone permissions.",
              textAlign: TextAlign.center,
              style: AppTextStyle.regular7.copyWith(color: AppColors.themeColor.textSecondaryColor),
            ),
            SizedBox(height: 24.h),
            TextButton.icon(
              onPressed: () => controller.loadSimInfo(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Scan Again"),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.themeColor.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                backgroundColor: AppColors.themeColor.primaryColor.withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
