import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_dimens.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/ui/widgets/app_safe_area.dart';
import 'package:telecaller_app/ui/widgets/custom-appbar.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSafeArea(
      top: false,
      child: Scaffold(
      backgroundColor: AppColors.themeColor.bgColor,
      appBar: CustomAppBar(
        titleText: "privacy_policy".tr,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerCard(Icons.privacy_tip_rounded, "Privacy Policy", "Last updated: 01 January 2025"),
            SizedBox(height: 24.h),
            _section("Information We Collect",
                "We collect information you provide directly to us such as name, phone number, email address, and usage data when you create an account or update your profile."),
            _section("How We Use Information",
                "We use the information to provide, maintain, and improve our services, process transactions, send technical notices, and respond to your questions."),
            _section("Data Sharing",
                "We do not share your personal information with third parties except as described in this policy or with vendors who perform services on our behalf."),
            _section("Data Security",
                "We take reasonable measures to protect information from loss, theft, misuse and unauthorized access. All data is encrypted in transit using SSL technology."),
            _section("Data Retention",
                "We store information as long as necessary to provide our services. You may request deletion of your data at any time by contacting our support team."),
            _section("Your Rights",
                "You have the right to access, correct, or delete your personal data at any time. You may also object to or restrict processing of your personal data."),
            _section("Contact Us",
                "Questions about this policy?\nsupport@digibulkmarketing.com\n\nDigiBulk Marketing Pvt. Ltd.\nIndia"),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    ));
  }

  Widget _headerCard(IconData icon, String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.themeColor.primaryColor.withOpacity(0.12), AppColors.themeColor.primaryColor.withOpacity(0.04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.themeColor.primaryColor.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(color: AppColors.themeColor.primaryColor.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.themeColor.primaryColor, size: 28.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyle.bold7.copyWith(fontSize: AppDimens.fontSize16, color: AppColors.themeColor.textPrimaryColor)),
                SizedBox(height: 4.h),
                Text(subtitle, style: AppTextStyle.regular7.copyWith(fontSize: AppDimens.fontSize11, color: AppColors.themeColor.textSecondaryColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 4.w, height: 18.h, decoration: BoxDecoration(color: AppColors.themeColor.primaryColor, borderRadius: BorderRadius.circular(4.r))),
              SizedBox(width: 10.w),
              Expanded(child: Text(title, style: AppTextStyle.bold7.copyWith(fontSize: AppDimens.fontSize14, color: AppColors.themeColor.textPrimaryColor))),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(color: AppColors.themeColor.cardBgColor, borderRadius: BorderRadius.circular(12.r)),
            child: Text(content, style: AppTextStyle.regular7.copyWith(fontSize: AppDimens.fontSize13, color: AppColors.themeColor.textSecondaryColor, height: 1.6)),
          ),
        ],
      ),
    );
  }
}
