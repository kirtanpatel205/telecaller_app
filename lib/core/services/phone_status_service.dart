import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phone_state/phone_state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telecaller_app/core/controllers/call_form_controller.dart';
import 'package:telecaller_app/core/controllers/overlay_controller.dart';
import 'package:telecaller_app/core/controllers/socket_controller.dart';
import 'package:telecaller_app/ui/views/call_form/call_form_page.dart';
import 'package:telecaller_app/ui/views/home/overlay/overlay_pages.dart';
import 'package:telecaller_app/core/models/all_lead_entity.dart';
import 'dart:io';

// ─────────────────────────────────────────────────────────────────────────────
// UI state machine for the call lifecycle.
//
//   IDLE  ──CALL_STARTED──▶  CALL_ACTIVE  ──CALL_ENDED──▶  SHOWING_OVERLAY
//                                                                  │
//                                               overlay closed ◀──┘  (→ IDLE)
// ─────────────────────────────────────────────────────────────────────────────
enum _CallUIState { idle, callActive, showingOverlay }

class PhoneStatusService extends GetxService {
  StreamSubscription<PhoneState>? _phoneStateSub;

  // ── Reactive state (for external observers) ───────────────────────────────
  var callStatus = "Idle".obs;
  var phoneNumber = "".obs;
  var isCallActive = false.obs;

  // ── Background flag ───────────────────────────────────────────────────────
  bool _isBackground = false;

  // ── Call session ──────────────────────────────────────────────────────────
  String? _currentCallSessionId;
  String? _externalCallSessionId;
  String? currentLeadId;
  String? currentFormId;
  String? currentLeadContactId;
  List<AllLeadLeadsFormIdFields> currentFormFields = [];

  // ── Timing ────────────────────────────────────────────────────────────────
  DateTime? _callStartTime;

  // ── UI state machine ──────────────────────────────────────────────────────
  _CallUIState _uiState = _CallUIState.idle;

  // ─────────────────────────────────────────────────────────────────────────
  // PUBLIC API
  // ─────────────────────────────────────────────────────────────────────────

  void setExternalCallSessionId(String? sessionId) {
    _externalCallSessionId = sessionId;
    print("📞 External callSessionId set: $_externalCallSessionId");
  }

  Future<PhoneStatusService> init({bool isBackground = false}) async {
    _isBackground = isBackground;
    if (!_isBackground) {
      await _checkAndRequestPermissions();
    }
    _startListening();
    return this;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PERMISSIONS
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _checkAndRequestPermissions() async {
    PermissionStatus status = await Permission.phone.status;
    if (!status.isGranted) {
      status = await Permission.phone.request();
      if (!status.isGranted) {
        callStatus.value = "Permission Denied";
        return;
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PHONE STATE STREAM — flutter phone_state package
  // ─────────────────────────────────────────────────────────────────────────

  void _startListening() async {
    final hasPermission = await Permission.phone.isGranted;
    print("📋 PhoneStatusService: phone permission=$hasPermission");

    if (!hasPermission && !_isBackground) {
      print("🚫 Permission not granted, not listening (foreground).");
      return;
    }

    _phoneStateSub = PhoneState.stream.listen((PhoneState state) {
      final prefix = _isBackground ? "🔔 [BG]" : "🔔";
      print("$prefix PhoneState: ${state.status} | number: ${state.number}");

      switch (state.status) {
        case PhoneStateStatus.CALL_INCOMING:
          callStatus.value = "Incoming";
          if (state.number != null && state.number!.isNotEmpty) {
            phoneNumber.value = state.number!;
          }
          break;

        case PhoneStateStatus.CALL_STARTED:
          _handleCallStarted(state.number);
          break;

        case PhoneStateStatus.CALL_ENDED:
          _handleCallEnded(state.number);
          break;

        default:
          callStatus.value = "Idle";
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // NATIVE EVENTS — from BackgroundServiceManager / PhoneStateReceiver
  // ─────────────────────────────────────────────────────────────────────────

  void handleNativeEvent({String? state, String? number}) {
    print("📡 [NATIVE] state=$state | number=$number");
    if (state == null) return;

    switch (state) {
      case "RINGING":
        callStatus.value = "Incoming";
        if (number != null && number.isNotEmpty) {
          phoneNumber.value = number;
        }
        break;

      case "OFFHOOK":
        _handleCallStarted(number);
        break;

      case "IDLE":
        _handleCallEnded(number);
        break;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CALL STARTED — single entry point
  // ─────────────────────────────────────────────────────────────────────────

  void _handleCallStarted(String? number) {
    // Ignore duplicate CALL_STARTED events (stream + native can fire together)
    if (_uiState != _CallUIState.idle) {
      print("⚠️ CALL_STARTED ignored — already in state $_uiState");
      return;
    }

    _uiState = _CallUIState.callActive;
    isCallActive.value = true;
    callStatus.value = "Call Started";
    _callStartTime = DateTime.now();

    if (number != null && number.isNotEmpty) {
      phoneNumber.value = number;
    }

    print("📞 CALL_STARTED: ${phoneNumber.value} | Lead: $currentLeadId");

    _emitCallStart();

    if (!_isBackground) {
      // unawaited — runs in background, manages its own lifecycle
      _openCallForm();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CALL ENDED — single entry point
  // ─────────────────────────────────────────────────────────────────────────

  void _handleCallEnded(String? number) {
    // Only process if a call was actually started
    if (_uiState == _CallUIState.idle) {
      print("⚠️ CALL_ENDED ignored — no active call (idle state)");
      return;
    }

    // Already transitioning to overlay — ignore duplicate end events
    if (_uiState == _CallUIState.showingOverlay) {
      print("⚠️ CALL_ENDED ignored — overlay already open");
      return;
    }

    // ── Capture data ───────────────────────────────────────────────────────
    final endedNumber = (number != null && number.isNotEmpty)
        ? number
        : phoneNumber.value;

    Duration callDuration = Duration.zero;
    if (_callStartTime != null) {
      callDuration = DateTime.now().difference(_callStartTime!);
      _callStartTime = null;
    }

    final sessionId = _currentCallSessionId ?? "";

    // ── Update reactive state ──────────────────────────────────────────────
    _uiState = _CallUIState.showingOverlay;
    isCallActive.value = false;
    callStatus.value = "Call Ended";
    phoneNumber.value = "";
    _currentCallSessionId = null;

    print(
      "📴 CALL_ENDED: number=$endedNumber | duration=${callDuration.inSeconds}s | Lead: $currentLeadId | session=$sessionId",
    );

    _emitCallEnd(sessionId, callDuration);

    if (!_isBackground) {
      // unawaited — manages its own lifecycle
      _openOverlay(
        number: endedNumber,
        duration: callDuration,
        callSessionId: sessionId,
      );
    } else {
      print("ℹ️ Background mode: no UI shown");
      _resetToIdle();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // OPEN CALL FORM (shown while call is active)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _openCallForm() async {
    if (Get.context == null) {
      print("❌ context is NULL — cannot show CallFormPage");
      return;
    }

    // Brief delay so the native phone dialer surfaces first
    await Future.delayed(const Duration(milliseconds: 500));

    // If call already ended during the delay, skip opening the form.
    if (_uiState != _CallUIState.callActive) {
      print("⚠️ Call ended during delay — skipping CallFormPage");
      return;
    }

    // If a dialog is already open (e.g. from AutoDialerController), don't open another one
    if (Get.isDialogOpen ?? false) {
      print("ℹ️ Dialog already open, skipping redundant _openCallForm");
      return;
    }

    print("✅ Opening CallFormPage via PhoneStatusService...");
    try {
      // Show form using synced metadata (populated by AutoDialer or defaults)
      await CallFormController.show(
        formid: currentFormId ?? "",
        leadId: currentLeadId ?? "",
        leadContactId: currentLeadContactId ?? "",
        formFields: currentFormFields,
        showUI: true,
      );
      print("✅ CallFormPage closed");
    } catch (e) {
      print("❌ CallFormPage error: $e");
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // OPEN OVERLAY (shown after call ends)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _openOverlay({
    required String number,
    required Duration duration,
    required String callSessionId,
  }) async {
    if (Get.context == null) {
      print("❌ context is NULL — cannot show OverlayPages");
      _resetToIdle();
      return;
    }

    // ── Step 1: Close CallFormPage if it is currently open ─────────────────
    if (Get.isDialogOpen ?? false) {
      print("🔒 Closing CallFormPage before showing overlay...");
      Get.back();
      // Allow the pop animation to complete
      await Future.delayed(const Duration(milliseconds: 350));
    }

    // ── Step 2: Short pause so the screen settles ──────────────────────────
    await Future.delayed(const Duration(milliseconds: 300));

    // ── Step 3: Notify OverlayController about the ended call ──────────────
    try {
      if (!Get.isRegistered<OverlayController>()) {
        Get.put(OverlayController());
      }
      Get.find<OverlayController>().onCallEnded(
        calledNumber: number,
        duration: duration,
        callSessionId: callSessionId,
      );
    } catch (e) {
      print("❌ OverlayController.onCallEnded error: $e");
      _resetToIdle();
      return;
    }

    // ── Step 4: Show the overlay ───────────────────────────────────────────
    print("✅ Opening OverlayPages...");
    try {
      await Get.dialog(
        OverlayPages(),
        barrierDismissible: false,
        barrierColor: Colors.black54,
      );
      print("✅ OverlayPages closed");
    } catch (e) {
      print("❌ OverlayPages error: $e");
    } finally {
      _resetToIdle();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // RESET — called after overlay closes, ready for the next call
  // ─────────────────────────────────────────────────────────────────────────

  void _resetToIdle() {
    _uiState = _CallUIState.idle;
    currentLeadId = null;
    currentFormId = null;
    currentLeadContactId = null;
    currentFormFields = [];

    // Also reset CallFormController if it exists
    if (Get.isRegistered<CallFormController>()) {
      Get.find<CallFormController>().resetForm();
    }

    print("🔓 PhoneStatusService: ready for next call");
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SOCKET — emit call-start
  // ─────────────────────────────────────────────────────────────────────────

  void _emitCallStart() async {
    try {
      if (Get.isRegistered<SocketController>()) {
        final socketCtrl = Get.find<SocketController>();
        _currentCallSessionId = _externalCallSessionId ??
            DateTime.now().millisecondsSinceEpoch.toString();
        _externalCallSessionId = null;

        await socketCtrl.emitCallStart(
          callSessionId: _currentCallSessionId!,
          leadContactId: currentLeadId ?? "",
          callId: "",
        );
        print(
          "📤 Socket: call-start emitted | session=$_currentCallSessionId",
        );
      }
    } catch (e) {
      print("❌ Socket emitCallStart error: $e");
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SOCKET — emit call-end
  // ─────────────────────────────────────────────────────────────────────────

  void _emitCallEnd(String sessionId, Duration duration) async {
    try {
      if (Get.isRegistered<SocketController>()) {
        final socketCtrl = Get.find<SocketController>();
        await socketCtrl.emitCallEnd(
          callSessionId: sessionId,
          leadContactId: currentLeadId ?? "",
          duration: duration.inSeconds,
          answerType: "completed",
          answer: "",
        );
        print(
          "📤 Socket: call-end emitted | lead=$currentLeadId | session=$sessionId",
        );
      }
    } catch (e) {
      print("❌ Socket emitCallEnd error: $e");
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void onClose() {
    _phoneStateSub?.cancel();
    super.onClose();
  }
}
