import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:telecaller_app/core/controllers/auth_controller.dart';
import 'package:telecaller_app/core/models/get_static_entity.dart';
import 'package:telecaller_app/core/services/api_service.dart';

class DashboardController extends GetxController{
  AuthController authController = Get.find();

  // Dummy Observable Data for Dashboard Overview
  RxInt activeTelecallers = 0.obs;
  RxInt leadsCount = 0.obs;
  RxInt ordersCount = 0.obs;
  RxInt formsSubmitted = 0.obs;

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
  RxList<FlSpot> callsOverTimeData = <FlSpot>[].obs;

  void updateTimeFilter(String filter) {
    selectedTimeFilter.value = filter;
    generateChartData();
  }

  void updateDateRange(DateTimeRange? range) {
    if (range != null) {
      selectedDateRange.value = range;
      generateChartData();
    }
  }

  void generateChartData() {
    callsOverTimeData.clear();
    // Generate dummy data based on filter
    int numberOfPoints = 0;
    switch (selectedTimeFilter.value) {
      case 'Today':
        numberOfPoints = 6; // E.g., every 4 hours
        break;
      case 'Week':
        numberOfPoints = 7;
        break;
      case 'Month':
        numberOfPoints = 30;
        break;
      case 'Year':
        numberOfPoints = 12;
        break;
      case 'Specific':
        if (selectedDateRange.value != null) {
          numberOfPoints = selectedDateRange.value!.duration.inDays;
          if (numberOfPoints == 0) numberOfPoints = 1;
        } else {
          numberOfPoints = 10;
        }
        break;
      default:
        numberOfPoints = 10;
    }
    
    // Create random-looking data
    for (int i = 0; i <= numberOfPoints; i++) {
      double randomValue = (i * 2.5 + (i % 3 * 15) + (i % 2 == 0 ? 50 : 10)).toDouble();
      if(randomValue > 240) randomValue = 200 + (i % 20).toDouble(); // cap it roughly for looks
      callsOverTimeData.add(FlSpot(i.toDouble(), randomValue));
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    authController.refreshProfile();
    generateChartData();
    super.onInit();
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
