import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_dimens.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/ui/widgets/custom-appbar.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.themeColor.bgColor,
      appBar: CustomAppBar(
        titleText: "terms_conditions".tr,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerCard(Icons.description_rounded, "Terms & Conditions", "Effective: 01 January 2025"),
            SizedBox(height: 24.h),
            _section("1. Acceptance of Terms",
                "By downloading, installing, or using the TeleCaller App, you agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use the application."),
            _section("2. Use of the Application",
                "You agree to use the application only for lawful purposes and in a manner that does not infringe the rights of others. You must not use the app to make unsolicited calls, spam, or harass individuals."),
            _section("3. Account Responsibility",
                "You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account. Notify us immediately of any unauthorized use of your account."),
            _section("4. Data and Privacy",
                "Your use of this application is also governed by our Privacy Policy, which is incorporated into these Terms by reference. By using the app, you consent to our data practices as described therein."),
            _section("5. Call Logs and Recording",
                "The app may access call logs to provide telecalling features. You are solely responsible for ensuring compliance with applicable laws regarding call recording and data in your jurisdiction."),
            _section("6. Intellectual Property",
                "All content and functionality of this application, including but not limited to design, graphics, and software, is the property of DigiБulk Marketing Pvt. Ltd. and is protected by applicable IP laws."),
            _section("7. Limitation of Liability",
                "To the fullest extent permitted by law, DigiБulk Marketing Pvt. Ltd. shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of this application."),
            _section("8. Termination",
                "We reserve the right to terminate or suspend your access to the application at any time, without prior notice, for conduct that we believe violates these Terms or is harmful to other users."),
            _section("9. Changes to Terms",
                "We may modify these Terms at any time. Continued use of the application after any changes indicates your acceptance of the new Terms. It is your responsibility to review these Terms periodically."),
            _section("10. Contact",
                "For any questions regarding these Terms:\nsupport@digibulkmarketing.com\n\nDigiBulk Marketing Pvt. Ltd.\nIndia"),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
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
