import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:telecaller_app/core/models/call_lead_update_response_entity.dart';
import 'package:telecaller_app/core/services/api_service.dart';

class OverlayController extends GetxController {
  // ─────────────────────────────────────────────
  // CALL INFO
  // ─────────────────────────────────────────────
  RxString formattedCallLogDuration = "00:00".obs;
  RxString lastCalledName = "No previous call".obs;
  RxString lastCalledNumber = "".obs;

  // ─────────────────────────────────────────────
  // CALL QUEUE
  // Entry: { "id": "...", "name": "...", "number": "..." }
  // ─────────────────────────────────────────────
  List<Map<String, String>> callQueue = [];
  int currentQueueIndex = 0;
  RxBool isAutoCallMode = false.obs;

  // Current lead info for API update
  String _currentLeadId = "";
  int _currentDurationSeconds = 0;

  // ─────────────────────────────────────────────
  // DROPDOWN / RESCHEDULE
  // ─────────────────────────────────────────────
  RxString callDropdownValue = "".obs;

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
    stopCountdown(); // user selecting = auto countdown band
  }

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
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  // ─────────────────────────────────────────────
  // COUNTDOWN
  // ─────────────────────────────────────────────
  final countdown = 10.obs;
  Timer? _countdownTimer;

  void startCountdown() {
    stopCountdown();
    countdown.value = 10;
    callDropdownValue.value = ""; // navin call mate dropdown reset

    // ✅ Auto mode ma j countdown shuru thay
    if (!isAutoCallMode.value) return;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        timer.cancel();
        // ✅ Countdown 0 thay = API update + next dial
        _updateAndDialNext();
      }
    });
  }

  void stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  // ─────────────────────────────────────────────
  // LOADING
  // ─────────────────────────────────────────────
  RxBool isLoading = false.obs;
  late ApiService apiService;

  // ─────────────────────────────────────────────
  // PhoneStatusService CALL ENDS — aa call thay chhe
  // number thi queue resolve karo → name + id set karo
  // ─────────────────────────────────────────────
  void onCallEnded({required String calledNumber, required Duration duration}) {
    // Duration format
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    formattedCallLogDuration.value = "$minutes:$seconds";
    _currentDurationSeconds = duration.inSeconds;

    lastCalledNumber.value = calledNumber;

    // ✅ Queue thi name + id resolve karo
    final match = _resolveFromQueue(calledNumber);
    lastCalledName.value = match["name"] ?? "Unknown";
    _currentLeadId = match["id"] ?? "";

    print(
      "✅ onCallEnded: number=$calledNumber | name=${lastCalledName.value} | id=$_currentLeadId",
    );

    startCountdown();
  }

  // ✅ Last 10 digits compare — country code difference handle kare
  Map<String, String> _resolveFromQueue(String number) {
    if (number.isEmpty) return {};
    final normalizedInput =
        number.length >= 10 ? number.substring(number.length - 10) : number;

    try {
      return callQueue.firstWhere((e) {
        final qNum = e["number"] ?? "";
        final normalizedQueue =
            qNum.length >= 10 ? qNum.substring(qNum.length - 10) : qNum;
        return normalizedInput == normalizedQueue;
      }, orElse: () => {});
    } catch (_) {
      return {};
    }
  }

  // ─────────────────────────────────────────────
  // NEXT CALL — User manually taps button
  // ─────────────────────────────────────────────
  Future<void> onNextCallTapped() async {
    stopCountdown();
    await _updateAndDialNext();
  }

  // ✅ API update PACHHI next dial
  Future<void> _updateAndDialNext() async {
    if (_currentLeadId.isNotEmpty) {
      await updateLeadStatus(
        leadId: _currentLeadId,
        durationInSeconds: _currentDurationSeconds,
      );
    }
    _dialNextInQueue();
  }

  void _dialNextInQueue() {
    print(
      "Queue length: ${callQueue.length}, currentIndex: $currentQueueIndex",
    );

    if (currentQueueIndex >= callQueue.length) {
      // ✅ Badhi calls complete
      Get.back();
      Get.snackbar(
        "Completed",
        "All calls completed!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[400],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    final next = callQueue[currentQueueIndex];
    final number = next["number"] ?? "";
    print("➡️ Next call: ${next['name']} | $number");
    currentQueueIndex++;

    Get.back(); // dialog band karo

    if (number.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 400), () {
        makeDirectCall(number);
      });
    }
  }

  // ─────────────────────────────────────────────
  // REDIAL
  // ─────────────────────────────────────────────
  void redialLastCall() {
    final number = lastCalledNumber.value;
    if (number.isNotEmpty) {
      Get.back();
      Future.delayed(const Duration(milliseconds: 300), () {
        makeDirectCall(number);
      });
    }
  }

  // ─────────────────────────────────────────────
  // DIRECT CALL
  // ─────────────────────────────────────────────
  Future<void> makeDirectCall(String number) async {
    try {
      print("📞 Calling: $number");
      await FlutterPhoneDirectCaller.callNumber(number);
    } catch (e) {
      if (kDebugMode) print("Call error: $e");
    }
  }

  // ─────────────────────────────────────────────
  // API — LEAD STATUS UPDATE
  // ─────────────────────────────────────────────
  Future<void> updateLeadStatus({
    required String leadId,
    required int durationInSeconds,
  }) async {
    isLoading.value = true;
    try {
      final answertype =
          callDropdownValue.value.isNotEmpty
              ? callDropdownValue.value
              : "no_response";

      print(
        "📡 Updating lead: id=$leadId | duration=$durationInSeconds | type=$answertype",
      );

      CallLeadUpdateResponseEntity response = await apiService
          .callUpdateLeadById(
            type: "outgoing",
            duration: durationInSeconds,
            lead_id: leadId,
            answertype: answertype,
          );

      print("✅ Lead update: ${response.status}");
    } catch (e) {
      print("❌ Update error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────
  @override
  void onInit() {
    apiService = Get.find<ApiService>();
    super.onInit();
  }

  @override
  void onClose() {
    stopCountdown();
    super.onClose();
  }
}
