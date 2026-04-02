
import 'package:get/get.dart';
import 'package:telecaller_app/ui/views/language/language_controller.dart';


class LanguageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LanguageController>(
          () =>LanguageController(),
    );
  }
}
