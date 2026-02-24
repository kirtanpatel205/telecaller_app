import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phone_state/phone_state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telecaller_app/core/controllers/overlay_controller.dart';
import 'package:telecaller_app/ui/views/home/overlay/overlay_pages.dart';

class PhoneStatusService extends GetxService {
  StreamSubscription<PhoneState>? _phoneStateSub;

  var callStatus = "Idle".obs;
  var phoneNumber = "".obs;
  var isCallActive = false.obs;


  DateTime? _callStartTime;
  bool _dialogOpen = false;
  bool _callEndedProcessed = false;

  // ✅ App start pachhi actually call started thayo ke nahi
  // Jyare CALL_STARTED aave tyare true thay
  // Aa false hoy to CALL_ENDED ignore karo (app start fake event)
  bool _callWasStarted = false;

  Future<PhoneStatusService> init() async {
    await _checkAndRequestPermissions();
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
    if (!await Permission.phone.isGranted) return;

    _phoneStateSub = PhoneState.stream.listen((PhoneState state) {
      print("🔔 PhoneState: ${state.status} | number: ${state.number}");

      switch (state.status) {
        case PhoneStateStatus.CALL_INCOMING:
          callStatus.value = "Incoming";
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
            print("📞 Tracking: ${phoneNumber.value}");
          }
          break;

        case PhoneStateStatus.CALL_ENDED:
          // ✅ Fix 1: CALL_STARTED nahi aavyo hoy to ignore karo
          // (App start fake event — number empty, duration 0)
          if (!_callWasStarted) {
            print(
              "🚫 CALL_ENDED ignored — no CALL_STARTED before this (app start fake event)",
            );
            return;
          }

          // ✅ Fix 2: Duplicate ignore karo
          if (_callEndedProcessed) {
            print("🔄 CALL_ENDED already processed, skip");
            return;
          }
          _callEndedProcessed = true;
          _callWasStarted = false; // Reset for next call

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
            "📴 CALL_ENDED: number=$endedNumber | duration=${callDuration.inSeconds}s",
          );

          phoneNumber.value = "";

          _showOverlayAfterCall(number: endedNumber, duration: callDuration);
          break;

        default:
          if (callStatus.value != "Idle") {
            callStatus.value = "Idle";
            _callEndedProcessed = false;
          }
      }
    });
  }

  Future<void> _showOverlayAfterCall({
    required String number,
    required Duration duration,
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
        );
      } else {
        Get.put(
          OverlayController(),
        ).onCallEnded(calledNumber: number, duration: duration);
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
