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
        appBar: CustomAppBar(
          leading: SizedBox(),
          titleText: "Dual SIM Login",
          showBackButton: true,
        ),
        body: Column(
          children: [
            SizedBox(height: 10.h),
            
            // Subtitle
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Text(
                "Select the SIM card you want to use for login and business calls.",
                textAlign: TextAlign.center,
                style: AppTextStyle.regular7.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.themeColor.textSecondaryColor,
                ),
              ),
            ),

            SizedBox(height: 30.h),

            // SIM Cards List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator(color: AppColors.themeColor.primaryColor));
                }
                
                if (controller.simCards.isEmpty) {
                  return _buildEmptyState();
                }
                
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: controller.simCards.length,
                  itemBuilder: (context, index) {
                    final sim = controller.simCards[index];
                    // IMPORTANT: Each item needs its own Obx to listen to selectedSimIndex
                    return Obx(() => _buildSimTile(index, sim));
                  },
                );
              }),
            ),

            // Bottom Button
            Padding(
              padding: EdgeInsets.all(24.r),
              child: Obx(() => CustomButton(
                onClick: controller.proceed,
                title: "Login with Selected SIM",
                isLoading: controller.isSendingOtp.value,
                enabled: controller.selectedSimIndex.value != -1,
              )),
            ),
          ],
        ),

      ),
    );
  }

  Widget _buildSimTile(int index, Map<String, dynamic> sim) {
    bool isSelected = controller.selectedSimIndex.value == index;
    
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            print("SIM $index selected"); // Debug log
            controller.selectSim(index);
          },
          borderRadius: BorderRadius.circular(16.r),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColors.themeColor.primaryColor 
                  : AppColors.themeColor.cardColor,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected ? AppColors.themeColor.primaryColor : AppColors.themeColor.bordercolror,
                width: 1.5,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: AppColors.themeColor.primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
              ],
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.2) : AppColors.themeColor.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.sim_card_rounded,
                    color: isSelected ? Colors.white : AppColors.themeColor.primaryColor,
                    size: 24.r,
                  ),
                ),
                SizedBox(width: 16.w),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sim['carrierName'] ?? "Slot ${index + 1}",
                        style: AppTextStyle.bold7.copyWith(
                          fontSize: 16.sp,
                          color: isSelected ? Colors.white : AppColors.themeColor.textPrimaryColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        sim['number'] != null && sim['number'].toString().isNotEmpty 
                            ? sim['number'] 
                            : "Detected Active SIM",
                        style: AppTextStyle.regular7.copyWith(
                          fontSize: 13.sp,
                          color: isSelected ? Colors.white.withOpacity(0.8) : AppColors.themeColor.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Selection Circle
                Container(
                  width: 24.r,
                  height: 24.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.white : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? Colors.white : AppColors.themeColor.bordercolror,
                      width: 2,
                    ),
                  ),
                  child: isSelected 
                      ? Icon(Icons.check, color: AppColors.themeColor.primaryColor, size: 16.r)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sim_card_alert_rounded, size: 64.r, color: Colors.grey),
          SizedBox(height: 16.h),
          Text("No SIM cards detected", style: AppTextStyle.bold7),
          TextButton(onPressed: () => controller.loadSimInfo(), child: Text("Retry")),
        ],
      ),
    );
  }
}
