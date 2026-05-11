import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:telecaller_app/constants/app_routes.dart';
import 'package:telecaller_app/core/controllers/auth_controller.dart';
import 'package:telecaller_app/core/helpers/storage.dart';
import 'package:telecaller_app/core/helpers/utils.dart';
import 'package:telecaller_app/core/models/api_response_entity.dart';
import 'package:telecaller_app/core/services/api_service.dart';
import 'package:telecaller_app/core/services/background_service_manager.dart';
import 'package:intl_phone_field2/phone_number.dart';

class SimSelectionController extends GetxController {
  final ApiService apiService = Get.find();
  final AuthController authController = AuthController.to;

  var simCards = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var isSendingOtp = false.obs;
  var selectedSimIndex = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    print("🚀 [SimSelection] Controller Initialized");
    loadSimInfo();
  }

  Future<void> loadSimInfo() async {
    print("📱 [SimSelection] Loading SIM info...");
    isLoading.value = true;
    try {
      // Refresh SIM info using existing logic
      await BackgroundServiceManager.fetchAndSaveSimInfo();
      
      // Load from storage
      final cached = await Storage.getSimInfo();
      if (cached != null) {
        simCards.value = cached.cast<Map<String, dynamic>>();
        print("📱 [SimSelection] Found ${simCards.length} SIM cards in cache");
        
        // Check if we have a previously selected slot
        final int? savedSlot = await Storage.getFromSharedPrefs<int>('selected_sim_slot_index');
        if (savedSlot != null) {
          print("📱 [SimSelection] Found saved slot index: $savedSlot");
          for (int i = 0; i < simCards.length; i++) {
            if ((simCards[i]['slotIndex'] ?? i) == savedSlot) {
              selectedSimIndex.value = i;
              print("📱 [SimSelection] Auto-selected SIM at index $i (slot $savedSlot)");
              break;
            }
          }
        }

        // Auto-select if only one SIM and nothing was saved
        if (simCards.length == 1 && selectedSimIndex.value == -1) {
          selectedSimIndex.value = 0;
          print("📱 [SimSelection] Single SIM detected, auto-selecting index 0");
        }
      } else {
        print("⚠️ [SimSelection] No SIM info found in storage");
      }
    } catch (e) {
      print("❌ [SimSelection] Error loading SIM info: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void selectSim(int index) {
    print("🔘 [SimSelection] User selected SIM index: $index");
    selectedSimIndex.value = index;
  }

  Future<void> proceed() async {
    print("🚀 [SimSelection] Proceeding with selection...");
    if (selectedSimIndex.value == -1) {
      print("⚠️ [SimSelection] No SIM selected");
      Get.snackbar("Selection Required", "Please select a SIM card to continue.");
      return;
    }
    
    final selectedSim = simCards[selectedSimIndex.value];
    String? rawNumber = selectedSim['number'];
    int slotIndex = selectedSim['slotIndex'] ?? selectedSimIndex.value;
    String carrier = selectedSim['carrierName'] ?? "Unknown";

    print("📱 [SimSelection] Selected SIM: $carrier, Slot: $slotIndex, Number: $rawNumber");

    // Save selection for background services
    await Storage.saveToSharedPrefs('selected_sim_slot_index', slotIndex);
    await GetStorage().write('selected_sim_slot_index', slotIndex);
    
    if (rawNumber == null || rawNumber.isEmpty || rawNumber == "null") {
      print("⚠️ [SimSelection] SIM number missing for Chinese phone/OEM");
      // If we can't get the number, we MUST ask the user
      _showNumberInputDialog();
      return;
    }

    await sendOtpForNumber(rawNumber);
  }

  Future<void> sendOtpForNumber(String number) async {
    print("📲 [SimSelection] Sending OTP for: $number");
    isSendingOtp.value = true;
    try {
      // Normalize number using central utility
      String normalized = Utils.normalizePhoneNumber(number);

      print("📲 [SimSelection] Normalized number: $normalized");
      
      ApiResponseEntity response = await apiService.sendOtp(
        phone: normalized,
      );

      if (response.status == true) {
        print("✅ [SimSelection] OTP sent successfully");
        final parsed = _parsePhoneNumber(normalized);
        authController.storePhoneNumber(parsed);
        Get.toNamed(Routes.OTP);
      } else {
        print("❌ [SimSelection] API Error: ${response.message}");
        Get.snackbar("Error", response.message ?? "Failed to send OTP.");
      }
    } catch (e) {
      print("❌ [SimSelection] Connection Error: $e");
      Get.snackbar("Error", "Failed to send OTP. Please try again.");
    } finally {
      isSendingOtp.value = false;
    }
  }

  PhoneNumber _parsePhoneNumber(String completeNumber) {
    print("🔍 [SimSelection] Parsing number: $completeNumber");
    if (completeNumber.startsWith('+91')) {
      return PhoneNumber(
        countryISOCode: 'IN',
        countryCode: '+91',
        number: completeNumber.substring(3),
      );
    }
    return PhoneNumber(
      countryISOCode: 'IN',
      countryCode: '+91',
      number: completeNumber,
    );
  }

  void _showNumberInputDialog() {
    print("📝 [SimSelection] Showing manual number input dialog");
    final textController = TextEditingController();
    Get.defaultDialog(
      title: "Enter SIM Number",
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "We couldn't automatically detect your phone number from this SIM. Please enter it manually to proceed.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            TextField(
              controller: textController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Phone Number",
                hintText: "Enter 10-digit number",
                border: OutlineInputBorder(),
                prefixText: "+91 ",
              ),
            ),
          ],
        ),
      ),
      textConfirm: "Login",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      onConfirm: () {
        String input = textController.text.trim();
        if (input.length == 10) {
          Get.back(); // Close dialog
          sendOtpForNumber("+91$input");
        } else {
          Get.snackbar("Invalid Number", "Please enter a valid 10-digit phone number.");
        }
      }
    );
  }
}

