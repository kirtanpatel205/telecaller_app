import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:telecaller_app/constants/app_routes.dart';
import 'package:telecaller_app/core/models/all_lead_entity.dart';
import 'package:telecaller_app/core/services/api_service.dart';

class LeadsController extends GetxController {
  // Observable variables
  RxBool isLoading = false.obs;
  RxInt totalLeads = 0.obs;
  var selectedDateIndex = 0.obs;
  final dates = <String>[].obs;
  var selectedLeadId = ''.obs;
  var selectedDateString = DateFormat('yyyy-MM-dd').format(DateTime.now()).obs;

  // Filter variables
  RxBool isApplyFilter = false.obs;
  RxString filterType = "all_time".obs; // all_time, specific_time
  RxString status = "all".obs;
  Rx<DateTime?> startDate = Rxn<DateTime>();
  Rx<DateTime?> endDate = Rxn<DateTime>();
  RxString searchText = "".obs;
  RxString sortBy = "create".obs;
  final TextEditingController searchController = TextEditingController();

  final Map<String, String> sortOptions = {
    "name": "name",
    "create-at": "create-at",
    "start_date": "start_date",
    "end_date": "end_date",
  };

  late ApiService apiService;
  late PagewiseLoadController<AllLeadLeads> pagewiseAllLeadLoadController;

  @override
  void onInit() {
    super.onInit();
    apiService = Get.find<ApiService>();
    initPagewise();
    generatePastDatesFromStartOfYear();

    // Debounce search to avoid multiple redundant calls
    debounce(searchText, (_) => resetAndReload(),
        time: const Duration(milliseconds: 500));
  }

  @override
  void onClose() {
    // Clean up resources
    // pagewiseAllLeadLoadController.dispose();
    super.onClose();
  }

  void generatePastDatesFromStartOfYear() {
    final now = DateTime.now();
    final firstDayOfYear = DateTime(2000, 1, 1);

    final totalDays = now.difference(firstDayOfYear).inDays + 1;

    final generatedDates = List.generate(totalDays, (i) {
      final date = now.subtract(Duration(days: i));
      return "${date.day}/${date.month}/${date.year}";
    });

    dates.assignAll(generatedDates);
  }

  /// Initialize PagewiseLoadController for pagination
  void initPagewise() {
    isLoading.value = true;

    pagewiseAllLeadLoadController = PagewiseLoadController<AllLeadLeads>(
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
                                ? DateFormat('yyyy-MM-dd').format(startDate.value!)
                                : null,
                        "end_date":
                            endDate.value != null
                                ? DateFormat('yyyy-MM-dd').format(endDate.value!)
                                : null,
                      },
              "status": status.value != "all" ? status.value : null,
            };
          }

          // Fetch leads from API
          final AllLeadEntity allCustomersEntity = await apiService.allLead(
            page: pageNumber ?? 1,
            limit: 10,
            search: searchText.value.isNotEmpty ? searchText.value : null,
            filterBy: filterBy,
            sortBy: sortBy.value,
          );

          if (allCustomersEntity.status ?? false) {
            // Update total leads count
            totalLeads.value = allCustomersEntity.total ?? 0;

            // Return leads for this page
            return allCustomersEntity.leads ?? [];
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

  /// Reset pagination and reload leads
  resetAndReload() {
    pagewiseAllLeadLoadController.reset();
  }

  void applyFilters() {
    isApplyFilter.value = true;
    resetAndReload();
    Get.back(); // Close bottom sheet
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

  // id arguments

  LedadContectId({String id = ''}) {
    print("LeadContact id $id");
    Get.toNamed(
      Routes.LEADSCONTACT,
      arguments: {"id": id,},
    );
  }

  Future<void> makeCall(String? phoneNumber) async {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    } else {
      Get.snackbar(
        "Error",
        "Phone number not available",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
