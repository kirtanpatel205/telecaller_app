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
    loadSimInfo();
  }

  Future<void> loadSimInfo() async {
    isLoading.value = true;
    try {
      // Refresh SIM info using existing logic
      await BackgroundServiceManager.fetchAndSaveSimInfo();
      
      // Load from storage
      final cached = await Storage.getSimInfo();
      if (cached != null) {
        simCards.value = cached.cast<Map<String, dynamic>>();
        
        // Auto-select if only one SIM
        if (simCards.length == 1) {
          selectedSimIndex.value = 0;
        }
      }
    } catch (e) {
      print("Error loading SIM info: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void selectSim(int index) {
    selectedSimIndex.value = index;
  }

  Future<void> proceed() async {
    if (selectedSimIndex.value == -1) {
      Get.snackbar("Selection Required", "Please select a SIM card to continue.");
      return;
    }
    
    final selectedSim = simCards[selectedSimIndex.value];
    String? rawNumber = selectedSim['number'];
    int slotIndex = selectedSim['slotIndex'] ?? selectedSimIndex.value;

    // Save selection for background services
    await Storage.saveToSharedPrefs('selected_sim_slot_index', slotIndex);
    await GetStorage().write('selected_sim_slot_index', slotIndex);
    
    // If number is missing, we might need to ask the user, 
    // but the request said "sim choses pages like add in this login pages add"
    // Usually banking apps use the SIM to send a message or verify.
    
    if (rawNumber == null || rawNumber.isEmpty) {
      // If we can't get the number, we might need a fallback or show a field.
      // But let's try to proceed if we have SOMETHING.
      // For now, let's show a dialog to enter number if missing.
      _showNumberInputDialog();
      return;
    }

    await sendOtpForNumber(rawNumber);
  }

  Future<void> sendOtpForNumber(String number) async {
    isSendingOtp.value = true;
    try {
      // Normalize number if needed (e.g., add +91 if missing and 10 digits)
      String normalized = number;
      if (!normalized.startsWith('+')) {
        if (normalized.length == 10) {
          normalized = "+91$normalized";
        }
      }

      print("Sending OTP for: $normalized");
      
      ApiResponseEntity response = await apiService.sendOtp(
        phone: normalized,
      );

      if (response.status == true) {
        // Store the number in AuthController for OTP page
        // Need to parse into PhoneNumber object for compatibility
        final parsed = _parsePhoneNumber(normalized);
        authController.storePhoneNumber(parsed);
        
        Get.toNamed(Routes.OTP);
      } else {
        Get.snackbar("Error", response.message ?? "Failed to send OTP.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to send OTP. Please try again.");
    } finally {
      isSendingOtp.value = false;
    }
  }

  PhoneNumber _parsePhoneNumber(String completeNumber) {
    // Simple parser for compatibility with existing AuthController/LoginController
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
    // Fallback if SIM number is not readable
    Get.defaultDialog(
      title: "Enter Number",
      content: Column(
        children: [
          Text("Could not auto-detect number for this SIM. Please enter it manually."),
          SizedBox(height: 10),
          // We can use a simple text field here
        ],
      ),
      onConfirm: () {
        // ... logic to handle manual input if needed
      }
    );
    // Actually, I'll just redirect to Login for now if number is missing, 
    // or better, I'll implement a clean input in the SIM selection page itself.
  }
}
