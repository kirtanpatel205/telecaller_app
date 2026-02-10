import 'package:get/get.dart';
import 'package:telecaller_app/core/controllers/auth_controller.dart';

class HomeController extends GetxController {
  RxInt currentTab = 0.obs;
  AuthController authController = Get.find();

  @override
  void onInit() {
    // TODO: implement onInit
    authController.refreshProfile();
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
