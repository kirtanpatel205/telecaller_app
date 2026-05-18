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
        extendBodyBehindAppBar: true,
        appBar: const CustomAppBar(
          leading: SizedBox(),
          titleText: "SIM Selection",
        ),
        backgroundColor: AppColors.themeColor.bgColor,
        body: Stack(
          children: [
            // Premium Background Decorations
            Positioned(
              top: -150.h,
              right: -50.w,
              child: Container(
                width: 400.r,
                height: 400.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.themeColor.primaryColor.withOpacity(0.12),
                      Colors.transparent,
                    ],
                    stops: const [0.2, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100.h,
              left: -100.w,
              child: Container(
                width: 300.r,
                height: 300.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.themeColor.primaryColor.withOpacity(0.08),
                      Colors.transparent,
                    ],
                    stops: const [0.2, 1.0],
                  ),
                ),
              ),
            ),
            
            Column(
              children: [
                // Custom Premium Header
                _buildHeader(context),

                // SIM Cards List
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return _buildLoadingState();
                    }
                    
                    if (controller.simCards.isEmpty) {
                      return _buildEmptyState();
                    }
                    
                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, MediaQuery.of(context).padding.bottom + 120.h),
                      physics: const BouncingScrollPhysics(),
                      itemCount: controller.simCards.length,
                      itemBuilder: (context, index) {
                        final sim = controller.simCards[index];
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 400 + (index * 100)),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 30 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: Obx(() => _buildSimTile(index, sim)),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }),
                ),
              ],
            ),

            // Premium Floating Action Button
            _buildBottomButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.themeColor.primaryColor.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40.r),
          bottomRight: Radius.circular(40.r),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              24.w, 
              MediaQuery.of(context).padding.top + kToolbarHeight + 16.h, 
              24.w, 
              32.h
            ),
            decoration: BoxDecoration(
              color: AppColors.themeColor.cardColor.withOpacity(0.85),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: AppColors.themeColor.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppColors.themeColor.primaryColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_rounded, size: 16.r, color: AppColors.themeColor.primaryColor),
                          SizedBox(width: 6.w),
                          Text(
                            "Secure Setup",
                            style: AppTextStyle.bold7.copyWith(fontSize: 10.sp, color: AppColors.themeColor.primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),
                Text(
                  "Choose Your\nNetwork",
                  style: AppTextStyle.bold7.copyWith(
                    fontSize: 26.sp, 
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "Select the primary SIM card you want to use for your telecalling activities.",
                  style: AppTextStyle.regular7.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.themeColor.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80.r,
                    height: 80.r,
                    child: CircularProgressIndicator(
                      value: value,
                      color: AppColors.themeColor.primaryColor.withOpacity(0.2),
                      strokeWidth: 4,
                    ),
                  ),
                  SizedBox(
                    width: 60.r,
                    height: 60.r,
                    child: CircularProgressIndicator(
                      color: AppColors.themeColor.primaryColor,
                      strokeWidth: 3,
                    ),
                  ),
                  Icon(Icons.sim_card_outlined, color: AppColors.themeColor.primaryColor, size: 24.r),
                ],
              );
            },
          ),
          SizedBox(height: 24.h),
          Text(
            "Scanning for networks...",
            style: AppTextStyle.bold7.copyWith(
              color: AppColors.themeColor.primaryColor,
              fontSize: 14.sp,
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
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutQuart,
          padding: EdgeInsets.all(1.5.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28.r),
            gradient: isSelected 
              ? LinearGradient(
                  colors: [
                    AppColors.themeColor.primaryColor,
                    AppColors.themeColor.primaryColor.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    AppColors.themeColor.bordercolror.withOpacity(0.8),
                    AppColors.themeColor.bordercolror.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.themeColor.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ]
                : [],
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: AppColors.themeColor.cardColor,
              borderRadius: BorderRadius.circular(26.r),
            ),
            child: Row(
              children: [
                // Premium SIM Icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 60.r,
                  height: 60.r,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSelected 
                        ? [
                            AppColors.themeColor.primaryColor, 
                            AppColors.themeColor.primaryColor.withOpacity(0.8)
                          ]
                        : [
                            AppColors.themeColor.primaryColor.withOpacity(0.05),
                            AppColors.themeColor.primaryColor.withOpacity(0.1),
                          ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : AppColors.themeColor.primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.sim_card_rounded,
                      color: isSelected ? Colors.white : AppColors.themeColor.primaryColor,
                      size: 28.r,
                    ),
                  ),
                ),
                SizedBox(width: 18.w),
                
                // SIM Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              carrier,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: AppTextStyle.bold7.copyWith(fontSize: 16.sp),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? AppColors.themeColor.primaryColor.withOpacity(0.1) 
                                  : AppColors.themeColor.bgColor,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: isSelected 
                                    ? AppColors.themeColor.primaryColor.withOpacity(0.3)
                                    : AppColors.themeColor.bordercolror,
                              ),
                            ),
                            child: Text(
                              "SIM ${index + 1}",
                              style: AppTextStyle.bold7.copyWith(
                                fontSize: 10.sp, 
                                color: isSelected ? AppColors.themeColor.primaryColor : AppColors.themeColor.textSecondaryColor
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          if (hasNumber) ...[
                            Icon(Icons.phone_rounded, size: 14.r, color: AppColors.themeColor.textSecondaryColor),
                            SizedBox(width: 4.w),
                          ],
                          Expanded(
                            child: Text(
                              hasNumber ? number : "Active Connection",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: AppTextStyle.regular7.copyWith(
                                fontSize: 12.sp,
                                color: hasNumber 
                                  ? AppColors.themeColor.textSecondaryColor
                                  : Colors.amber.shade700,
                                fontWeight: hasNumber ? FontWeight.w500 : FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(width: 12.w),
                // Premium Animated Checkbox/Radio
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 28.r,
                  height: 28.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.themeColor.primaryColor : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.themeColor.primaryColor : AppColors.themeColor.bordercolror,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.themeColor.primaryColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : [],
                  ),
                  child: isSelected
                      ? Icon(Icons.check_rounded, color: Colors.white, size: 18.r)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.fromLTRB(24.w, 30.h, 24.w, MediaQuery.of(context).padding.bottom + 20.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.themeColor.bgColor.withOpacity(0),
              AppColors.themeColor.bgColor,
              AppColors.themeColor.bgColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0, 0.6, 1.0],
          ),
        ),
        child: Obx(() {
          final bool isEnabled = controller.selectedSimIndex.value != -1;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            transform: Matrix4.translationValues(0, isEnabled ? 0 : 10, 0),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isEnabled ? 1.0 : 0.6,
              child: CustomButton(
                onClick: controller.proceed,
                title: "Continue to Setup",
                isLoading: controller.isSendingOtp.value,
                enabled: isEnabled,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(28.r),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red.shade100, width: 2),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.sim_card_rounded, size: 60.r, color: Colors.red.shade300),
                    Positioned(
                      bottom: -5,
                      right: -5,
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.warning_rounded, size: 24.r, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              Text(
                "No Network Found",
                style: AppTextStyle.bold7.copyWith(fontSize: 18.sp),
              ),
              SizedBox(height: 12.h),
              Text(
                "We couldn't detect any active SIM cards. Please make sure your SIM is inserted properly and permissions are granted.",
                textAlign: TextAlign.center,
                style: AppTextStyle.regular7.copyWith(
                  color: AppColors.themeColor.textSecondaryColor,
                  fontSize: 13.sp,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 32.h),
              ElevatedButton.icon(
                onPressed: () => controller.loadSimInfo(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text("Scan Networks Again"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.themeColor.primaryColor,
                  backgroundColor: AppColors.themeColor.primaryColor.withOpacity(0.1),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
