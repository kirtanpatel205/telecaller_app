import 'package:get/get.dart';
import 'package:telecaller_app/ui/views/welcome/welcome_controller.dart';


class WelcomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WelcomeController>(
          () => WelcomeController(),
    );
  }
}
