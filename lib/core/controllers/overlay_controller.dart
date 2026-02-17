import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OverlayController extends GetxController {

  /// -----------------------------
  /// CALL INFO
  /// -----------------------------

  RxString formattedCallLogDuration = "00:00".obs;
  RxString lastCalledName = "".obs;
  RxString lastCalledNumber = "".obs;
  RxString customerphoneNum = "".obs;

  /// -----------------------------
  /// DROPDOWN
  /// -----------------------------

  RxString dropdownValue = "".obs;

  List<Map<String, String>> leadOptions = [
    {"label": "Interested", "value": "interested"},
    {"label": "Not Interested", "value": "not_interested"},
    {"label": "Call Later", "value": "reschedule"},
    {"label": "Switch Off", "value": "switch_off"},
  ];

  void ondropdownchange(String value) {
    dropdownValue.value = value;
  }

  /// -----------------------------
  /// RESCHEDULE
  /// -----------------------------

  RxString rescheduledate = "".obs;

  Future<void> pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      rescheduledate.value =
      "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
    }
  }

  /// -----------------------------
  /// CALL FLOW
  /// -----------------------------

  RxBool isCallStarted = false.obs;
  RxBool isCallInProgress = false.obs;
  RxBool isCallTask = true.obs;

  TextEditingController timeBetweenCalls =
  TextEditingController(text: "10");

  RxInt countdown = 10.obs;
  RxInt countdownEnd = 10.obs;

  Timer? timer;

  void startTimer() {
    timer?.cancel();
    countdownEnd.value = countdown.value;

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownEnd.value > 0) {
        countdownEnd.value--;
      } else {
        timer.cancel();
      }
    });
  }

  /// -----------------------------
  /// API / UPDATE PLACEHOLDER
  /// -----------------------------

  Future<void> getUpdateleadsbyid() async {
    // 🔥 Here call your API
    await Future.delayed(const Duration(milliseconds: 500));
  }

/// -----------------------------
/// PENDING LIST (Mock)
/// -----------------------------

// var pendingCustomersController = PendingCustomersMock();

}
