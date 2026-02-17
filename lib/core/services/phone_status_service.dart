import 'dart:async';
import 'package:get/get.dart';
import 'package:phone_state/phone_state.dart';

class PhoneStatusService extends GetxService {
  StreamSubscription<PhoneState>? _phoneStateSub;

  var callStatus = "Idle".obs;
  var phoneNumber = "".obs;

  Future<PhoneStatusService> init() async {
    _startListening();
    return this;
  }

  void _startListening() async {
    // Permission check

    _phoneStateSub = PhoneState.stream.listen((PhoneState state) {
      switch (state.status) {
        case PhoneStateStatus.CALL_INCOMING:
          callStatus.value = "Incoming";
          phoneNumber.value = state.number ?? "";
          break;

        case PhoneStateStatus.CALL_STARTED:
          callStatus.value = "Call Started";
          break;

        case PhoneStateStatus.CALL_ENDED:
          callStatus.value = "Call Ended";
          break;

        default:
          callStatus.value = "Idle";
      }

      print("Call Status: ${callStatus.value}");
    });
  }

  @override
  void onClose() {
    _phoneStateSub?.cancel();
    super.onClose();
  }
}
