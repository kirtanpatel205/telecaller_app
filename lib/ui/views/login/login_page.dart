import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field2/intl_phone_field.dart';
import 'package:intl_phone_field2/phone_number.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_dimens.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/core/helpers/utils.dart';
import 'package:telecaller_app/ui/views/login/login_controller.dart';
import 'package:telecaller_app/ui/widgets/app_safe_area.dart';
import 'package:telecaller_app/ui/widgets/custom_button.dart';



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
              SizedBox(height: 30.h),
              Flexible(
                child: Image.asset('assets/images/L1.png', width: 0.9.sw),
              ),
              Text(
                "otp_verification".tr,
                textAlign: TextAlign.start,
                style: AppTextStyle.bold7.copyWith(
                  fontSize: AppDimens.fontSize20,
                  color: AppColors.themeColor.textPrimaryColor,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                "enter_phone_number_to_send_one_nltime_password".tr.trParams({
                  "nl": "n".tr,
                }),
                style: AppTextStyle.regular7.copyWith(
                  fontSize: AppDimens.fontSize14,
                  color: AppColors.themeColor.textSecondaryColor,
                ),
              ),
              SizedBox(height: 30.h),
              IntlPhoneField(
                textFieldPadding: EdgeInsets.symmetric(horizontal: 5),
                flagsButtonPadding: EdgeInsets.symmetric(horizontal: 5),
                controller: controller.phoneController,
                initialCountryCode: 'IN',
                keyboardType: TextInputType.number,
                cursorColor: AppColors.themeColor.primaryColor,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                showDropdownIcon: false,
                dropdownTextStyle: AppTextStyle.regular7.copyWith(
                  color: AppColors.themeColor.textPrimaryColor,
                  fontSize: AppDimens.fontSize14,
                ),
                style: AppTextStyle.regular7.copyWith(
                  color: AppColors.themeColor.textPrimaryColor,
                  fontSize: AppDimens.fontSize14,
                ),
                decoration: InputDecoration(
                  labelText: 'Enter Mobile Number'.tr,
                  labelStyle: AppTextStyle.regular7.copyWith(
                    color: AppColors.themeColor.textSecondaryColor,
                    fontSize: AppDimens.fontSize14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: AppColors.themeColor.bordercolror),
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
              SizedBox(height: 25.h),
              CustomButton(
                onClick: () => _handleSendOtp(context),
                title: "continue".tr,
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
      Utils.showSnackbar("please_check_the_terms_and_conditions_to_continue".tr);

      return;
    }

    if (!controller.phoneIsValid.value) {
      Utils.showErrorSnackbar(context, "please_enter_a_valid_phone_number".tr);

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
                style: AppTextStyle.regular7.copyWith(
                  fontSize: AppDimens.fontSize10,
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
                  style: AppTextStyle.bold7.copyWith(
                    fontSize: AppDimens.fontSize10,
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
