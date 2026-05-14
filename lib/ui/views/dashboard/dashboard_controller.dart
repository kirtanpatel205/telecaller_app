import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:telecaller_app/core/controllers/auth_controller.dart';
import 'package:telecaller_app/core/models/call_chart_entity.dart';
import 'package:telecaller_app/core/models/lead_chart_entity.dart';
import 'package:telecaller_app/core/models/get_static_entity.dart';
import 'package:telecaller_app/core/services/api_service.dart';

class DashboardController extends GetxController{


  @override
  void onInit() {
    // TODO: implement onInit
    authController.refreshProfile();
    super.onInit();
    fetchChartData();
    fetchLeadChartData();
    static();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    // authController.refreshProfile();
    super.onReady();
  }

  RxBool isLoading = true.obs;
  ApiService apiService = Get.find();
  AuthController authController = Get.find();

  // Dummy Observable Data for Dashboard Overview
  RxInt activeTelecallers = 0.obs;
  RxInt leadsCount = 0.obs;
  RxInt ordersCount = 0.obs;
  RxInt formsSubmitted = 0.obs;
  final items = [
    {"label": "today".tr, "value": "today"},
    {"label": "week".tr, "value": "week"},
    {"label": "month".tr, "value": "month"},
    {"label": "year".tr, "value": "year"},
    {"label": "specific".tr, "value": "specific"},
  ];

  // Lead Contacts
  RxInt leadContactAllToday = 0.obs;
  RxInt leadContactAllTotal = 0.obs;
  RxInt leadContactCompletedToday = 0.obs;
  RxInt leadContactCompletedTotal = 0.obs;
  RxInt leadContactScheduledToday = 0.obs;
  RxInt leadContactScheduledTotal = 0.obs;
  RxInt leadContactPendingToday = 0.obs;
  RxInt leadContactPendingTotal = 0.obs;

  // Calls
  RxInt callsIncomingToday = 0.obs;
  RxInt callsIncomingTotal = 0.obs;
  RxInt callsMissedToday = 0.obs;
  RxInt callsMissedTotal = 0.obs;
  RxInt callsNotAnsweredToday = 0.obs;
  RxInt callsNotAnsweredTotal = 0.obs;
  RxInt callsOutgoingToday = 0.obs;
  RxInt callsOutgoingTotal = 0.obs;

  // Chart Data
  RxString selectedTimeFilter = 'Today'.obs;
  Rxn<DateTimeRange> selectedDateRange = Rxn<DateTimeRange>();
  RxList<CallChartBarChart> barChartData = <CallChartBarChart>[].obs;
  
  // Pie Chart Data
  RxInt touchedPieIndex = (-1).obs;
  // Pie Chart Data
  RxInt incomingPieCount = 0.obs;
  RxInt outgoingPieCount = 0.obs;
  RxInt missedPieCount = 0.obs;
  RxInt notAnsweredPieCount = 0.obs;

  RxBool isChartLoading = true.obs;

  // Lead Chart Data
  RxString selectedLeadTimeFilter = 'Today'.obs;
  Rxn<DateTimeRange> selectedLeadDateRange = Rxn<DateTimeRange>();
  RxList<LeadChartLeads> leadBarChartData = <LeadChartLeads>[].obs;
  
  // Lead Pie Chart Data
  RxInt touchedLeadPieIndex = (-1).obs;
  RxInt leadCompletedPieCount = 0.obs;
  RxInt leadScheduledPieCount = 0.obs;
  RxInt leadPendingPieCount = 0.obs;

  RxBool isLeadChartLoading = true.obs;

  void updateTimeFilter(String filter) {
    selectedTimeFilter.value = filter;
    fetchChartData();
  }

  void updateDateRange(DateTimeRange? range) {
    if (range != null) {
      selectedDateRange.value = range;
      fetchChartData();
    }
  }

  void fetchChartData() async {
    isChartLoading.value = true;
    barChartData.clear();

    String filter = selectedTimeFilter.value;
    String? startDate;
    String? endDate;

    if (filter == 'Specific' && selectedDateRange.value != null) {
      startDate = selectedDateRange.value!.start.toIso8601String().split('T').first;
      endDate = selectedDateRange.value!.end.toIso8601String().split('T').first;
    }

    String apiFilter = filter.toLowerCase().replaceAll(' ', '_');
    if (apiFilter == 'week') apiFilter = 'this_week';
    if (apiFilter == 'month') apiFilter = 'this_month';
    if (apiFilter == 'year') apiFilter = 'this_year';

    try {
      final CallChartEntity chartEntity = await apiService.callChart(
        filter: apiFilter,
        startDate: startDate ?? '',
        endDate: endDate ?? '',
      );

      if (chartEntity.status) {
        // Handle Bar Chart Data
        if (chartEntity.barChart.isNotEmpty) {
           barChartData.assignAll(chartEntity.barChart);
        }

        // Handle Pie Chart Data
        incomingPieCount.value = chartEntity.pieChart.incomingCall;
        outgoingPieCount.value = chartEntity.pieChart.outgoingCall;
        missedPieCount.value = chartEntity.pieChart.missedCall;
        notAnsweredPieCount.value = chartEntity.pieChart.notAnsweredCall;
      }
    } catch (e) {
      log("Error fetching chart data: $e");
    } finally {
      isChartLoading.value = false;
    }
  }


  void updateLeadTimeFilter(String filter) {
    selectedLeadTimeFilter.value = filter;
    fetchLeadChartData();
  }

  void updateLeadDateRange(DateTimeRange? range) {
    if (range != null) {
      selectedLeadDateRange.value = range;
      fetchLeadChartData();
    }
  }

  void fetchLeadChartData() async {
    isLeadChartLoading.value = true;
    leadBarChartData.clear();

    String filter = selectedLeadTimeFilter.value;
    String? startDate;
    String? endDate;

    if (filter == 'Specific' && selectedLeadDateRange.value != null) {
      startDate = selectedLeadDateRange.value!.start.toIso8601String().split('T').first;
      endDate = selectedLeadDateRange.value!.end.toIso8601String().split('T').first;
    }

    String apiFilter = filter.toLowerCase().replaceAll(' ', '_');
    if (apiFilter == 'week') apiFilter = 'this_week';
    if (apiFilter == 'month') apiFilter = 'this_month';
    if (apiFilter == 'year') apiFilter = 'this_year';

    try {
      final LeadChartEntity chartEntity = await apiService.leadChart(
        filter: apiFilter,
        startDate: startDate ?? '',
        endDate: endDate ?? '',
      );

      if (chartEntity.status) {
        // Handle Bar Chart Data
        if (chartEntity.leads.isNotEmpty) {
           leadBarChartData.assignAll(chartEntity.leads);
        }

        // Handle Pie Chart Data
        leadCompletedPieCount.value = chartEntity.pieChart.completed;
        leadScheduledPieCount.value = chartEntity.pieChart.scheduled;
        leadPendingPieCount.value = chartEntity.pieChart.pending;
      }
    } catch (e) {
      log("Error fetching lead chart data: $e");
    } finally {
      isLeadChartLoading.value = false;
    }
  }


  void static() async {
    isLoading.value = true;
    GetStaticEntity statisticEntity = await apiService.DashboardStastics();
    if (statisticEntity.status == true) {
      activeTelecallers.value = statisticEntity.statistics.totalLeads;
      leadsCount.value = statisticEntity.statistics.todayLeads;
      ordersCount.value = statisticEntity.statistics.totalFormSubmitted;
      formsSubmitted.value = statisticEntity.statistics.todayFormSubmitted;



      leadContactAllToday.value = statisticEntity.statistics.todayLeadContacts;
      leadContactAllTotal.value = statisticEntity.statistics.totalLeadContacts;
      leadContactCompletedToday.value = statisticEntity.statistics.completedToday;
      leadContactCompletedTotal.value = statisticEntity.statistics.completedTotal;
      leadContactScheduledToday.value = statisticEntity.statistics.scheduledToday;
      leadContactScheduledTotal.value = statisticEntity.statistics.scheduledTotal;
      leadContactPendingToday.value = statisticEntity.statistics.pendingToday;
      leadContactPendingTotal.value = statisticEntity.statistics.pendingTotal;

      callsIncomingToday.value = statisticEntity.statistics.incomingToday;
      callsIncomingTotal.value = statisticEntity.statistics.incomingTotal;
      callsMissedToday.value = statisticEntity.statistics.missedToday;
      callsMissedTotal.value = statisticEntity.statistics.missedTotal;
      callsNotAnsweredToday.value = statisticEntity.statistics.notAnsweredToday;
      callsNotAnsweredTotal.value = statisticEntity.statistics.notAnsweredTotal;
      callsOutgoingToday.value = statisticEntity.statistics.outgoingToday;
      callsOutgoingTotal.value = statisticEntity.statistics.outgoingTotal;
    }
    isLoading.value = false;
    log("statisticEntity Api ${statisticEntity}");
    // log("${staticData.value.length}");
  }
}
