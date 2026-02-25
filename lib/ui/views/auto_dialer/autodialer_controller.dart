import 'package:get/get.dart';

class AutoDialerController extends GetxController {
  final status = 'idle'.obs;
  
  final totalAttempts = 0.obs;
  final connected = 0.obs;
  final successful = 0.obs;
  final failed = 0.obs;
  
  final callTimer = '00:00'.obs;
  final leadsCount = 0.obs;
  
  final selectedLead = ''.obs;
  final List<String> availableLeads = ['dhruv', 'Lead B', 'Lead C'];

  // Dialer Settings
  final autoNextLead = true.obs;
  final callSpeed = 3.0.obs;

  @override
  void onInit() {
    super.onInit();
    leadsCount.value = availableLeads.length;
    if (availableLeads.isNotEmpty) {
      selectedLead.value = availableLeads.first;
    }
  }

  void startDialing() {
    if (leadsCount.value > 0) {
      status.value = 'dialing';
    } else {
      Get.snackbar('Error', 'No leads available to dial');
    }
  }
  
  void pauseDialing() {
    if (status.value == 'dialing') {
      status.value = 'paused';
    }
  }
  
  void stopDialing() {
    status.value = 'idle';
    callTimer.value = '00:00';
  }
}