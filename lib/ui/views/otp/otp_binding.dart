
import 'package:get/get.dart';
import 'package:telecaller_app/ui/views/otp/otp_controller.dart';


class OtpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpController>(
          () =>OtpController(),
    );
  }
}