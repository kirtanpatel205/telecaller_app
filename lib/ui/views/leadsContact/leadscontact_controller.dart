import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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

  RxString selectedOptionCall = "updated-at".obs;
  RxBool isLoading = false.obs;

  // Filter & Sort variables
  RxBool isApplyFilter = false.obs;
  RxString filterType = "all_time".obs;
  RxString status = "all".obs;
  Rx<DateTime?> startDate = Rxn<DateTime>();
  Rx<DateTime?> endDate = Rxn<DateTime>();
  RxString searchText = "".obs;
  RxString sortBy = "create".obs;
  final TextEditingController searchController = TextEditingController();

  final Map<String, String> sortOptions = {
    "name": "name",
    "email": "email",
    "phone": "phone",
    "create-at": "create-at",
    // "update": "Updated Date",
  };

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
      initPagewise(id);
    } else {
      print("Lead ID not found in arguments");
    }
  }

  void initPagewise(String? leadId) {
    isLoading.value = true;

    pagewiseLoadLeadIdController =
        PagewiseLoadController<LeadContactIdLeadContacts>(
          pageSize: 10,
          pageFuture: (pageNumber) async {
            try {
              // Build filter payload
              Map<String, dynamic>? filterBy;
              if (isApplyFilter.value) {
                filterBy = {
                  "date_type": filterType.value,
                  "date":
                      filterType.value == "all_time"
                          ? null
                          : {
                            "start_date":
                                startDate.value != null
                                    ? DateFormat('yyyy-MM-dd').format(
                                      startDate.value!,
                                    )
                                    : null,
                            "end_date":
                                endDate.value != null
                                    ? DateFormat('yyyy-MM-dd').format(
                                      endDate.value!,
                                    )
                                    : null,
                          },
                  "status": status.value != "all" ? status.value : null,
                };
              }

              final LeadContactIdEntity allCustomersEntity = await apiService
                  .getCallLead(
                    page: pageNumber ?? 1,
                    limit: 10,
                    id: leadId,
                    search: searchText.value.isNotEmpty ? searchText.value : null,
                    filterBy: filterBy,
                    sortBy: sortBy.value,
                  );

              if (allCustomersEntity.status ?? false) {
                totalLeadsId.value = allCustomersEntity.total ?? 0;

                var leads = allCustomersEntity.leadContacts ?? [];
                _calculateStatistics(leads);
                leads = _sortLeads(leads);

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
  // Manual Call (buttonShow == true)
  // ─────────────────────────────────────────────────────────


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
    switch (sortBy.value) {
      case 'name':
        sortedLeads.sort(
          (a, b) => (a.contact?.name ?? '').compareTo(b.contact?.name ?? ''),
        );
        break;
      case 'email':
        sortedLeads.sort(
          (a, b) => (a.contact?.email ?? '').compareTo(b.contact?.email ?? ''),
        );
        break;
      case 'phone':
        sortedLeads.sort(
          (a, b) => (a.contact?.phone ?? '').compareTo(b.contact?.phone ?? ''),
        );
        break;
      case 'create':
        sortedLeads.sort((a, b) {
          final dateA = DateTime.tryParse(a.createdAt ?? '') ?? DateTime.now();
          final dateB = DateTime.tryParse(b.createdAt ?? '') ?? DateTime.now();
          return dateB.compareTo(dateA);
        });
        break;
      case 'update':
        sortedLeads.sort((a, b) {
          final dateA = DateTime.tryParse(a.updatedAt ?? '') ?? DateTime.now();
          final dateB = DateTime.tryParse(b.updatedAt ?? '') ?? DateTime.now();
          return dateB.compareTo(dateA);
        });
        break;
      default:
        break;
    }
    return sortedLeads;
  }

  void updateSearch(String query) {
    searchText.value = query;
    resetAndReload();
  }

  void updateFilter(String filter) {
    status.value = filter;
    resetAndReload();
  }

  void updateSort(String sort) {
    sortBy.value = sort;
    resetAndReload();
  }

  void resetAndReload() {
    pagewiseLoadLeadIdController.reset();
  }

  void applyFilters() {
    isApplyFilter.value = true;
    resetAndReload();
    Get.back();
  }

  void resetFilters() {
    isApplyFilter.value = false;
    filterType.value = "all_time";
    status.value = "all";
    startDate.value = null;
    endDate.value = null;
    searchText.value = "";
    sortBy.value = "create";
    searchController.clear();
    resetAndReload();
  }

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'scheduled':
        return const Color(0xFF4F46E5);
      case 'completed':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'interested':
        return const Color(0xFF8BC34A);
      case 'not interested':
        return const Color(0xFFF44336);
      case 'follow up':
        return const Color(0xFF9C27B0);
      case 'invalid':
        return const Color(0xFF757575);
      case 'no response':
        return const Color(0xFFBDBDBD);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Future<void> makeCall(String? phoneNumber) async {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      await Utils.makeDirectCall(phoneNumber);
    } else {
      Get.snackbar(
        "Error",
        "Phone number not available",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String formatDuration(int? seconds) {
    if (seconds == null || seconds == 0) return '0 Sec';
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

  Future<void> sendWhatsApp(String? phoneNumber) async {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final url = "https://wa.me/$phoneNumber";
      await Utils.launchURL(url);
    } else {
      Utils.showToast("Phone number not available");
    }
  }

  Future<void> sendSMS(String? phoneNumber) async {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final url = "sms:$phoneNumber";
      await Utils.launchURL(url);
    } else {
      Utils.showToast("Phone number not available");
    }
  }

  Future<void> sendEmail(String? email) async {
    if (email != null && email.isNotEmpty) {
      final url = "mailto:$email";
      await Utils.launchURL(url);
    } else {
      Utils.showToast("Email address not available");
    }
  }


}
