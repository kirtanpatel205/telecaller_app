import 'package:get/get.dart';
import 'package:telecaller_app/core/controllers/auth_controller.dart';

class DashboardController extends GetxController{
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
}