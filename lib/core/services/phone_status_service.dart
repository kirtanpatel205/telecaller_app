import 'dart:async';
import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phone_state/phone_state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telecaller_app/core/controllers/call_form_controller.dart';
import 'package:telecaller_app/core/controllers/overlay_controller.dart';
import 'package:telecaller_app/core/controllers/socket_controller.dart';
import 'package:telecaller_app/core/helpers/storage.dart';
import 'package:telecaller_app/ui/views/call_form/call_form_page.dart';
import 'package:telecaller_app/ui/views/home/overlay/overlay_pages.dart';
import 'package:telecaller_app/core/models/all_lead_entity.dart';
import 'package:telecaller_app/core/helpers/utils.dart';
import 'dart:io';

// ─────────────────────────────────────────────────────────────────────────────
// UI state machine for the call lifecycle.
//
//   IDLE  ──CALL_STARTED──▶  CALL_ACTIVE  ──CALL_ENDED──▶  SHOWING_OVERLAY
//                                                                  │
//                                               overlay closed ◀──┘  (→ IDLE)
// ─────────────────────────────────────────────────────────────────────────────
enum _CallUIState { idle, callActive, showingOverlay }

class PhoneStatusService extends GetxService with WidgetsBindingObserver {
  StreamSubscription<PhoneState>? _phoneStateSub;

  // ── Reactive state (for external observers) ───────────────────────────────
  var callStatus = "Idle".obs;
  var phoneNumber = "".obs;
  var targetPhoneNumber =
      "".obs; // New: Specific number the app is currently calling
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

  // ── Pending Overlay ──────────────────────────────────────────────────────
  bool _isOverlayPending = false;
  String _pendingOverlayNumber = "";
  Duration _pendingOverlayDuration = Duration.zero;
  String _pendingOverlaySessionId = "";

  // ── Concurrency & Event Filtering (Minimal) ──────────────────────────────
  // Removed strict locks that blocked legitimate Call End events
  int _lastEventTimestamp = 0;

  // ── Dual SIM Debounce ─────────────────────────────────────────────────────
  Timer? _debounceTimer;
  bool _isCallConfirmed = false;

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
      WidgetsBinding.instance.addObserver(this);
    }
    _startListening();

    // Listen for target number changes to track intent
    ever(targetPhoneNumber, (String number) {
      if (number.isNotEmpty) {
        print("🎯 PhoneStatusService: New dial intent stored for $number");
        _isCallConfirmed = false; // Reset confirmation for new attempt
      }
    });

    return this;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isBackground) return;

    if (state == AppLifecycleState.resumed) {
      print(
        "📱 [LIFECYCLE] App resumed. Checking for pending UI or dialer state...",
      );

      // 1. Handle pending overlay from background call
      if (_isOverlayPending) {
        print("🔔 [LIFECYCLE] App resumed with PENDING overlay. Opening now.");
        final number = _pendingOverlayNumber;
        final duration = _pendingOverlayDuration;
        final sessionId = _pendingOverlaySessionId;
        _isOverlayPending = false;
        _openOverlay(
          number: number,
          duration: duration,
          callSessionId: sessionId,
        );
      }

      handleDialerClosed();
    }
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
  // WATCHDOG: Handle case where dialer is closed/cancelled without events
  // ─────────────────────────────────────────────────────────────────────────

  void handleDialerClosed() async {
    print(
      "🏥 [WATCHDOG] Dialer closed event received. Checking if call started...",
    );

    // Give it more time for slower devices to report OFFHOOK
    await Future.delayed(const Duration(seconds: 2));

    if (_uiState == _CallUIState.idle && targetPhoneNumber.value.isNotEmpty) {
      print(
        "🚫 [WATCHDOG] Dialer closed without OFFHOOK. Emitting call-failed.",
      );
      _handleCallEnded(null); // This will trigger the cancellation/failed logic
    } else {
      print(
        "✅ [WATCHDOG] Call already started or no active dial intent. Ignoring dialer closed.",
      );
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
            phoneNumber.value = Utils.normalizePhoneNumber(state.number!);
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
    final now = DateTime.now().millisecondsSinceEpoch;

    // Throttle only if it's the EXACT same event within 200ms
    // to allow rapid START -> END transitions
    _lastEventTimestamp = now;

    print(
      "📡 [NATIVE] state=$state | number=$number | target=${targetPhoneNumber.value}",
    );

    // Safety: if we get a native state change, ensure we are ready to process it
    if (state != null) {
      callStatus.value = state;
    }

    switch (state) {
      case "RINGING":
        callStatus.value = "Incoming";
        if (number != null && number.isNotEmpty) {
          phoneNumber.value = Utils.normalizePhoneNumber(number);
        }
        break;

      case "OFFHOOK":
        print("📡 [NATIVE] OFFHOOK -> Starting call handling");
        _handleCallStarted(number);
        break;

      case "IDLE":
        print("📡 [NATIVE] IDLE -> Handling call end/cancel");
        _handleCallEnded(number);
        break;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CALL STARTED — single entry point
  // ─────────────────────────────────────────────────────────────────────────

  void _handleCallStarted(String? number) async {
    // Ignore duplicate CALL_STARTED events (stream + native can fire together)
    if (_uiState != _CallUIState.idle) {
      print("⚠️ CALL_STARTED ignored — already in state $_uiState");
      return;
    }

    try {
      _uiState = _CallUIState.callActive;
      _isCallConfirmed = false;

      if (number != null && number.isNotEmpty) {
        phoneNumber.value = Utils.normalizePhoneNumber(number);
      }

      // 🚨 SESSION ID GENERATION:
      // Generate and persist immediately so it's available for call-failed
      // if the call ends before the 2s confirmation threshold.
      _currentCallSessionId =
          _externalCallSessionId ??
          DateTime.now().millisecondsSinceEpoch.toString();
      _externalCallSessionId = null;
      await Storage.saveActiveSessionId(_currentCallSessionId!);

      print(
        "⏳ CALL_STARTED detected (Debouncing 2s): ${phoneNumber.value} | Session: $_currentCallSessionId",
      );

      // Start debounce timer to filter out SIM selection cancels
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(seconds: 2), () async {
        _isCallConfirmed = true;
        isCallActive.value = true;
        callStatus.value = "Call Started";
        _callStartTime = DateTime.now();

        print("📞 CALL_CONFIRMED: ${phoneNumber.value} | Lead: $currentLeadId");

        await _emitCallStart();

        if (!_isBackground) {
          // unawaited — runs in background, manages its own lifecycle
          _openCallForm();
        }
      });
    } catch (e) {
      print("❌ Error in _handleCallStarted: $e");
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CALL LOG — fetch actual duration after call ends
  // ─────────────────────────────────────────────────────────────────────────

  Future<Duration> _getCallDurationFromLog(String number) async {
    try {
      // CallLog read  1-2 seconds wait  (OS write
      await Future.delayed(const Duration(seconds: 2));

      final Iterable<CallLogEntry> entries = await CallLog.query(
        dateFrom:
            DateTime.now()
                .subtract(const Duration(minutes: 5))
                .millisecondsSinceEpoch,
      );

      // સૌથી recent matching entry શોધો
      for (final entry in entries) {
        final logNumber = entry.number ?? "";
        // number ના last 10 digits compare કરો
        if (logNumber.endsWith(
              number.length > 10
                  ? number.substring(number.length - 10)
                  : number,
            ) ||
            number.endsWith(
              logNumber.length > 10
                  ? logNumber.substring(logNumber.length - 10)
                  : logNumber,
            )) {
          final seconds = entry.duration ?? 0;
          print(
            "📋 CallLog found: number=$logNumber | duration=${seconds}s | type=${entry.callType}",
          );
          return Duration(seconds: seconds);
        }
      }

      print("⚠️ CallLog: no matching entry found for $number");
      return Duration.zero;
    } catch (e) {
      print("❌ CallLog error: $e");
      return Duration.zero;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CALL ENDED — single entry point
  // ─────────────────────────────────────────────────────────────────────────

  void _handleCallEnded(String? number) async {
    // 1. Cancel debounce timer immediately
    _debounceTimer?.cancel();
    _debounceTimer = null;

    // Allow processing if not idle OR if we can recover a session ID
    // OR if we were expecting a call (targetPhoneNumber is set)
    final savedSessionId = await Storage.getActiveSessionId();

    if (_uiState == _CallUIState.idle &&
        savedSessionId == null &&
        targetPhoneNumber.value.isEmpty) {
      print(
        "⚠️ CALL_ENDED ignored — no active call, no saved session, and no target number",
      );
      return;
    }

    // Already transitioning to overlay — ignore duplicate end events
    if (_uiState == _CallUIState.showingOverlay) {
      print("⚠️ CALL_ENDED ignored — overlay already open");
      return;
    }

    try {
      // 🚨 Dual SIM Cancellation Check
      if (!_isCallConfirmed) {
        print(
          "🚫 CALL_CANCELLED: Detected IDLE before 2s threshold (SIM selection cancel or failed dial)",
        );
        print(
          "🔍 Debug State: uiState=$_uiState | target=${targetPhoneNumber.value} | confirmed=$_isCallConfirmed",
        );

        final sessionId =
            _currentCallSessionId ??
            _externalCallSessionId ??
            DateTime.now().millisecondsSinceEpoch.toString();

        final endedNumber =
            targetPhoneNumber.value.isNotEmpty
                ? targetPhoneNumber.value
                : ((number != null && number.isNotEmpty)
                    ? number
                    : phoneNumber.value);

        await _emitCallFailed(
          sessionId: sessionId,
          leadContactId: currentLeadContactId ?? currentLeadId ?? "",
          callId: endedNumber,
        );

        if (Get.isRegistered<OverlayController>()) {
          Get.find<OverlayController>().handleCallCancelled();
        }
        _resetToIdle();
        return;
      }

      // ── Capture data ───────────────────────────────────────────────────────
      // Prioritize targetPhoneNumber (the one we intended to call) over
      // the dynamic phoneNumber which might have been overwritten by an incoming call.
      final endedNumber =
          targetPhoneNumber.value.isNotEmpty
              ? targetPhoneNumber.value
              : ((number != null && number.isNotEmpty)
                  ? number
                  : phoneNumber.value);

      // 🚨 RACE PROTECTION: Update state immediately before any async await
      // to block concurrent events from entering this block.
      _uiState = _CallUIState.showingOverlay;
      isCallActive.value = false;
      callStatus.value = "Call Ended";

      Duration callDuration = await _getCallDurationFromLog(endedNumber);
      _callStartTime = null;

      // Recover session ID if missing
      final sessionId = _currentCallSessionId ?? savedSessionId ?? "";
      if (_currentCallSessionId == null && savedSessionId != null) {
        print("🔄 Recovered sessionId from storage: $sessionId");
      }

      // ── Finalize reactive state ──────────────────────────────────────────
      phoneNumber.value = "";
      _currentCallSessionId = null;
      await Storage.clearActiveSessionId(); // Done with this session

      print(
        "📴 CALL_ENDED: number=$endedNumber | duration=${callDuration.inSeconds}s | Lead: $currentLeadId | session=$sessionId",
      );

      await _emitCallEnd(sessionId, callDuration, currentLeadId ?? "");

      if (!_isBackground) {
        final isFormShowing = _isFormShowing();
        print(
          "🔍 Overlay check: Get.isDialogOpen=${Get.isDialogOpen}, isFormShowing=$isFormShowing",
        );

        if (isFormShowing) {
          print("⏳ CallFormPage is open. Delaying overlay...");
          _isOverlayPending = true;
          _pendingOverlayNumber = endedNumber;
          _pendingOverlayDuration = callDuration;
          _pendingOverlaySessionId = sessionId;
        } else {
          _openOverlay(
            number: endedNumber,
            duration: callDuration,
            callSessionId: sessionId,
          );
        }
      } else {
        print("ℹ️ Background mode: no UI shown");
        _resetToIdle();
      }
    } catch (e) {
      print("❌ Error in _handleCallEnded: $e");
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

    // ✅ CRITICAL: Do NOT open UI if app is not in foreground (resumed)
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      print(
        "⏭️ [UI] App is in background. Skipping automatic CallFormPage launch.",
      );
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
    if (Get.isDialogOpen == true) {
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

      // ── Trigger pending overlay if call ended while form was open ───────
      if (_isOverlayPending) {
        print("🔔 Showing delayed post-call overlay...");
        final number = _pendingOverlayNumber;
        final duration = _pendingOverlayDuration;
        final sessionId = _pendingOverlaySessionId;

        _isOverlayPending = false; // Reset

        await _openOverlay(
          number: number,
          duration: duration,
          callSessionId: sessionId,
        );
      }
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

    // ✅ CRITICAL: Do NOT open UI if app is not in foreground (resumed)
    // Instead, mark as pending so it shows when the user manually opens the app.
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      print(
        "⏭️ [UI] App is in background. Marking overlay as PENDING for manual resume.",
      );
      _isOverlayPending = true;
      _pendingOverlayNumber = number;
      _pendingOverlayDuration = duration;
      _pendingOverlaySessionId = callSessionId;
      return;
    }

    // ── Step 1: Ensure any residual dialogs are closed ────────────────────
    if (Get.isRegistered<CallFormController>()) {
      Get.find<CallFormController>().canClose.value = true;
    }

    // Safety check: sometimes dialogs linger in GetX
    while (Get.isDialogOpen == true) {
      print("🔒 Closing lingering dialog before overlay...");
      Get.back();
      await Future.delayed(const Duration(milliseconds: 100));
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
        barrierColor: Colors.transparent,
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
    _isCallConfirmed = false;
    currentLeadId = null;
    currentFormId = null;
    currentLeadContactId = null;
    currentFormFields = [];
    targetPhoneNumber.value = ""; // Reset target tracker
    _isOverlayPending = false;

    // Also reset CallFormController if it exists
    if (Get.isRegistered<CallFormController>()) {
      Get.find<CallFormController>().resetForm();
    }

    print("🔓 PhoneStatusService: ready for next call");
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  bool _isFormShowing() {
    if (Get.isDialogOpen == true) return true;
    if (Get.isRegistered<CallFormController>()) {
      return Get.find<CallFormController>().isFormVisible.value;
    }
    return false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SOCKET — emit call-start
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _emitCallStart() async {
    try {
      if (Get.isRegistered<SocketController>()) {
        final socketCtrl = Get.find<SocketController>();

        if (_currentCallSessionId == null) {
          print(
            "⚠️ _emitCallStart: _currentCallSessionId was null, generating fallback",
          );
          _currentCallSessionId =
              DateTime.now().millisecondsSinceEpoch.toString();
          await Storage.saveActiveSessionId(_currentCallSessionId!);
        }

        await socketCtrl.emitCallStart(
          callSessionId: _currentCallSessionId!,
          leadContactId: currentLeadContactId ?? currentLeadId ?? "",
          callId: Utils.normalizePhoneNumber(phoneNumber.value),
        );
        print("📤 Socket: call-start emitted | session=$_currentCallSessionId");
      }
    } catch (e) {
      print("❌ Socket emitCallStart error: $e");
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SOCKET — emit call-end
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _emitCallEnd(
    String sessionId,
    Duration duration,
    String leadId,
  ) async {
    try {
      if (Get.isRegistered<SocketController>()) {
        final socketCtrl = Get.find<SocketController>();

        final answerType = duration.inSeconds > 0 ? "completed" : "failed";

        await socketCtrl.emitCallEnd(
          callSessionId: sessionId,
          leadContactId: currentLeadContactId ?? leadId,
          duration: duration.inSeconds,
          answerType: answerType,
          answer: "",
        );
        print(
          "📤 Socket: call-end emitted | lead=${currentLeadContactId ?? leadId} | session=$sessionId",
        );
      }
    } catch (e) {
      print("❌ Socket emitCallEnd error: $e");
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SOCKET — emit call-failed (for Dual SIM cancel)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _emitCallFailed({
    required String sessionId,
    required String leadContactId,
    required String callId,
  }) async {
    try {
      print(
        "📤 Socket: Emitting call-failed | Session: $sessionId | Lead: $leadContactId | CallId: $callId",
      );
      if (Get.isRegistered<SocketController>()) {
        final socketCtrl = Get.find<SocketController>();
        await socketCtrl.emitCallFailed(
          callSessionId: sessionId,
          leadContactId: leadContactId,
          callId: Utils.normalizePhoneNumber(callId),
        );
        print("✅ Socket: call-failed emitted successfully");
      }
    } catch (e) {
      print("❌ Socket: Failed to emit call-failed: $e");
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void onClose() {
    if (!_isBackground) {
      WidgetsBinding.instance.removeObserver(this);
    }
    _phoneStateSub?.cancel();
    super.onClose();
  }
}
