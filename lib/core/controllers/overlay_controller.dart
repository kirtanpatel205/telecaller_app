import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:telecaller_app/core/controllers/socket_controller.dart';
import 'package:telecaller_app/core/models/call_lead_update_response_entity.dart';
import 'package:telecaller_app/core/services/api_service.dart';
import 'package:telecaller_app/core/services/phone_status_service.dart';
import 'package:telecaller_app/ui/views/auto_dialer/autodialer_controller.dart';

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
  final currentQueueIndex = 0.obs;
  RxBool isAutoCallMode = false.obs;

  Map<String, String>? get nextLead {
    if (callQueue.isEmpty || currentQueueIndex.value >= callQueue.length) return null;
    return callQueue[currentQueueIndex.value];
  }

  // Current lead info for API update
  String currentLeadId = "";
  String currentLeadContactId = "";
  String currentCallSessionId = "";
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
    pauseCountdown(); // Ensure it pauses when a selection is made
    print("⏸️ Timer paused due to selection: $value");
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
      pauseCountdown(); // Stop timer if user is rescheduling
      rescheduleDate.value =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  // ─────────────────────────────────────────────
  // COUNTDOWN
  // ─────────────────────────────────────────────
  final countdown = 10.obs;
  final isPaused = false.obs;
  Timer? _countdownTimer;

  // States for countdown
  bool _isPreCallMode = false;

  void startCountdown({int seconds = 10, bool isPreCall = false}) {
    stopCountdown();
    _isPreCallMode = isPreCall;
    isPaused.value = false;
    countdown.value = seconds;

    if (!isPreCall) {
      callDropdownValue.value = ""; // navin call mate dropdown reset
    }

    // ✅ Auto mode ma j countdown shuru thay
    if (!isAutoCallMode.value) return;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isPaused.value) return; // Wait if paused

      if (countdown.value > 0) {
        countdown.value--;
      } else {
        timer.cancel();
        if (_isPreCallMode) {
          _actuallyDialNext();
        } else {
          // ✅ Countdown 0 thay = API update + next dial
          _updateAndDialNext();
        }
      }
    });
  }

  void pauseCountdown() {
    print("⏸️ Auto-dialer Paused");
    isPaused.value = true;
  }

  void resumeCountdown() {
    print("▶️ Auto-dialer Resumed");
    isPaused.value = false;
  }

  void stopCountdown() {
    print("🛑 Auto-dialer Stopped");
    _countdownTimer?.cancel();
    _countdownTimer = null;
    isPaused.value = false;
    countdown.value = 0;
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
  void onCallEnded({
    required String calledNumber,
    required Duration duration,
    required String callSessionId,
  }) {
    // Duration format
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    formattedCallLogDuration.value = "$minutes:$seconds";
    _currentDurationSeconds = duration.inSeconds;

    lastCalledNumber.value = calledNumber;
    currentCallSessionId = callSessionId;

    // ✅ Sync: Pre-resolve from PhoneStatusService if available
    if (Get.isRegistered<PhoneStatusService>()) {
      final ps = Get.find<PhoneStatusService>();
      final psContactId = ps.currentLeadContactId;

      if (psContactId != null && psContactId.isNotEmpty) {
        final match = callQueue.firstWhereOrNull((e) => e["leadContactId"] == psContactId);
        if (match != null) {
          lastCalledName.value = match["name"] ?? "Unknown";
          currentLeadId = match["id"] ?? "";
          currentLeadContactId = match["leadContactId"] ?? psContactId;
          print("🎯 Resolve: Used PhoneStatusService ContactId match");
        }
      }
    }

    // ✅ Fallback: Resolve from queue by number
    if (lastCalledName.value == "No previous call" || lastCalledName.value == "Unknown") {
      final match = _resolveFromQueue(calledNumber);
      lastCalledName.value = match["name"] ?? "Unknown";
      currentLeadId = match["id"] ?? "";
      currentLeadContactId = match["leadContactId"] ?? "";
      print("🎯 Resolve: Used Number lookup fallback");
    }

    print(
      "✅ onCallEnded: number=$calledNumber | name=${lastCalledName.value} | id=$currentLeadId",
    );

    // After call ends, overlay shows up.
    // currentQueueIndex is already pointing to the NEXT person.
    startCountdown(seconds: 10, isPreCall: false);
  }

  String _currentLeadIdInternal = "";

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
    // Resume/Stop the overlay countdown and move to pre-call phase
    _countdownTimer?.cancel();
    _countdownTimer = null;
    await _updateAndDialNext();
  }

  // ✅ API update PACHHI next dial prepare karo
  Future<void> _updateAndDialNext() async {
    if (currentLeadId.isNotEmpty) {
      await updateLeadStatus(
        leadId: currentLeadId,
        durationInSeconds: _currentDurationSeconds,
      );
    }
    _prepareNextCall();
  }

  void _prepareNextCall() {
    print(
      "Queue length: ${callQueue.length}, currentIndex: ${currentQueueIndex.value}",
    );

    if (currentQueueIndex.value >= callQueue.length) {
      // ✅ Badhi calls complete
      _finishQueue();
      return;
    }

    // Close overlay first
    if (Get.isOverlaysOpen) {
      Get.back();
    }

    // Start 5s pre-call countdown
    print("⏳ Starting 5s pre-call countdown...");
    // Force reset countdown to 5 and start it
    countdown.value = 5;
    startCountdown(seconds: 5, isPreCall: true);
  }

  void _actuallyDialNext() {
    if (currentQueueIndex.value >= callQueue.length) {
      _finishQueue();
      return;
    }

    final next = callQueue[currentQueueIndex.value];
    final number = next["number"] ?? "";
    print("➡️ Next call: ${next['name']} | $number");

    currentQueueIndex.value++;
    
    // Set IDs for socket/APIs
    currentLeadId = next["id"] ?? "";
    currentLeadContactId = next["leadContactId"] ?? "";

    // ── SYNC: Update PhoneStatusService for the next dial ─────────────────
    if (Get.isRegistered<PhoneStatusService>()) {
      final ps = Get.find<PhoneStatusService>();
      ps.currentLeadId = next["id"];
      ps.currentLeadContactId = next["leadContactId"];
      
      // Restore form metadata from AutoDialerController if available
      if (Get.isRegistered<AutoDialerController>()) {
        final ad = Get.find<AutoDialerController>();
        final dataset = ad.selectedLeadDataset.value;
        if (dataset != null) {
          ps.currentFormId = dataset.formId?.id ?? "";
          ps.currentFormFields = dataset.formId?.fields ?? [];
        }
      }
      
      print("🔄 Overlay Sync: Lead=${ps.currentLeadId} | Contact=${ps.currentLeadContactId} | Form=${ps.currentFormId}");
    }

    // Sync with background service
    FlutterBackgroundService().invoke('set_lead_info', {'leadId': currentLeadId});

    if (number.isNotEmpty) {
      makeDirectCall(number);
    }
  }

  void _finishQueue() {
    isAutoCallMode.value = false;
    stopCountdown();
    if (Get.isOverlaysOpen) {
      Get.back();
    }
    Get.snackbar(
      "Completed",
      "All calls completed!",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green[400],
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  // ─────────────────────────────────────────────
  // REDIAL
  // ─────────────────────────────────────────────
  void redialLastCall() {
    stopCountdown(); // Stop auto-progression on manual redial
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
        "📡 Updating lead log: id=$currentLeadContactId | duration=$durationInSeconds | type=$answertype",
      );

      CallLeadUpdateResponseEntity response = await apiService
          .callUpdateLeadById(
            type: "outgoing",
            duration: durationInSeconds,
            lead_id: currentLeadContactId, // 🎯 USE CONTACT ID HERE
            answertype: answertype,
          );

      print("✅ Lead log update: ${response.status}");

      // 📤 Emit Socket Call End with actual disposition
      try {
        if (Get.isRegistered<SocketController>()) {
          await Get.find<SocketController>().emitCallEnd(
            callSessionId: currentCallSessionId,
            leadContactId: currentLeadContactId, // 🎯 USE CONTACT ID HERE
            duration: durationInSeconds,
            answerType: answertype,
            answer: "", // Optional answer text if needed
          );
          print("📤 Socket: final call-end emitted with answerType: $answertype");
        }
      } catch (e) {
        print("❌ Socket emitCallEnd error: $e");
      }
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
