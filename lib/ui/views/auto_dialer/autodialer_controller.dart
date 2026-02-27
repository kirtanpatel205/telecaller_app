import 'dart:async';
import 'package:get/get.dart';
import 'package:collection/collection.dart';
import 'package:telecaller_app/core/controllers/overlay_controller.dart';
import 'package:telecaller_app/core/models/all_lead_entity.dart';
import 'package:telecaller_app/core/models/lead_contact_id_entity.dart';
import 'package:telecaller_app/core/services/api_service.dart';
import 'package:telecaller_app/core/services/phone_status_service.dart';

class AutoDialerController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final status = 'idle'.obs;
  final isLoading = false.obs;

  final totalAttempts = 0.obs;
  final connected = 0.obs;
  final successful = 0.obs;
  final failed = 0.obs;

  final callTimer = '00:00'.obs;
  Timer? _activeCallTimer;
  int _seconds = 0;

  // Lead Categories (Lead Pages)
  final leadsDatasets = <AllLeadLeads>[].obs;
  final selectedLeadDataset = Rxn<AllLeadLeads>();

  // Contacts for selected Lead
  final contactQueue = <LeadContactIdLeadContacts>[].obs;

  // Dialer Settings
  final autoNextLead = true.obs;
  final callSpeed = 3.0.obs;
  
  // Current Active Contact
  final currentContact = Rxn<LeadContactIdLeadContacts>();
  final countdown = 0.obs;

  @override
  void onInit() {
    super.onInit();
    initData();
    
    // Listen to call status to start/stop duration timer
    final phoneService = Get.find<PhoneStatusService>();
    ever(phoneService.isCallActive, (bool active) {
      if (active) {
        _startActiveTimer();
        if (status.value == 'idle') {
          status.value = 'dialing'; // For manual/external calls
        }
      } else {
        _stopActiveTimer();
        // When call ends, set status back to idle so "Next Call In" can show
        if (status.value == 'dialing') {
          status.value = 'idle';
        }
      }
    });
  }

  void _startActiveTimer() {
    _stopActiveTimer();
    _seconds = 0;
    callTimer.value = '00:00';
    _activeCallTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds++;
      final mins = (_seconds ~/ 60).toString().padLeft(2, '0');
      final secs = (_seconds % 60).toString().padLeft(2, '0');
      callTimer.value = '$mins:$secs';
    });
  }

  void _stopActiveTimer() {
    _activeCallTimer?.cancel();
    _activeCallTimer = null;
  }

  Future<void> initData() async {
    await fetchLeadsDatasets();

    // Check for incoming arguments
    if (Get.arguments != null && Get.arguments["id"] != null) {
      final String incomingId = Get.arguments["id"];
      final match = leadsDatasets.firstWhereOrNull((d) => d.id == incomingId);
      if (match != null) {
        onLeadDatasetChanged(match);
      } else {
        // If not in first page, fetch explicitly
        await fetchContactsForLead(incomingId);
      }
    }
  }

  Future<void> fetchLeadsDatasets() async {
    isLoading.value = true;
    try {
      final response = await _apiService.allLead(page: 0, limit: 10);
      if (response.status ?? false) {
        leadsDatasets.assignAll(response.leads ?? []);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch lead datasets: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onLeadDatasetChanged(AllLeadLeads? dataset) async {
    selectedLeadDataset.value = dataset;
    if (dataset != null && dataset.id != null) {
      await fetchContactsForLead(dataset.id!);
    } else {
      contactQueue.clear();
    }
  }

  Future<void> fetchContactsForLead(String leadId) async {
    isLoading.value = true;
    try {
      final response = await _apiService.getCallLead(
        id: leadId,
        page: 0,
        limit: 10,
      );
      if (response.status ?? false) {
        contactQueue.assignAll(response.leadContacts ?? []);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch contacts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void startDialing() {
    if (contactQueue.isEmpty) {
      Get.snackbar(
        'Error',
        'No contacts available to dial. Please select a Lead dataset first.',
      );
      return;
    }

    status.value = 'dialing';

    // Setup OverlayController for auto-dialing
    if (!Get.isRegistered<OverlayController>()) {
      Get.put(OverlayController());
    }
    final overlayCtrl = Get.find<OverlayController>();

    final queue =
        contactQueue
            .where(
              (l) => l.contact?.phone != null && l.contact!.phone!.isNotEmpty,
            )
            .map(
              (l) => {
                "id": l.id ?? "",
                "name": l.contact?.name ?? "Unknown",
                "number": l.contact?.phone ?? "",
              },
            )
            .toList();

    if (queue.isEmpty) {
      Get.snackbar(
        'Error',
        'No valid phone numbers found in the selected lead.',
      );
      status.value = 'idle';
      return;
    }

    overlayCtrl.callQueue = queue;
    overlayCtrl.currentQueueIndex.value =
        1; // Start with first index since we dial it now
    overlayCtrl.isAutoCallMode.value = true;

    // Set current contact for UI
    _updateSyncWithOverlay(overlayCtrl);

    // Initial call
    final firstNumber = queue.first['number']!;
    overlayCtrl.makeDirectCall(firstNumber);
  }

  void _updateSyncWithOverlay(OverlayController overlayCtrl) {
    // Sync countdown for UI
    countdown.bindStream(overlayCtrl.countdown.stream);

    // Sync pause state
    ever(overlayCtrl.isPaused, (bool paused) {
      if (paused) {
        if (status.value == 'dialing') status.value = 'paused';
      } else {
        if (status.value == 'paused') status.value = 'dialing';
      }
    });

    // Listen for queue index changes OR countdown changes
    // to keep currentContact UI updated
    void refreshCurrentContact() {
       final index = overlayCtrl.currentQueueIndex.value;
       final cdValue = overlayCtrl.countdown.value;
       
       if (cdValue > 0) {
         // During countdown, show the contact we ARE ABOUT TO dial
         if (index < overlayCtrl.callQueue.length) {
           final next = overlayCtrl.callQueue[index];
           currentContact.value = contactQueue.firstWhereOrNull((l) => l.id == next['id']);
         }
       } else {
         // During call, show the contact we ARE dialing
         if (index > 0 && index <= overlayCtrl.callQueue.length) {
           final current = overlayCtrl.callQueue[index - 1];
           currentContact.value = contactQueue.firstWhereOrNull((l) => l.id == current['id']);
         }
       }
    }

    ever(overlayCtrl.currentQueueIndex, (_) => refreshCurrentContact());
    ever(overlayCtrl.countdown, (_) => refreshCurrentContact());

    // Initial set
    refreshCurrentContact();
  }

  void pauseDialing() {
    if (status.value == 'dialing') {
      status.value = 'paused';
    }
  }

  void stopDialing() {
    status.value = 'idle';
    callTimer.value = '00:00';
    currentContact.value = null;
    if (Get.isRegistered<OverlayController>()) {
      Get.find<OverlayController>().stopCountdown();
    }
  }

  void makeManualCall(LeadContactIdLeadContacts lead) {
    currentContact.value = lead;
    final number = lead.contact?.phone ?? "";
    if (number.isEmpty) return;

    if (!Get.isRegistered<OverlayController>()) {
      Get.put(OverlayController());
    }
    final overlayCtrl = Get.find<OverlayController>();

    // Manual mode: single entry queue, no auto countdown
    overlayCtrl.callQueue = [
      {
        "id": lead.id ?? "",
        "name": lead.contact?.name ?? "Unknown",
        "number": number,
      },
    ];
    overlayCtrl.currentQueueIndex.value = 0;
    overlayCtrl.isAutoCallMode.value = false;
    currentContact.value = lead; // Explicitly set for manual

    overlayCtrl.makeDirectCall(number);
  }
}
