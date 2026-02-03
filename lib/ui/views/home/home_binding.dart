import 'package:get/get.dart';
import 'package:telecaller_app/ui/views/home/home_controller.dart';

class HomeBinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(()=>HomeController());

  }

}
