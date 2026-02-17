import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OverlayController extends GetxController {

  /// ---------------- CALL INFO ----------------
  final formattedCallLogDuration = "00:00".obs;
  final lastCalledName = "No previous call".obs;
  final lastCalledNumber = "+910000000000".obs;
  final customerphoneNum = "".obs;

  /// ---------------- DROPDOWN ----------------
  final callDropdownValue = "".obs;

  final List<Map<String, String>> leadOptions = [
    {"label": "Interested", "value": "interested"},
    {"label": "Not Interested", "value": "not_interested"},
    {"label": "Reschedule", "value": "reschedule"},
    {"label": "Follow-up", "value": "follow_up"},
    {"label": "Invalid", "value": "invalid"},
    {"label": "No Response", "value": "no_response"},
    {"label": "Other", "value": "other"},
  ];

  void onDropdownChange(String value) {
    callDropdownValue.value = value;
  }

  /// ---------------- RESCHEDULE ----------------
  final rescheduleDate = "".obs;

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      rescheduleDate.value =
      "${picked.year}-${picked.month}-${picked.day}";
    }
  }

  /// ---------------- TIMER ----------------
  final countdown = 10.obs;
  Timer? _timer;

  void startTimer() {
    _timer?.cancel();
    countdown.value = 10;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void onInit() {
    startTimer();
    super.onInit();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
