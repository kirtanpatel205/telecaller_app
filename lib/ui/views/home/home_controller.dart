import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_routes.dart';
import 'package:telecaller_app/core/controllers/auth_controller.dart';
import 'package:telecaller_app/core/services/fcm_service.dart';
import 'package:telecaller_app/ui/views/auto_dialer/autodialer_controller.dart';
import 'package:telecaller_app/ui/views/leads/leads_controller.dart';
import 'package:telecaller_app/ui/views/setting/setting_controller.dart';

class HomeController extends GetxController {
  RxInt currentTab = 0.obs;
  AuthController authController = Get.find();
  LeadsController leadsController = Get.put(LeadsController());
  AutoDialerController autoDialerController = Get.put(AutoDialerController());
  SettingController settingController = Get.put(SettingController());
  // FCMService FcmToken = Get.find();




  @override
  void onInit() {
    // TODO: implement onInit
    authController.refreshProfile();
    // FcmToken.init();
    super.onInit();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    authController.refreshProfile();
    super.onReady();
  }

  void onBottomTabChange(int index) {
    currentTab.value = index;
  }
}
