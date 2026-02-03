import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class NetworkService extends GetxService {
  final _isOnline = true.obs;

  bool get isOnline => _isOnline.value;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    _listenForConnectivityChanges();
  }

  void _checkInitialConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectionStatus(connectivityResult as ConnectivityResult);
  }

  void _listenForConnectivityChanges() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _updateConnectionStatus(result);
    } as void Function(List<ConnectivityResult> event)?);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      _isOnline.value = false;
      Get.snackbar("Internet", "No connection. Please turn on your internet!");
    } else {
      _isOnline.value = true;
      Get.snackbar("Internet", "No connection. Please turn on your internet!");
    }
  }
}
