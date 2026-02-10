import 'package:get/get.dart';
import 'package:telecaller_app/ui/views/home/home_controller.dart';
import 'package:telecaller_app/ui/views/notifiction/notifiction_controller.dart';

class NotifictionBinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(()=>NotifictionController());

  }

}
