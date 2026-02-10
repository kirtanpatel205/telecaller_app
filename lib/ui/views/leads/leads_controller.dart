import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/core/models/all_lead_entity.dart';
import 'package:telecaller_app/core/services/api_service.dart';

class LeadsController extends GetxController {
  // Observable variables
  RxList<AllLeadLeads> allLeads = <AllLeadLeads>[].obs;
  RxBool isLoading = false.obs;
  RxString searchQuery = ''.obs;
  RxString selectedFilter = 'all'.obs;
  RxInt totalLeads = 0.obs;

  late ApiService apiService;
  late PagewiseLoadController<AllLeadLeads> pagewiseAllLeadLoadController;

  @override
  void onInit() {
    super.onInit();
    apiService = Get.find<ApiService>();
    initPagewise();
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
  void resetAndReload() {
    pagewiseAllLeadLoadController.reset();
    initPagewise();
  }

  /// Update search query and reset pagination
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    resetAndReload();
  }

  /// Update filter and reset pagination
  void updateFilter(String filter) {
    selectedFilter.value = filter;
    resetAndReload();
  }

  /// Reset filters to default
  void resetFilters() {
    searchQuery.value = '';
    selectedFilter.value = 'all';
    resetAndReload();
  }

  /// Get the next lead to call (for Auto Dial Next feature)
  Future<AllLeadLeads?> getNextLeadForCall() async {
    try {
      // Filter for leads that are "Scheduled" and not yet called
      if (allLeads.isNotEmpty) {
        final nextLead = allLeads.firstWhereOrNull(
              (lead) => lead.status == 'Scheduled',
        );
        return nextLead;
      }
      return null;
    } catch (e) {
      print('Error getting next lead: $e');
      return null;
    }
  }

  /// Mark lead as called
  Future<bool> markLeadAsCalled(String leadId) async {
    try {
      // Implement API call to mark lead as called
      // await apiService.updateLeadStatus(leadId, 'Called');
      return true;
    } catch (e) {
      print('Error marking lead as called: $e');
      return false;
    }
  }

  /// Get lead details
  Future<AllLeadLeads?> getLeadDetails(String leadId) async {
    try {
      return allLeads.firstWhereOrNull((lead) => lead.id == leadId);
    } catch (e) {
      print('Error getting lead details: $e');
      return null;
    }
  }

  @override
  void onClose() {
    // Clean up resources
    pagewiseAllLeadLoadController.dispose();
    super.onClose();
  }
}