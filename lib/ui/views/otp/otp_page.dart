import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_dimens.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/ui/views/otp/otp_controller.dart';
import 'package:telecaller_app/ui/widgets/app_safe_area.dart';
import 'package:telecaller_app/ui/widgets/custom-appbar.dart';
import 'package:telecaller_app/ui/widgets/custom_button.dart';

class OtpPage extends GetView<OtpController> {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: AppColors.themeColor.bgColor,
        appBar: const CustomAppBar(
          titleText: "OTP Verification",
          showBackButton: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Center aligned for better design
            children: [
                  SizedBox(height: 60.h),
                  
                  // Top Illustration with subtle shadow
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.themeColor.primaryColor.withOpacity(0.1),
                          blurRadius: 40,
                          spreadRadius: 10,
                        )
                      ],
                    ),
                    child: SvgPicture.asset(
                      'assets/images/otp-banner.svg',
                      height: 160.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                  
                  SizedBox(height: 40.h),
                  
                  Text(
                    "verification_code".tr,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.bold7.copyWith(
                      fontSize: 24.sp,
                      color: AppColors.themeColor.textPrimaryColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppTextStyle.regular7.copyWith(
                          fontSize: 14.sp,
                          color: AppColors.themeColor.textSecondaryColor,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(text: "we_have_send_the_verification_code_nlon_your_mobile_number".tr.replaceAll("@nl", "\n")),
                          TextSpan(
                            text: " ${controller.authController.phoneNumber.value.completeNumber}",
                            style: AppTextStyle.bold7.copyWith(
                              color: AppColors.themeColor.primaryColor,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 40.h),
                  
                  // OTP Entry Field with Autofill
                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    onChanged: (value) => controller.onOtpChange(value),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    animationType: AnimationType.fade,
                    autoFocus: true, // Autofill feature: focus automatically
                    enablePinAutofill: true, // Autofill feature: enable system autofill
                    cursorColor: AppColors.themeColor.primaryColor,
                    textStyle: AppTextStyle.bold7.copyWith(
                      fontSize: 20.sp,
                      color: AppColors.themeColor.textPrimaryColor,
                    ),
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(12.r),
                      fieldHeight: 50.h,
                      fieldWidth: 44.w,
                      activeColor: AppColors.themeColor.primaryColor,
                      selectedColor: AppColors.themeColor.primaryColor,
                      inactiveColor: AppColors.themeColor.bordercolror.withOpacity(0.5),
                      activeFillColor: AppColors.themeColor.cardColor,
                      selectedFillColor: AppColors.themeColor.cardColor,
                      inactiveFillColor: AppColors.themeColor.cardColor.withOpacity(0.5),
                    ),
                    enableActiveFill: true,
                    boxShadows: [
                      BoxShadow(
                        offset: const Offset(0, 4),
                        color: Colors.black.withOpacity(Get.isDarkMode ? 0.2 : 0.05),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  
                  SizedBox(height: 30.h),
                  
                  // Timer & Resend
                  Obx(() => Center(
                    child: Column(
                      children: [
                        if (controller.remainingTime.value > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "don_t_recieve_verification_code".tr + " ",
                                style: AppTextStyle.medium7.copyWith(
                                  fontSize: 13.sp,
                                  color: AppColors.themeColor.textSecondaryColor,
                                ),
                              ),
                              Text(
                                "00:${controller.remainingTime.value.toString().padLeft(2, '0')}",
                                style: AppTextStyle.bold7.copyWith(
                                  fontSize: 13.sp,
                                  color: AppColors.themeColor.primaryColor,
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "don_t_recieve_verification_code".tr + " ",
                                style: AppTextStyle.medium7.copyWith(
                                  fontSize: 13.sp,
                                  color: AppColors.themeColor.textSecondaryColor,
                                ),
                              ),
                              TextButton(
                                onPressed: controller.resendOtp,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size(0, 0),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  "resend_otp".tr,
                                  style: AppTextStyle.bold7.copyWith(
                                    fontSize: 13.sp,
                                    color: AppColors.themeColor.primaryColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  )),
                  
                  SizedBox(height: 50.h),
                  
                  // Verify Button
                  Obx(() => CustomButton(
                    onClick: () => controller.verifyOtp(),
                    isLoading: controller.isLoading.value,
                    title: "continue".tr,
                    enabled: controller.otp.value.length == 6,
                  )),
                  
                  SizedBox(height: 30.h),
                ],
              ),
        ),
      ),
    );
  }
}
