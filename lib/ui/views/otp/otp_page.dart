
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/getwidget.dart';
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
    return

        // Obx(()=>
        AppSafeArea(
          top: false,
          child: Scaffold(
      //resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        titleText: "otp_verification".tr,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
              child: SvgPicture.asset(
                  height: MediaQuery.sizeOf(context).height / 2.4,
                  width: 0.8.sw,
                  'assets/images/otp-banner.svg')),


          Text(
            "verification_code".tr,
            style: AppTextStyle.bold7.copyWith(
              fontSize: AppDimens.fontSize20,
              color: AppColors.themeColor.textPrimaryColor,
            ),
          ),

          SizedBox(
            height: 5.h,
          ),

          Text(
            "we_have_send_the_verification_code_nlon_your_mobile_number".tr.trParams({"nl": "n".tr}),
            style: AppTextStyle.regular7.copyWith(
              fontSize: AppDimens.fontSize14,
              color: AppColors.themeColor.textSecondaryColor,
            ),
          ),

          SizedBox(
            height: 20.h,
          ),
          // Padding(
          //   padding: EdgeInsets.only(top: 45, right: 20, left: 17),
          //   //  child: Container(
          //   // margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          //   //  padding: EdgeInsets.only(right: 20, left: 17),
          //   child:
          PinCodeTextField(
            textStyle: AppTextStyle.bold7.copyWith(
              color: AppColors.themeColor.onPrimaryColor,
              fontSize: AppDimens.fontSize18,
            ),

            enableActiveFill: true,
            onChanged: (String otp) => controller.onOtpChange(otp),
            appContext: Get.context!,
            length: 6,

            // obscuringCharacter: '*',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            //controller: controller.otpController,
            backgroundColor: Colors.transparent,
            animationType: AnimationType.fade,
            cursorColor: AppColors.themeColor.onPrimaryColor,
            //enableActiveFill: true,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(9.r),
              fieldHeight: 45.h,
              fieldWidth: 45.w,
              inactiveColor: AppColors.themeColor.primaryColor,
              selectedColor: AppColors.themeColor.primaryColor,
              activeColor: AppColors.themeColor.primaryColor,
              activeFillColor: AppColors.themeColor.primaryColor,
              selectedFillColor: AppColors.themeColor.cardBgColor,
              inactiveFillColor: AppColors.themeColor.cardBgColor,
            ),
          ),

          Obx(
            () => Container(
              alignment: Alignment.center,
              child: controller.remainingTime.value > 0
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "don_t_recieve_verification_code".tr,
                          style: AppTextStyle.medium7.copyWith(
                              fontSize: AppDimens.fontSize12,
                              color: AppColors.themeColor.textSecondaryColor),
                        ),
                        Text(
                          "00:${controller.remainingTime.value.toString().padLeft(2, '0')}",
                          style: AppTextStyle.bold7.copyWith(
                              fontSize: AppDimens.fontSize12,
                              color: AppColors.themeColor.primaryColor),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "don_t_recieve_verification_code".tr,
                          style: AppTextStyle.medium7.copyWith(
                              fontSize: AppDimens.fontSize12,
                              color: AppColors.themeColor.textSecondaryColor),
                        ),
                        InkWell(
                          // onPressed: controller.resendOtp,
                          onTap: () => controller.resendOtp(),
                          child: Text(
                            "resend_otp".tr,
                            style: AppTextStyle.bold7.copyWith(
                                fontSize: AppDimens.fontSize12,
                                color: AppColors.themeColor.primaryColor),
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          SizedBox(
            height: 50.h,
          ),
         Obx(()=> CustomButton(

           onClick: () => controller.verifyOtp(),
           isLoading: controller.isLoading.value,
           title: "continue".tr,
         ),)
        ],
      ).paddingAll(20.r),
    ));
    //);
  }
}
