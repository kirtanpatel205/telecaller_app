
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/getwidget.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:telecaller_app/constants/app_colors.dart';
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
        AppSafeArea(child: Scaffold(
      //resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(),
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
            "Verification code".tr,
            style: AppTextStyle.titleBold.copyWith(fontSize: 20),
          ),

          SizedBox(
            height: 5,
          ),

          Text(
            "We Have Send The verification Code @nlOn Your Mobile Number".trParams({"nl": "\n"}),
            style: AppTextStyle.subTitle.copyWith(fontSize: 14),
          ),

          SizedBox(
            height: 20,
          ),
          // Padding(
          //   padding: EdgeInsets.only(top: 45, right: 20, left: 17),
          //   //  child: Container(
          //   // margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          //   //  padding: EdgeInsets.only(right: 20, left: 17),
          //   child:
          PinCodeTextField(
            textStyle: TextStyle(color: AppColors.themeColor.cardColor),

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
            cursorColor: AppColors.themeColor.cardColor,
            //enableActiveFill: true,
            pinTheme: PinTheme(
              // disabledColor: Colors.white,
              //errorBorderColor: Colors.white,
              shape: PinCodeFieldShape.box,
              // borderRadius: BorderRadius.horizontal(),
              borderRadius: BorderRadius.circular(9),
              // disabledColor: AppColors.themeColor.secondaryColor,
              // activeFillColor: AppColors.themeColor.secondaryColor,
              fieldHeight: 40,
              fieldWidth: 40,
              inactiveColor: AppColors.themeColor.primaryColor,
              selectedColor: AppColors.themeColor.primaryColor,
              activeColor: AppColors.themeColor.primaryColor,
              activeFillColor: AppColors.themeColor.primaryColor,
              selectedFillColor: AppColors.themeColor.cardColor,
              inactiveFillColor: AppColors.themeColor.cardColor,
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
                          "Don’t recieve Verification code?".tr,
                          style: AppTextStyle.bold6.copyWith(
                              color: AppColors.themeColor.textSecondaryColor),
                        ),
                        Text(
                          "00:${controller.remainingTime.value.toString().padLeft(2, '0')}",
                          style: AppTextStyle.bold6.copyWith(
                              color: AppColors.themeColor.primaryColor),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don’t recieve Verification code?".tr,
                          style: AppTextStyle.bold6.copyWith(
                              color: AppColors.themeColor.textSecondaryColor),
                        ),
                        InkWell(
                          // onPressed: controller.resendOtp,
                          onTap: () => controller.resendOtp(),
                          child: Text(
                            "Resend OTP",
                            style: AppTextStyle.bold6.copyWith(
                                color: AppColors.themeColor.primaryColor),
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          SizedBox(
            height: 50,
          ),
         Obx(()=> CustomButton(

           onClick: () => controller.verifyOtp(),
           isLoading: controller.isLoading.value,
           title: "Continue".tr,
         ),)
        ],
      ).paddingAll(20.r),
    ));
    //);
  }
}
