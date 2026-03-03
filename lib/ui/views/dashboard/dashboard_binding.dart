import 'package:get/get.dart';
import 'package:telecaller_app/ui/views/dashboard/dashboard_controller.dart';

class DashboardBinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut(()=>DashboardController());

  }

}
