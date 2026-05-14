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
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/ui/widgets/custom_button.dart';


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
        final int? savedSlot = await Storage.getFromSharedPrefs<int>(
          'selected_sim_slot_index',
        );
        if (savedSlot != null) {
          print("📱 [SimSelection] Found saved slot index: $savedSlot");
          for (int i = 0; i < simCards.length; i++) {
            if ((simCards[i]['slotIndex'] ?? i) == savedSlot) {
              selectedSimIndex.value = i;
              print(
                "📱 [SimSelection] Auto-selected SIM at index $i (slot $savedSlot)",
              );
              break;
            }
          }
        }

        // Auto-select if only one SIM and nothing was saved
        if (simCards.length == 1 && selectedSimIndex.value == -1) {
          selectedSimIndex.value = 0;
          print(
            "📱 [SimSelection] Single SIM detected, auto-selecting index 0",
          );
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
      Get.snackbar(
        "Selection Required",
        "Please select a SIM card to continue.",
      );
      return;
    }

    final selectedSim = simCards[selectedSimIndex.value];
    String? rawNumber = selectedSim['number'];
    int slotIndex = selectedSim['slotIndex'] ?? selectedSimIndex.value;
    String carrier = selectedSim['carrierName'] ?? "Unknown";

    print(
      "📱 [SimSelection] Selected SIM: $carrier, Slot: $slotIndex, Number: $rawNumber",
    );

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

      ApiResponseEntity response = await apiService.sendOtp(phone: normalized);

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
    print("📝 [SimSelection] Showing manual number input bottom sheet");
    final textController = TextEditingController();
    final isValid = false.obs;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: AppColors.themeColor.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32.r),
            topRight: Radius.circular(32.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.themeColor.bordercolror.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.phone_android_rounded,
                    color: Colors.orange,
                    size: 24.r,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  "Manual Verification",
                  style: AppTextStyle.bold7.copyWith(fontSize: 20.sp),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              "We couldn't automatically detect the number for this SIM. Please enter it manually to receive your OTP.",
              style: AppTextStyle.regular7.copyWith(
                color: AppColors.themeColor.textSecondaryColor,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),

            // Modern Input Field with Auto-Validation
            Obx(() => Container(
              decoration: BoxDecoration(
                color: AppColors.themeColor.bgColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isValid.value 
                    ? Colors.green.shade400 
                    : AppColors.themeColor.bordercolror.withOpacity(0.5),
                  width: isValid.value ? 2 : 1,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: TextField(
                controller: textController,
                keyboardType: TextInputType.phone,
                style: AppTextStyle.bold7.copyWith(
                  fontSize: 18.sp,
                  letterSpacing: 2,
                ),
                autofocus: true,
                maxLength: 10,
                onChanged: (val) {
                  isValid.value = val.length == 10;
                },
                decoration: InputDecoration(
                  counterText: "",
                  border: InputBorder.none,
                  hintText: "000 000 0000",
                  hintStyle: AppTextStyle.regular7.copyWith(
                    color: AppColors.themeColor.textSecondaryColor.withOpacity(
                      0.3,
                    ),
                    letterSpacing: 2,
                  ),
                  suffixIcon: isValid.value 
                    ? Icon(Icons.check_circle_rounded, color: Colors.green.shade400)
                    : null,
                  prefixIcon: Container(
                    width: 60.w,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "+91 ",
                      style: AppTextStyle.bold7.copyWith(
                        fontSize: 18.sp,
                        color: AppColors.themeColor.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            )),
            SizedBox(height: 32.h),

            // Proceed Button - Reactively enabled
            Obx(() => CustomButton(
              onClick: () {
                String input = textController.text.trim();
                Get.back(); // Close bottom sheet
                sendOtpForNumber("+91$input");
              },
              title: "Verify & Get OTP",
              enabled: isValid.value,
            )),
            SizedBox(height: MediaQuery.of(Get.context!).viewInsets.bottom),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
