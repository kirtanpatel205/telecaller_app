import 'package:get/get.dart';
import 'package:telecaller_app/ui/views/home/home_controller.dart';
import 'package:telecaller_app/ui/views/setting/setting_controller.dart';

class SettingBinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(()=>SettingController());

  }

}
