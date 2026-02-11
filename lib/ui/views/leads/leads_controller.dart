import 'package:flutter_pagewise/flutter_pagewise.dart';
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


  late ApiService apiService;
  late PagewiseLoadController<AllLeadLeads> pagewiseAllLeadLoadController;

  @override
  void onInit() {
    super.onInit();
    apiService = Get.find<ApiService>();
    initPagewise();
    generatePastDatesFromStartOfYear();
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
          // Fetch leads from API
          final AllLeadEntity allCustomersEntity = await apiService.allLead(
            page: pageNumber ?? 1,
            limit: 10,
            // search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
            // Uncomment if your API supports filtering
            // filter: selectedFilter.value != 'all' ? selectedFilter.value : null,
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
    initPagewise();
  }

  // id arguments

  LedadContectId(String id){
    print("LeadContact id $id");
    Get.toNamed(Routes.LEADSCONTACT,arguments: {
      "id":id
    });


  }


}