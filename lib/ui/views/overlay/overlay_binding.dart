import 'package:get/get.dart';
import 'package:telecaller_app/ui/views/overlay/overlay_controller.dart';

class OverlayBinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies

    Get.lazyPut(()=>OverlayController());
  }
}