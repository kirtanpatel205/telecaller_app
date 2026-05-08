import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// import 'package:dbm_emp/core/models/login_response_entity.dart';

import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:telecaller_app/core/controllers/auth_controller.dart';
import 'package:telecaller_app/core/helpers/utils.dart';
import 'package:telecaller_app/core/models/api_response_entity.dart';
import 'package:telecaller_app/core/models/login_response_entity.dart';
import 'package:telecaller_app/core/services/api_service.dart';

class OtpController extends GetxController {
  AuthController authController = AuthController.to;
  ApiService apiService = Get.find();

  RxString otp = "".obs;
  RxInt remainingTime = 46.obs;
  RxBool isLoading = false.obs;
  Timer? _timer;

  TextEditingController otpController = TextEditingController();

  void startTimer() {
    _timer?.cancel();
    remainingTime.value = 46;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime.value == 0) {
        timer.cancel();
      } else {
        remainingTime.value--;
      }
    });
  }

  void onOtpChange(String otp) {
    this.otp.value = otp;
    // print("width: ${Get.width}");
    // print("height: ${Get.height}");
  }

  @override
  void onInit() {
    startTimer();
    // TODO: implement onInit
    super.onInit();
    // print("width: ${Get.width}");
    // print("height: ${Get.height}");
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    // print("width: ${Get.width}");
    // print("height: ${Get.height}");
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> verifyOtp() async {
    print("verifyOtp: start");
    isLoading.value = true;

    try {
      LoginResponseEntity response = await apiService.verifyOtp(
        phone: authController.phoneNumber.value.completeNumber,
        authType: "phone",
        otp: otp.value,
      );
      if (response.status == false) {
        Utils.showToast("Your account is inactive, Please contact admin");
      }
      authController.checkUserManually(response);

      isLoading.value = false;
    } catch (e) {
      Utils.showToast("Error: " + e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    startTimer();
    isLoading.value = true;
    try {
      ApiResponseEntity response = await apiService.sendOtp(
        phone: authController.phoneNumber.value.number,
      );
      if (response.status == true) {
        Utils.showToast(response.message!);
      } else {
        Utils.showToast(response.message!);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to resend OTP. $e");
      }
    } finally {
      isLoading.value = false;
    }
  }


}
