import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field2/intl_phone_field.dart';
import 'package:intl_phone_field2/phone_number.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/core/helpers/utils.dart';
import 'package:telecaller_app/ui/views/login/login_controller.dart';
import 'package:telecaller_app/ui/widgets/app_safe_area.dart';
import 'package:telecaller_app/ui/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSafeArea(
      child: Obx(
        () => Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              Flexible(
                child: Image.asset('assets/images/L1.png', width: 0.9.sw),
              ),
              Text(
                "OTP Verification",
                textAlign: TextAlign.start,
                style: AppTextStyle.titleBold.copyWith(fontSize: 20),
              ),
              SizedBox(height: 5),
              Text(
                "Enter Phone Number To Send One @nlTime Password.".trParams({
                  "nl": "\n",
                }),
                style: AppTextStyle.subTitle.copyWith(fontSize: 14),
              ),
              SizedBox(height: 30),
              IntlPhoneField(
                textFieldPadding: EdgeInsets.symmetric(horizontal: 5),
                flagsButtonPadding: EdgeInsets.symmetric(horizontal: 5),
                controller: controller.phoneController,
                initialCountryCode: 'IN',
                keyboardType: TextInputType.number,
                cursorColor: AppColors.themeColor.primaryColor,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                showDropdownIcon: false,
                dropdownTextStyle: TextStyle(
                  color: AppColors.themeColor.textPrimaryColor,
                ),
                style: TextStyle(color: AppColors.themeColor.textPrimaryColor),
                decoration: InputDecoration(
                  labelText: 'Enter Mobile Number'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(),
                  ),
                  counterText: '',
                  errorText: null,
                ),
                onChanged: (phone) {
                  controller.phoneNumber.value = phone;
                  controller.phoneIsValid.value =
                      phone.completeNumber.length >= 10;
                  print(phone.completeNumber);
                },
                onSaved: (PhoneNumber? number) {
                  controller.phoneNumber.value = number!;
                  print('On Saved: $number');
                },
                onCountryChanged: (country) {
                  print('Country changed to: ${country.name}');
                },
              ),
              buildReminderCheckBox(context),
              SizedBox(height: 25),
              CustomButton(
                onClick: () => _handleSendOtp(context),
                title: "Continue".tr,
                enabled:
                    controller.rememberMe.value &&
                    controller.phoneIsValid.value,
                isLoading: controller.isLoading.value, // Pass loading state
              ),
            ],
          ).paddingAll(20.r),
        ),
      ),
    );
  }

  void _handleSendOtp(BuildContext context) {
    if (!controller.rememberMe.value) {
      Utils.showSnackbar("Please check the terms and conditions to continue");

      return;
    }

    if (!controller.phoneIsValid.value) {
      Utils.showErrorSnackbar(context, "Please enter a valid phone number");

      return;
    }

    controller.sendOtp();
  }

  Widget buildReminderCheckBox(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: controller.rememberMe.value,
          onChanged: (value) => controller.rememberMe.value = value ?? false,
          activeColor: AppColors.themeColor.primaryColor,
        ),
        Expanded(
          child: Wrap(
            children: [
              Text(
                'I read and accepted the ',
                style: AppTextStyle.regular8
                    .copyWith(fontSize: 10)
                    .copyWith(
                      color: AppColors.themeColor.textSecondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              InkWell(
                onTap: () {
                  controller.openUrl(context);
                },
                child: Text(
                  'privacy policy',
                  style: AppTextStyle.regular8
                      .copyWith(fontSize: 10)
                      .copyWith(
                        color: AppColors.themeColor.primaryColor,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
