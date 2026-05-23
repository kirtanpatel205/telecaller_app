import 'package:get/get.dart';
import 'package:telecaller_app/ui/views/home/home_controller.dart';
import 'package:telecaller_app/ui/views/leads/leads_controller.dart';
import 'package:telecaller_app/ui/views/auto_dialer/autodialer_controller.dart';
import 'package:telecaller_app/ui/views/setting/setting_controller.dart';
import 'package:telecaller_app/ui/views/dashboard/dashboard_controller.dart';
import 'package:telecaller_app/core/controllers/call_form_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => LeadsController());
    Get.lazyPut(() => AutoDialerController());
    Get.lazyPut(() => SettingController());
    Get.lazyPut(() => DashboardController());
    Get.lazyPut(() => CallFormController());
  }
}
