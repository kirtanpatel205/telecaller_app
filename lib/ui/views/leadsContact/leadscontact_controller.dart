import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/core/controllers/overlay_controller.dart';
import 'package:telecaller_app/core/helpers/utils.dart';
import 'package:telecaller_app/core/models/lead_contact_id_entity.dart';
import 'package:telecaller_app/core/services/api_service.dart';

class LeadsContactController extends GetxController {
  late ApiService apiService;

  RxInt totalLeadsId = 0.obs;
  RxInt completedCount = 0.obs;
  RxInt pendingCount = 0.obs;
  RxInt scheduledCount = 0.obs;
  RxInt interestedCount = 0.obs;
  RxInt notInterestedCount = 0.obs;
  RxInt followUpCount = 0.obs;
  RxInt invalidCount = 0.obs;
  RxInt noResponseCount = 0.obs;
  RxBool buttonShow = false.obs;

  RxString searchQuery = ''.obs;
  RxString selectedFilter = 'all'.obs;
  RxString selectedSort = 'name'.obs;

  // ✅ autoCallDone HATAVYU — page wise first load pachi auto call lagse
  // OverlayController j manage karse ke next call kyare lagvanu chhe
  RxBool isLoading = false.obs;
  var optionsCall = ["updated-at", "created-at", "name", "phone"].obs;
  RxString selectedOptionCall = "updated-at".obs;

  // ✅ Track karva ke queue set thayo ke nahi
  bool _queueInitialized = false;

  late PagewiseLoadController<LeadContactIdLeadContacts>
  pagewiseLoadLeadIdController;

  @override
  void onInit() {
    super.onInit();
    argumnetGet();
    apiService = Get.find<ApiService>();
  }

  void argumnetGet() {
    if (Get.arguments != null && Get.arguments["id"] != null) {
      final String id = Get.arguments["id"];
      buttonShow.value = Get.arguments["buttonShow"] ?? false;
      print("Button show value: ${buttonShow.value}");
      initPagewise(id);
    } else {
      print("Lead ID not found in arguments");
    }
  }

  void initPagewise(String? leadId) {
    isLoading.value = true;
    _queueInitialized = false; // reset on re-init

    pagewiseLoadLeadIdController =
        PagewiseLoadController<LeadContactIdLeadContacts>(
          pageSize: 10,
          pageFuture: (pageNumber) async {
            try {
              final LeadContactIdEntity allCustomersEntity = await apiService
                  .getCallLead(page: pageNumber ?? 1, limit: 10, id: leadId);

              if (allCustomersEntity.status ?? false) {
                totalLeadsId.value = allCustomersEntity.total ?? 0;

                var leads = allCustomersEntity.leadContacts ?? [];
                _calculateStatistics(leads);
                leads = _sortLeads(leads);

                // ✅ AUTO CALL: sirf PEHLI VAAR (page 1, queue not set yet)
                if (buttonShow.value == false &&
                    leads.isNotEmpty &&
                    !_queueInitialized) {
                  _queueInitialized = true;

                  // Queue setup karo — PEHLA, call lagavta pehla
                  _setupCallQueue(leads);

                  // First number auto dial
                  final firstNumber = leads.first.contact?.phone;
                  if (firstNumber != null && firstNumber.isNotEmpty) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      makeDirectCall(firstNumber);
                    });
                  }
                }

                return leads;
              } else {
                return [];
              }
            } catch (e) {
              print('Error fetching leads: $e');
              rethrow;
            }
          },
        );

    isLoading.value = false;
  }

  // ─────────────────────────────────────────────────────────
  // Queue setup — id + name + number — OverlayController ne aapi do
  // ─────────────────────────────────────────────────────────
  void _setupCallQueue(List<LeadContactIdLeadContacts> leads) {
    // OverlayController ensure
    if (!Get.isRegistered<OverlayController>()) {
      Get.put(OverlayController());
    }
    final overlayCtrl = Get.find<OverlayController>();

    // ✅ BADHA leads queue ma — id, name, number sathe
    final queue =
        leads
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

    overlayCtrl.callQueue = queue;
    // ✅ Index 1 thi start — index 0 abhi dial thai rahi chhe
    overlayCtrl.currentQueueIndex = 1;
    overlayCtrl.isAutoCallMode.value = true;

    print("✅ Queue set: ${queue.length} contacts");
    for (int i = 0; i < queue.length; i++) {
      print(
        "  [$i] ${queue[i]['name']} | ${queue[i]['number']} | id=${queue[i]['id']}",
      );
    }
  }

  // ─────────────────────────────────────────────────────────
  // Manual Call (buttonShow == true)
  // ─────────────────────────────────────────────────────────
  void onManualCallTapped(LeadContactIdLeadContacts lead) {
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
    overlayCtrl.currentQueueIndex = 0;
    overlayCtrl.isAutoCallMode.value = false;

    makeDirectCall(number);
  }

  void _calculateStatistics(List<LeadContactIdLeadContacts> leads) {
    completedCount.value =
        leads.where((l) => l.status?.toLowerCase() == 'completed').length;
    pendingCount.value =
        leads.where((l) => l.status?.toLowerCase() == 'pending').length;
    scheduledCount.value =
        leads.where((l) => l.status?.toLowerCase() == 'scheduled').length;
    interestedCount.value =
        leads.where((l) => l.status?.toLowerCase() == 'interested').length;
    notInterestedCount.value =
        leads.where((l) => l.status?.toLowerCase() == 'not interested').length;
    followUpCount.value =
        leads.where((l) => l.status?.toLowerCase() == 'follow up').length;
    invalidCount.value =
        leads.where((l) => l.status?.toLowerCase() == 'invalid').length;
    noResponseCount.value =
        leads.where((l) => l.status?.toLowerCase() == 'no response').length;
  }

  List<LeadContactIdLeadContacts> _sortLeads(
    List<LeadContactIdLeadContacts> leads,
  ) {
    final sortedLeads = List<LeadContactIdLeadContacts>.from(leads);
    switch (selectedSort.value) {
      case 'name':
        sortedLeads.sort(
          (a, b) => (a.contact?.name ?? '').compareTo(b.contact?.name ?? ''),
        );
        break;
      case 'phone':
        sortedLeads.sort(
          (a, b) => (a.contact?.phone ?? '').compareTo(b.contact?.phone ?? ''),
        );
        break;
      case 'date':
        sortedLeads.sort((a, b) {
          final dateA = DateTime.tryParse(a.createdAt ?? '') ?? DateTime.now();
          final dateB = DateTime.tryParse(b.createdAt ?? '') ?? DateTime.now();
          return dateB.compareTo(dateA);
        });
        break;
      case 'status':
        sortedLeads.sort((a, b) => (a.status ?? '').compareTo(b.status ?? ''));
        break;
      default:
        break;
    }
    return sortedLeads;
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    resetAndReload();
  }

  void updateFilter(String filter) {
    selectedFilter.value = filter;
    resetAndReload();
  }

  void updateSort(String sort) {
    selectedSort.value = sort;
    resetAndReload();
  }

  void resetAndReload() {
    pagewiseLoadLeadIdController.reset();
  }

  String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return '#4CAF50';
      case 'pending':
        return '#2196F3';
      case 'scheduled':
        return '#FF9800';
      case 'interested':
        return '#8BC34A';
      case 'not interested':
        return '#F44336';
      case 'follow up':
        return '#9C27B0';
      case 'invalid':
        return '#757575';
      case 'no response':
        return '#BDBDBD';
      default:
        return '#9E9E9E';
    }
  }

  String formatDuration(int? seconds) {
    if (seconds == null || seconds == 0) return 'NaN Sec';
    if (seconds < 60) return '$seconds Sec';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')} Min';
  }

  int getTotalDuration(List<LeadContactIdLeadContactsLogs>? logs) {
    if (logs == null || logs.isEmpty) return 0;
    return logs.fold<int>(0, (sum, log) => sum + (log.duration ?? 0));
  }

  Future<void> onDropdownSelectedCall(String value) async {
    selectedOptionCall.value = value;
  }

  Future<void> makeDirectCall(String phoneNumber) async {
    try {
      await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    } catch (e) {
      Utils.showToast("Failed to make call: $e");
    }
  }
}
