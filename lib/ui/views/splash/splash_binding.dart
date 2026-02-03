import 'package:get/get.dart';
import 'package:telecaller_app/ui/views/splash/splash_controller.dart';


class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(
          () => SplashController(),
    );
  }
}
