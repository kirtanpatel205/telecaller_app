import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/ui/views/call_form/call_form_page.dart';

class CallFormController extends GetxController {
  // ─────────────────────────────────────────────
  // FORM KEY
  // ─────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();

  // ─────────────────────────────────────────────
  // TEXT CONTROLLERS
  // ─────────────────────────────────────────────
  final fullNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final callbackDateController = TextEditingController();

  // ─────────────────────────────────────────────
  // DROPDOWNS
  // ─────────────────────────────────────────────
  RxString selectedProduct = "".obs;
  RxString selectedInterestLevel = "".obs;

  final List<Map<String, String>> productOptions = [
    {"label": "Loan", "value": "loan"},
    {"label": "Insurance", "value": "insurance"},
    {"label": "Credit Card", "value": "credit_card"},
    {"label": "Savings Account", "value": "savings_account"},
    {"label": "Fixed Deposit", "value": "fixed_deposit"},
    {"label": "Other", "value": "other"},
  ];

  final List<Map<String, String>> interestLevelOptions = [
    {"label": "High", "value": "high"},
    {"label": "Medium", "value": "medium"},
    {"label": "Low", "value": "low"},
  ];

  // ─────────────────────────────────────────────
  // RADIO GROUPS
  // ─────────────────────────────────────────────
  RxString selectedContactPreference = "".obs;
  RxString selectedDocument = "".obs;

  final List<String> contactPreferences = ["Call", "WhatsApp", "Email"];
  final List<String> documentOptions = ["Aadhar", "PAN", "Bank Statement"];

  // ─────────────────────────────────────────────
  // LOADING
  // ─────────────────────────────────────────────
  RxBool isLoading = false.obs;

  // ─────────────────────────────────────────────
  // DATE PICKER
  // ─────────────────────────────────────────────
  final rescheduleDate = "".obs;

  Future<void> pickCallbackDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final formatted =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      rescheduleDate.value = formatted;
      callbackDateController.text = formatted;
    }
  }

  // ─────────────────────────────────────────────
  // SAVE & SUBMIT
  // ─────────────────────────────────────────────
  Future<void> onSaveAndSubmit() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedProduct.value.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Please select an interested product",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
      return;
    }

    if (selectedContactPreference.value.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Please select a contact preference",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Collect form data
      final formData = {
        "fullName": fullNameController.text.trim(),
        "phoneNumber": phoneNumberController.text.trim(),
        "interestedProduct": selectedProduct.value,
        "contactPreference": selectedContactPreference.value,
        "documentsAvailable": selectedDocument.value,
        "preferredCallbackDate": callbackDateController.text.trim(),
        "customerInterestLevel": selectedInterestLevel.value,
      };

      print("📋 Call Form Submitted: $formData");

      // TODO: Add API call here
      // await apiService.submitCallForm(formData);

      Get.snackbar(
        "Success",
        "Form submitted successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[400],
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Close dialog after successful submission
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    } catch (e) {
      print("❌ Form submit error: $e");
      Get.snackbar(
        "Error",
        "Failed to submit form. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // RESET FORM
  // ─────────────────────────────────────────────
  void resetForm() {
    fullNameController.clear();
    phoneNumberController.clear();
    callbackDateController.clear();
    selectedProduct.value = "";
    selectedContactPreference.value = "";
    selectedDocument.value = "";
    selectedInterestLevel.value = "";
    rescheduleDate.value = "";
  }

  // ─────────────────────────────────────────────
  // STATIC SHOW — open the dialog from anywhere
  // ─────────────────────────────────────────────
  static Future<void> show() async {
    // Register controller if not already registered
    if (!Get.isRegistered<CallFormController>()) {
      Get.put(CallFormController());
    } else {
      Get.find<CallFormController>().resetForm();
    }

    await Get.dialog(
      CallFormPage(),
      barrierDismissible: false,
      barrierColor: Colors.black54,
    );
  }

  // ─────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────
  @override
  void onClose() {
    fullNameController.dispose();
    phoneNumberController.dispose();
    callbackDateController.dispose();
    super.onClose();
  }
}
