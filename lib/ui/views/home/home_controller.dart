import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_routes.dart';
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


  void navigateToPage(int index) {
    switch (index) {
      case 0:
        Get.toNamed(Routes.HOME);
        break;
      case 1:
        Get.toNamed(Routes.LEADS);
        break;
      case 2:
        Get.toNamed(Routes.AUTO_DIAL);
        break;
      case 3:
        Get.toNamed(Routes.SETTING);
        break;
    }
  }

}
