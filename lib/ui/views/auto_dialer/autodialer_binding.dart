import 'package:get/get.dart';
import 'package:telecaller_app/ui/views/auto_dialer/autodialer_controller.dart';

class AutodialerBinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(()=>AutoDialerController());

  }

}
