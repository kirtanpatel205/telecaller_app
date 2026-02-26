import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telecaller_app/constants/app_routes.dart';
import 'package:telecaller_app/core/controllers/auth_controller.dart';
import 'package:telecaller_app/core/services/fcm_service.dart';
import 'package:telecaller_app/ui/views/auto_dialer/autodialer_controller.dart';
import 'package:telecaller_app/ui/views/dashboard/dashboard_controller.dart';
import 'package:telecaller_app/ui/views/leads/leads_controller.dart';
import 'package:telecaller_app/ui/views/setting/setting_controller.dart';

class HomeController extends GetxController {
  RxInt currentTab = 0.obs;
  AuthController authController = Get.find();
  FCMService fcmService = Get.find();


  LeadsController leadsController = Get.put(LeadsController());
  AutoDialerController autoDialerController = Get.put(AutoDialerController());
  SettingController settingController = Get.put(SettingController());
  DashboardController dashboardController = Get.put(DashboardController());
  // FCMService fcmService = Get.put(FCMService().init());

  // FCMService FcmToken = Get.find();




  @override
  void onInit() async {
    super.onInit();
    await _checkPermissions();
    await Get.put<FCMService>(FCMService()).init();
  }

  Future<void> _checkPermissions() async {
    // Request Phone permission (needed for ACTION_CALL)
    if (await Permission.phone.isDenied) {
      await Permission.phone.request();
    }

    // Request System Alert Window permission (needed to start activity from background)
    if (await Permission.systemAlertWindow.isDenied) {
      print("System Alert Window permission is denied. Requesting...");
      // This will redirect user to settings on Android
      await Permission.systemAlertWindow.request();
    }
  }

  @override
  void onReady() {
    // TODO: implement onReady
    // authController.refreshProfile();
    super.onReady();
  }

  void onBottomTabChange(int index) {
    currentTab.value = index;
  }
}
