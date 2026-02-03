import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl_phone_field2/phone_number.dart';
import 'package:telecaller_app/constants/app_routes.dart';
import 'package:telecaller_app/core/controllers/auth_controller.dart';
import 'package:telecaller_app/core/helpers/utils.dart';
import 'package:telecaller_app/core/models/api_response_entity.dart';
import 'package:telecaller_app/core/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginController extends GetxController {
  ApiService apiService = Get.find();

  var phoneIsValid = false.obs; // this is used for phoneNumber
  Rx<PhoneNumber> phoneNumber = AuthController.to.phoneNumber;
  RxBool rememberMe = false.obs; // this is used for rememberMe
  RxBool isLoading = false.obs;

  AuthController authController = AuthController.to;
  TextEditingController phoneController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    print(phoneNumber);
  }

  void updatePhoneNumber(String number, bool valid) {
    phoneNumber.value = PhoneNumber(
      countryISOCode: phoneNumber.value.countryISOCode,
      countryCode: phoneNumber.value.countryCode,
      number: number,
    );
    phoneIsValid.value = valid;
  }

  void clearPhoneNumber() {
    phoneNumber.value = PhoneNumber(
      countryISOCode: '',
      countryCode: '',
      number: '',
    );
    phoneIsValid.value = false;
  }

  Future<void> openUrl(BuildContext context) async {
    String url = "https://master.digibulkmarketing.com/privacy-policy";

    if (url == null || url.isEmpty || url == "N/A") {
      Utils.showErrorSnackbar(
        context,
        'No valid privacy policy link available',
      );
      return;
    }

    try {
      final uri = Uri.parse(url);

      if (uri.scheme.isEmpty || uri.host.isEmpty) {
        Utils.showErrorSnackbar(context, 'Invalid URL format');
        return;
      }

      print('🔗 Launching payment URL: $url');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        Utils.showSuccessSnackbar(context, 'Privacy policy opened');
      } else {
        // Fallback
        await launchUrl(uri, mode: LaunchMode.platformDefault);
        Utils.showSuccessSnackbar(context, 'Privacy policy opened');
      }
    } catch (e) {
      print('❌ Error launching URL: $e');
      Utils.showErrorSnackbar(context, 'Could not launch payment link');
    }
  }

  Future<void> sendOtp() async {
    if (!phoneIsValid.value || phoneNumber.value == null) {
      Utils.showToast("optpage3".tr);
      return; // ⛔ stop execution if number is invalid
    }

    isLoading.value = true;
    try {
      print("phoneNumber ${phoneNumber.value.completeNumber}");
      ApiResponseEntity response = await apiService.sendOtp(
        phone: phoneNumber.value.completeNumber,
      );

      if (response.status == true) {
        Get.toNamed(Routes.OTP);
        authController.storePhoneNumber(phoneNumber.value);
        if (kDebugMode) {
          print('authcontroller ${authController.phoneNumber.value}');
        }
      } else if (response.message == "Access Denial") {
        Get.toNamed(Routes.CONTACTMASTER);
        Get.snackbar("Error", response.message!);
      } else {
        Get.snackbar("Error", response.message ?? "Failed to send OTP.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to send OTP. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }
}
