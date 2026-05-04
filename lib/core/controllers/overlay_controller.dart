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

class OverlayController extends GetxController {
  // ─────────────────────────────────────────────
  // AUTO-DIALER STATE
  // ─────────────────────────────────────────────
  final isPreCallMode = false.obs;
  final lastUpdateEvent = Rxn<Map<String, String>>();
  
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

  int totalInQueue() => callQueue.length;

  // ─────────────────────────────────────────────
  // DROPDOWN / RESCHEDULE
  // ─────────────────────────────────────────────
  RxString callDropdownValue = "".obs;

  final List<Map<String, String>> leadOptions = [
    {"label": "interested", "value": "interested"},
    {"label": "not_interested", "value": "not_interested"},
    {"label": "reschedule", "value": "scheduled"},
    {"label": "follow-up", "value": "follow_up"},
    {"label": "invalid", "value": "invalid"},
    {"label": "no_response", "value": "no_response"},
    {"label": "other", "value": "other"},
  ];

  void onDropdownChange(String value) {
    callDropdownValue.value = value;
    stopCountdown(); // Stop timer completely when a selection is made
    print("🛑 Timer stopped due to selection: $value");
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

  // Internal state for countdown
  bool _isPreCallInternal = false;

  void startCountdown({int seconds = 10, bool isPreCall = false}) {
    // Cancel any existing timer, but DO NOT call stopCountdown() 
    // because that resets isAutoCallMode to false!
    _countdownTimer?.cancel();
    _countdownTimer = null;
    
    _isPreCallInternal = isPreCall;
    isPreCallMode.value = isPreCall;
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
        if (_isPreCallInternal) {
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
    
    // If the timer was stopped (e.g. after a cancellation), restart it
    if (_countdownTimer == null && isAutoCallMode.value) {
      if (countdown.value > 0) {
        startCountdown(seconds: countdown.value, isPreCall: _isPreCallInternal);
      } else {
        // If countdown reached 0, treat as a fresh pre-call start
        _prepareNextCall();
      }
    }
  }

  void stopCountdown() {
    print("🛑 Auto-dialer Stopped");
    _countdownTimer?.cancel();
    _countdownTimer = null;
    isPaused.value = false;
    isAutoCallMode.value = false; // Reset auto-dialer mode
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
    // currentQueueIndex points to the lead that JUST finished.
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
    
    // Force auto-call mode true so the timer/call can proceed
    isAutoCallMode.value = true;
    
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

    if (currentQueueIndex.value + 1 >= callQueue.length) {
      // ✅ Badhi calls complete
      _finishQueue();
      return;
    }

    // Move to next index
    currentQueueIndex.value++;

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
    final next = callQueue[currentQueueIndex.value];
    final number = next["number"] ?? "";
    print("➡️ Next call: ${next['name']} | $number");
    
    // Set IDs for socket/APIs
    currentLeadId = next["id"] ?? "";
    currentLeadContactId = next["leadContactId"] ?? "";

    // ── SYNC: Update PhoneStatusService for the next dial ─────────────────
    if (Get.isRegistered<PhoneStatusService>()) {
      final ps = Get.find<PhoneStatusService>();
      ps.currentLeadId = next["id"];
      ps.currentLeadContactId = next["leadContactId"];
      ps.targetPhoneNumber.value = number;
      
      // Restore form metadata from AutoDialerController if available
      try {
        final dynamic ad = Get.find(tag: 'AutoDialerController'); // if using tag
        // If not using tag, we have to be careful. 
        // The best way is for AutoDialerController to push this data to PhoneStatusService itself.
      } catch (e) {}
      
      print("🔄 Overlay Sync: Lead=${ps.currentLeadId} | Contact=${ps.currentLeadContactId} | Form=${ps.currentFormId}");
    }

    // Sync with background service
    FlutterBackgroundService().invoke('set_lead_info', {
      'leadId': currentLeadId,
      'leadContactId': currentLeadContactId,
      'phoneNumber': number,
    });

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

    // Sync metadata for the redial session
    FlutterBackgroundService().invoke('set_lead_info', {
      'leadId': currentLeadId,
      'leadContactId': currentLeadContactId,
      'phoneNumber': number,
    });

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
            schedule_at: answertype == "scheduled" ? rescheduleDate.value : "",
          );

      print("✅ Lead log update: ${response.status}");
      
      // ✅ Update Local State via Event (listened to by AutoDialerController)
      lastUpdateEvent.value = {
        'contactId': currentLeadContactId,
        'status': answertype,
      };
      lastUpdateEvent.refresh();

      // 📤 Emit Socket Call End with actual disposition
      try {
        if (Get.isRegistered<SocketController>()) {
          await Get.find<SocketController>().emitCallEnd(
            callSessionId: currentCallSessionId,
            leadContactId: currentLeadContactId, // 🎯 USE CONTACT ID HERE
            duration: durationInSeconds,
            answerType: answertype,
            answer: answertype == "scheduled" ? "Scheduled at ${rescheduleDate.value}" : "", // Optional answer text if needed
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

  // ─────────────────────────────────────────────
  // CALL CANCELLED — Rollback queue
  // ─────────────────────────────────────────────
  void handleCallCancelled() {
    print("🚫 handleCallCancelled: Resetting autodialer state");
    
    if (isAutoCallMode.value) {
      // Index already points to the current lead being attempted, no need to rollback
      // as it will stay on the same lead for retry/resume.
      _countdownTimer?.cancel();
      _countdownTimer = null;
      isPaused.value = true;
    } else {
      stopCountdown();
    }

    Get.snackbar(
      "Call Cancelled",
      "SIM selection was cancelled. Autodialer paused.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange[400],
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void onClose() {
    stopCountdown();
    super.onClose();
  }
}
