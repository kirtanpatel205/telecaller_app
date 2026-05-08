import 'package:get/get.dart';
import 'package:telecaller_app/ui/views/sim_selection/sim_selection_controller.dart';

class SimSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SimSelectionController>(
      () => SimSelectionController(),
    );
  }
}
