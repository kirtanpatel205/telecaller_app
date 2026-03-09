import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phone_state/phone_state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telecaller_app/core/controllers/overlay_controller.dart';
import 'package:telecaller_app/core/controllers/socket_controller.dart';
import 'package:telecaller_app/ui/views/home/overlay/overlay_pages.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'dart:io';

class PhoneStatusService extends GetxService {
  StreamSubscription<PhoneState>? _phoneStateSub;

  var callStatus = "Idle".obs;
  var phoneNumber = "".obs;
  var isCallActive = false.obs;

  // ✅ Background flag to avoid UI calls in isolate
  bool _isBackground = false;

  String? _currentCallSessionId;
  String? currentLeadId;

  DateTime? _callStartTime;
  bool _dialogOpen = false;
  bool _callEndedProcessed = false;

  String? _externalCallSessionId;

  // ✅ App start pachhi actually call started thayo ke nahi
  // Jyare CALL_STARTED aave tyare true thay
  // Aa false hoy to CALL_ENDED ignore karo (app start fake event)
  bool _callWasStarted = false;

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

  void _startListening() async {
    final hasPermission = await Permission.phone.isGranted;
    print("📋 PhoneStatusService: Checking phone permission: $hasPermission");

    // In background isolates, we'll try to listen regardless of what the permission check says,
    // as it can sometimes be unreliable in separate isolates, and the main app already has it.
    if (!hasPermission && !_isBackground) {
      print("🚫 Permission not granted, not listening (foreground).");
      return;
    }

    _phoneStateSub = PhoneState.stream.listen((PhoneState state) async {
      final prefix = _isBackground ? "🔔 [BG EVENT]" : "🔔 [EVENT]";
      print(
        "$prefix PhoneState: ${state.status} | number: ${state.number}",
      );

      switch (state.status) {
        case PhoneStateStatus.CALL_INCOMING:
          callStatus.value = "Incoming";
          print("📞 Incoming call detected: ${state.number}");
          if (state.number != null && state.number!.isNotEmpty) {
            phoneNumber.value = state.number!;
          }
          break;

        case PhoneStateStatus.CALL_STARTED:
          isCallActive.value = true;
          callStatus.value = "Call Started";
          _callEndedProcessed = false;
          _callWasStarted = true; // ✅ Real call started

          if (_callStartTime == null) {
            _callStartTime = DateTime.now();
          }

          if (state.number != null && state.number!.isNotEmpty) {
            phoneNumber.value = state.number!;
          }

          print("📞 CALL_STARTED: ${phoneNumber.value} | Lead: $currentLeadId");

          // Emit Socket Call Start
          _emitCallStart();
          break;

        case PhoneStateStatus.CALL_ENDED:
          if (!_callWasStarted) {
            print(
              "🚫 CALL_ENDED ignored — no CALL_STARTED before this (app start fake event)",
            );
            return;
          }

          if (_callEndedProcessed) {
            print("🔄 CALL_ENDED already processed, skip");
            return;
          }
          _callEndedProcessed = true;
          _callWasStarted = false;

          isCallActive.value = false;
          callStatus.value = "Call Ended";

          final endedNumber =
              (state.number != null && state.number!.isNotEmpty)
                  ? state.number!
                  : phoneNumber.value;

          Duration callDuration = Duration.zero;
          if (_callStartTime != null) {
            callDuration = DateTime.now().difference(_callStartTime!);
            _callStartTime = null;
          }

          print(
            "📴 CALL_ENDED: number=$endedNumber | duration=${callDuration.inSeconds}s | Lead: $currentLeadId",
          );

          phoneNumber.value = "";

          // Capture session ID before clearing for the overlay
          final sessionIdForOverlay = _currentCallSessionId ?? "";

          // Emit Socket Call End
          _emitCallEnd(sessionIdForOverlay, callDuration);

          // Only show overlay if we are NOT in the background isolate
          if (!_isBackground) {
            _showOverlayAfterCall(
              number: endedNumber, 
              duration: callDuration,
              callSessionId: sessionIdForOverlay,
            );
          } else {
            print("ℹ️ Background mode: No overlay/ui shown");
            _callEndedProcessed = false; // Reset for next call in background
          }
          break;

        default:
          if (callStatus.value != "Idle") {
            callStatus.value = "Idle";
            _callEndedProcessed = false;
          }
      }
    });
  }

  /// ✅ Handle native events from PhoneStateReceiver (via BackgroundServiceManager)
  void handleNativeEvent({String? state, String? number}) {
    final prefix = "📡 [NATIVE EVENT]";
    print("$prefix PhoneState: $state | number: $number");

    if (state == null) return;

    switch (state) {
      case "RINGING":
        callStatus.value = "Incoming";
        if (number != null && number.isNotEmpty) {
          phoneNumber.value = number;
        }
        break;

      case "OFFHOOK":
        // This maps to CALL_STARTED
        if (_callEndedProcessed) {
           _callEndedProcessed = false;
        }
        isCallActive.value = true;
        callStatus.value = "Call Started";
        _callWasStarted = true;

        if (_callStartTime == null) {
          _callStartTime = DateTime.now();
        }

        if (number != null && number.isNotEmpty) {
          phoneNumber.value = number;
        }

        print("📞 NATIVE CALL_STARTED: ${phoneNumber.value} | Lead: $currentLeadId");

        // Emit Socket Call Start
        _emitCallStart();
        break;

      case "IDLE":
        // This maps to CALL_ENDED
        if (!_callWasStarted) {
          print("$prefix IDLE ignored — no call was started");
          return;
        }

        if (_callEndedProcessed) {
          print("$prefix IDLE already processed, skip");
          return;
        }
        _callEndedProcessed = true;
        _callWasStarted = false;

        isCallActive.value = false;
        callStatus.value = "Call Ended";

        final endedNumber = (number != null && number.isNotEmpty) ? number : phoneNumber.value;

        Duration callDuration = Duration.zero;
        if (_callStartTime != null) {
          callDuration = DateTime.now().difference(_callStartTime!);
          _callStartTime = null;
        }

        print("📴 NATIVE CALL_ENDED: number=$endedNumber | duration=${callDuration.inSeconds}s | Lead: $currentLeadId");

        final sessionIdForOverlay = _currentCallSessionId ?? "";
        
        // Emit Socket Call End
        _emitCallEnd(sessionIdForOverlay, callDuration);

        phoneNumber.value = "";
        _currentCallSessionId = null;

        if (!_isBackground) {
           _showOverlayAfterCall(
              number: endedNumber, 
              duration: callDuration,
              callSessionId: sessionIdForOverlay,
            );
        } else {
           _callEndedProcessed = false; // Reset for next call
        }
        break;
    }
  }

  void _emitCallStart() async {

    try {
      if (Get.isRegistered<SocketController>()) {
        final SocketController socketCtrl = Get.find<SocketController>();
        _currentCallSessionId = _externalCallSessionId ?? DateTime.now().millisecondsSinceEpoch.toString();
        _externalCallSessionId = null;

        await socketCtrl.emitCallStart(
          callSessionId: _currentCallSessionId!,
          leadContactId: currentLeadId ?? "",
          callId: "",
        );
        final prefix = _isBackground ? "📤 [BG Socket]" : "📤 Socket";
        print("$prefix: call-start emitted with session: $_currentCallSessionId");
      }
    } catch (e) {
      print("❌ Socket emitCallStart error: $e");
    }
  }

  void _emitCallEnd(String sessionId, Duration duration) async {
    try {
      if (Get.isRegistered<SocketController>()) {
        final SocketController socketCtrl = Get.find<SocketController>();
        await socketCtrl.emitCallEnd(
          callSessionId: sessionId,
          leadContactId: currentLeadId ?? "",
          duration: duration.inSeconds,
          answerType: "completed",
          answer: "",
        );
        final prefix = _isBackground ? "📤 [BG Socket]" : "📤 Socket";
        print("$prefix: call-end emitted for lead $currentLeadId");
      }
    } catch (e) {
      print("❌ Socket emitCallEnd error: $e");
    }
  }

  Future<void> _showOverlayAfterCall({
    required String number,
    required Duration duration,
    required String callSessionId,
  }) async {
    if (_dialogOpen) {
      print("⚠️ Dialog already open — skip");
      return;
    }

    print("⏳ Waiting 900ms...");
    await Future.delayed(const Duration(milliseconds: 900));

    try {
      if (Get.isRegistered<OverlayController>()) {
        Get.find<OverlayController>().onCallEnded(
          calledNumber: number,
          duration: duration,
          callSessionId: callSessionId,
        );
      } else {
        Get.put(
          OverlayController(),
        ).onCallEnded(
          calledNumber: number, 
          duration: duration, 
          callSessionId: callSessionId
        );
      }
    } catch (e) {
      print("❌ OverlayController error: $e");
      return;
    }

    if (Get.context == null) {
      print("❌ Get.context is NULL");
      return;
    }

    print("✅ Opening dialog...");
    _dialogOpen = true;

    try {
      await Get.dialog(
        OverlayPages(),
        barrierDismissible: false,
        barrierColor: Colors.black54,
      );
      print("✅ Dialog closed");
    } catch (e) {
      print("❌ Dialog error: $e");
    } finally {
      _dialogOpen = false;
      _callEndedProcessed = false;
      print("🔓 Ready for next call");
    }
  }

  @override
  void onClose() {
    _phoneStateSub?.cancel();
    super.onClose();
  }
}
