import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class NetworkService extends GetxService {
  final _isOnline = true.obs;

  RxBool get isOnline => _isOnline;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    _listenForConnectivityChanges();
  }

  void _checkInitialConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.isNotEmpty) {
      _updateConnectionStatus(connectivityResult.first);
    }
  }

  void _listenForConnectivityChanges() {
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.isNotEmpty) {
        _updateConnectionStatus(results.first);
      }
    });
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      _isOnline.value = false;
      Get.snackbar(
        "Internet",
        "No connection. Please turn on your internet!",
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } else {
      _isOnline.value = true;
      // Get.snackbar("Internet", "Connected to internet",
      //     backgroundColor: Get.theme.colorScheme.primary,
      //     colorText: Get.theme.colorScheme.onPrimary);
    }
  }
}
