import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';

//import 'package:dbm_emp/core/models/language_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:getwidget/types/gf_loader_type.dart';
import 'package:intl/intl.dart';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:telecaller_app/core/helpers/storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';

class Utils {
  const Utils._();

  static bool isTablet() {
    var size = Get.size;
    var diagonal =
        sqrt((size.width * size.width) + (size.height * size.height));
    var isTablet = diagonal > 1100.0;
    //var isTablet = diagonal > 900.0;
    return isTablet;
  }

  static Future<String> loadJsonData(String path) async {
    String jsonString = await rootBundle.loadString(path);
    return jsonString;
  }

  // Url Open Snakbaar

  static showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.withOpacity(0.8),
        duration: const Duration(seconds: 3),
      ),
    );
  }



  // ✅ Helper method - Show success snackbar
  static showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.withOpacity(0.8),
        duration: const Duration(seconds: 2),
      ),
    );
  }


  static colorToHex(Color color) {
    return "#${color.value.toRadixString(16)}";
  }
  static Future<bool> hasValidToken() async {
    final token = Storage.getValue<String>(AppConstants.TOKEN);
    // print("New VALIDATION TOKEN $token");
    return token != null && token.isNotEmpty;
  }

  static Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static Map<String, dynamic> cleanNull(Map<String, dynamic> map) {
    final Map<String, dynamic> tempMap = map;
    tempMap.removeWhere((String key, dynamic value) => value == null);
    return tempMap;
  }

  static void printMap(Map<String, dynamic> map, {String name = "printMap"}) {
    debugPrint('$name - ${json.encode(map)}');
  }

  static int currentTimeInSeconds({DateTime? dateTime}) {
    var ms = (dateTime ?? new DateTime.now()).millisecondsSinceEpoch;
    return (ms / 1000).round();
  }

  static String symbolNumber(int numberToFormat) {
    return numberToFormat == null
        ? "0"
        : NumberFormat.compact().format(numberToFormat);
  }

  static String bash64(String text) {
    dynamic encodedText = utf8.encode(text);
    String base64Str = base64.encode(encodedText);
    return base64Str;
  }

  static Future<String> deviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor!; // unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.id; // unique ID on Android
    }
  }

  static String bash64Decode(String text) {
    String decodedText = utf8.decode(base64.decode(text));
    return decodedText;
  }

  static String getHash(String token, int currentTimeInSeconds) {
    return bash64('$token$currentTimeInSeconds');
  }

  static String fileExt(String filePath) {
    String filename = path.basename(filePath);
    return filename.split(".").last;
  }

  static String getRandomString(
    int length, {
    bool isNumber = true,
  }) {
    final _chars = isNumber ? '1234567890' : 'abcdefghijklmnopqrstuvwxyz';
    final _rnd = Random();

    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => _chars.codeUnitAt(
          _rnd.nextInt(
            _chars.length,
          ),
        ),
      ),
    );
  }

  static void loadingDialog() {
    Utils.closeDialog();

    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  static String normalizePhoneNumber(String number) {
    String normalized = number.trim().replaceAll(RegExp(r'[\s\-()]+'), '');
    if (normalized.isEmpty) return normalized;

    // Handle case like 91637... (12 digits starting with 91)
    if (normalized.startsWith('91') && normalized.length == 12) {
      return '+$normalized';
    }

    // Handle 10 digit Indian numbers
    if (normalized.length == 10 && !normalized.startsWith('+')) {
      return '+91$normalized';
    }

    // Ensure it starts with + if it's already a full number but missing the sign
    if (normalized.length > 10 && !normalized.startsWith('+')) {
      return '+$normalized';
    }

    return normalized;
  }

  static const _channel = MethodChannel('com.digibulkmarketing.telecaller_app/lockscreen');

  static Future<void> makeDirectCall(String number) async {
    try {
      if (number.isEmpty) return;
      
      final String normalizedNumber = normalizePhoneNumber(number);
      print("📞 [Utils] Initiating direct call to: $normalizedNumber (Original: $number)");
      
      // 1. Get the user-selected SIM slot index
      final int? slotIndex = await Storage.getSelectedSimSlot();
      print("📱 [Utils] Preferred SIM slot: ${slotIndex ?? 'default'}");

      // 2. Try native MethodChannel first to specify SIM slot
      try {
        final bool? success = await _channel.invokeMethod('makeDirectCall', {
          'number': normalizedNumber,
          'slotIndex': slotIndex,
        });
        
        if (success == true) {
          print("✅ [Utils] Native call triggered successfully");
          return;
        }
      } catch (e) {
        print("⚠️ [Utils] Native call failed: $e. Falling back to plugin.");
      }

      // 3. Fallback to standard plugin (may show system SIM picker)
      // Note: We use the external plugin as a safe fallback
      await FlutterPhoneDirectCaller.callNumber(number);
      
    } catch (e) {
      print("❌ [Utils] Fatal error making call: $e");
    }
  }

  static Future<bool> launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      return await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      print('Could not launch $url');
      return false;
    }
  }


  static void closeDialog() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  static void closeSnackbar() {
    if (Get.isSnackbarOpen) {
      Get.back();
    }
  }

  static void showSnackbar(String? message) {
    closeSnackbar();

    Get.rawSnackbar(message: message);
  }

  static void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        textColor: AppColors.themeColor.cardColor,
        backgroundColor: AppColors.themeColor.primaryColor,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1);
  }

  int daysBetweenString(String start, String end) {
    DateTime from = DateTime.parse(start).toLocal();
    DateTime to = DateTime.parse(end).toLocal();

    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  static DateTime stringToDate(String date) {
    return DateTime.parse(date).toLocal();
  }

  static String formatStringDate(String date,
      {String format = "dd-MMM-yyyy HH:mm a"}) {
    /// Convert into local date format.
    var localDate = stringToDate(date);

    /// inputFormat - format getting from api or other func.
    /// e.g If 2021-05-27 9:34:12.781341 then format should be yyyy-MM-dd HH:mm
    /// If 27/05/2021 9:34:12.781341 then format should be dd/MM/yyyy HH:mm
    var inputFormat = DateFormat('yyyy-MM-dd HH:mm');
    var inputDate = inputFormat.parse(localDate.toString());

    /// outputFormat - convert into format you want to show.
    var outputFormat = DateFormat(format);
    var outputDate = outputFormat.format(inputDate);

    return outputDate.toString();
  }

  static String formatDate(DateTime date,
      {String format = "dd/MMM/yyyy HH:mm"}) {
    /// Convert into local date format.
    var localDate = date;

    /// inputFormat - format getting from api or other func.
    /// e.g If 2021-05-27 9:34:12.781341 then format should be yyyy-MM-dd HH:mm
    /// If 27/05/2021 9:34:12.781341 then format should be dd/MM/yyyy HH:mm
    var inputFormat = DateFormat('yyyy-MM-dd HH:mm');
    var inputDate = inputFormat.parse(localDate.toString());

    /// outputFormat - convert into format you want to show.
    var outputFormat = DateFormat(format);
    var outputDate = outputFormat.format(inputDate);

    return outputDate.toString();
  }

  static void showToastError(String message) {
    Fluttertoast.showToast(
        msg: message,
        textColor: AppColors.themeColor.cardColor,
        backgroundColor: AppColors.themeColor.textSecondaryColor,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1);
  }

  static void closeKeyboard() {
    final currentFocus = Get.focusScope!;
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  // static void showToast(String message) {
  //   Fluttertoast.showToast(
  //       msg: message,
  //       textColor: AppColors.themeColor.otpColor,
  //       backgroundColor: AppColors.themeColor.cardColor,
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.BOTTOM,
  //       timeInSecForIosWeb: 1);
  // }

  static void goBackToScreen(String routeName) {
    Get.until(
      (route) => route.settings.name == routeName,
    );
  }

  static String fixLink({required String type, required String link}) {
    if (link.startsWith("http")) {
      return link;
    }

    String finalLink = "";
    switch (type) {
      case "linkedin":
        finalLink = "https://www.linkedin.com/in/" + link.replaceAll("@", "");
        break;
      case "instagram":
        finalLink = "https://instagram.com/" + link.replaceAll("@", "");
        break;
      case "spotify":
        finalLink = "https://spotify.com/" + link.replaceAll("@", "");
        break;
      case "youtube":
        finalLink = "https://youtube.com/" + link.replaceAll("@", "");
        break;
    }
    return finalLink;
  }

  static Widget get loading => Container(
        //color: Colors.black,
        child: Center(
          child: GFLoader(
            type: GFLoaderType.android,
            androidLoaderColor: AlwaysStoppedAnimation<Color>(
                AppColors.themeColor.primaryColor),

            //loaderColorOne: Colors.blueAccent,
            //loaderColorTwo: Colors.black,
            //loaderColorThree: Colors.pink,
          ),
        ),
      );
}
