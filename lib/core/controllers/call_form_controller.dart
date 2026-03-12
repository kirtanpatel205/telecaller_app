import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/core/models/all_lead_entity.dart';
import 'package:telecaller_app/core/services/api_service.dart';
import 'package:telecaller_app/ui/views/call_form/call_form_page.dart';

const FORM_FIELD_TYPES = {
  "TEXT": "text",
  "NUMBER": "number",
  "TEXTAREA": "textarea",
  "PARAGRAPH": "paragraph",
  "SELECT": "select",
  "RADIO": "radio",
  "CHECKBOX": "checkbox",
  "DATE": "date",
  "TIME": "time",
  "SLIDER": "slider",
  "RATING": "rating",
  "FILE": "file",
  "IMAGE": "image",
  "VIDEO": "video",
  "LOCATION": "location",
  "LINK": "link",
};

class CallFormController extends GetxController {
  // ─────────────────────────────────────────────
  // FORM KEY
  // ─────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();

  // ─────────────────────────────────────────────
  // DYNAMIC FIELDS
  // ─────────────────────────────────────────────
  final RxList<AllLeadLeadsFormIdFields> formFields =
      <AllLeadLeadsFormIdFields>[].obs;
  final Map<String, TextEditingController> dynamicControllers = {};
  final Map<String, RxString> dynamicValues = {};
  final RxString formId = "".obs;
  final RxString leadId = "".obs;
  final RxString leadContactId = "".obs;

  // ─────────────────────────────────────────────
  // LOADING
  // ─────────────────────────────────────────────
  RxBool isLoading = false.obs;

  // ─────────────────────────────────────────────
  // SAVE & SUBMIT
  // ─────────────────────────────────────────────
  Future<void> onSaveAndSubmit() async {
    if (!formKey.currentState!.validate()) return;

    // Check required dynamic dropdowns/radios that aren't text-based
    for (var field in formFields) {
      if (field.required ?? false) {
        if (field.type == FORM_FIELD_TYPES["SELECT"] ||
            field.type == FORM_FIELD_TYPES["RADIO"]) {
          if ((dynamicValues[field.id]?.value ?? "").isEmpty) {
            Get.snackbar(
              "Validation Error",
              "Please select a value for ${field.label}",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red[400],
              colorText: Colors.white,
            );
            return;
          }
        }
      }
    }

    isLoading.value = true;

    try {
      // Collect dynamic form data
      final Map<String, dynamic> formData = {
        "leadId": leadId.value,
        "formId": formId.value,
        "leadContactId": leadContactId.value,
        "answers": [],
      };

      for (var field in formFields) {
        final fieldId = field.id ?? "";
        if (fieldId.isEmpty) continue;

        dynamic value = "";
        if (dynamicControllers.containsKey(fieldId)) {
          value = dynamicControllers[fieldId]!.text.trim();
        } else if (dynamicValues.containsKey(fieldId)) {
          value = dynamicValues[fieldId]!.value;
        }

        // Handle specific types if needed (e.g. converting numeric strings to numbers)
        if (field.type == FORM_FIELD_TYPES["NUMBER"] || 
            field.type == FORM_FIELD_TYPES["RATING"] || 
            field.type == FORM_FIELD_TYPES["SLIDER"]) {
          value = num.tryParse(value.toString()) ?? value;
        }

        formData["answers"].add({
          "fieldId": fieldId,
          "label": field.label ?? "",
          "type": field.type ?? "",
          "value": value,
        });
      }

      print("📋 Call Form Submitted: $formData");

      final apiService = Get.find<ApiService>();
      final response = await apiService.submitCallForm(formData);

      if (response.status ?? false) {
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
      } else {
        throw response.message ?? "Failed to submit form";
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
    for (var controller in dynamicControllers.values) {
      controller.dispose();
    }
    dynamicControllers.clear();
    dynamicValues.clear();
    formFields.clear();
    formId.value = "";
    leadId.value = "";
    leadContactId.value = "";
  }

  // ─────────────────────────────────────────────
  // DATE PICKER
  // ─────────────────────────────────────────────
  Future<void> pickDate(BuildContext context, String fieldId) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final formatted =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      dynamicControllers[fieldId]?.text = formatted;
    }
  }

  // ─────────────────────────────────────────────
  // TIME PICKER
  // ─────────────────────────────────────────────
  Future<void> pickTime(BuildContext context, String fieldId) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final formatted =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      dynamicControllers[fieldId]?.text = formatted;
      dynamicValues[fieldId]?.value = formatted;
    }
  }

  // ─────────────────────────────────────────────
  // STATIC SHOW — open the dialog from anywhere
  // ─────────────────────────────────────────────
  static Future<void> show({
    required String formid,
    required String leadId,
    required String leadContactId,
    List<AllLeadLeadsFormIdFields> formFields = const [],
    bool showUI = true,
  }) async {
    print(
      "🚀 CallFormController.show: Form=$formid, Lead=$leadId, Contact=$leadContactId, showUI=$showUI, fields=${formFields.length}",
    );
    if (!Get.isRegistered<CallFormController>()) {
      Get.put(CallFormController());
    }
    final controller = Get.find<CallFormController>();

    // ── Guard: Suppress Empty Form ──────────────────────────────────────────
    // If showUI=true but no formid is passed AND no form is primed, skip showing.
    // This prevents "wrong data" popups from PhoneStatusService for leads without forms.
    if (showUI && (formid == null || formid.isEmpty) && controller.formId.value.isEmpty) {
      print("🚫 Suppressing empty form popup (no primed data and no incoming formId)");
      return;
    }

    // Detect if this is a "trigger" for an existing primed form
    // (e.g., PhoneStatusService showing a form that AutoDialer already prepared)
    bool isTriggeringPrimed =
        (formid == null || formid.isEmpty) &&
        controller.formId.value.isNotEmpty;

    if (!isTriggeringPrimed) {
      print("📝 Initializing form with new data...");
      controller.resetForm();
      controller.formId.value = formid;
      controller.leadId.value = leadId;
      controller.leadContactId.value = leadContactId;
      controller.formFields.assignAll(formFields);

      // Initialize dynamic controllers/values
      for (var field in formFields) {
        final fieldId = field.id ?? "";
        if (fieldId.isEmpty) continue;

        final type = field.type;

        // 1. Initialize TextEditingControllers for text-based or display-as-text fields
        if (type == FORM_FIELD_TYPES["TEXT"] ||
            type == FORM_FIELD_TYPES["NUMBER"] ||
            type == FORM_FIELD_TYPES["TEXTAREA"] ||
            type == FORM_FIELD_TYPES["DATE"] ||
            type == FORM_FIELD_TYPES["TIME"] ||
            type == FORM_FIELD_TYPES["LINK"] ||
            type == FORM_FIELD_TYPES["LOCATION"]) {
          controller.dynamicControllers[fieldId] = TextEditingController();
        }

        // 2. Initialize RxString values for state-based fields
        if (type == FORM_FIELD_TYPES["SELECT"] ||
            type == FORM_FIELD_TYPES["RADIO"] ||
            type == FORM_FIELD_TYPES["CHECKBOX"] ||
            type == FORM_FIELD_TYPES["DATE"] ||
            type == FORM_FIELD_TYPES["TIME"] ||
            type == FORM_FIELD_TYPES["SLIDER"] ||
            type == FORM_FIELD_TYPES["RATING"]) {
          controller.dynamicValues[fieldId] = "".obs;
        }
      }
    } else {
      print("🔄 Using already primed form: ${controller.formId.value}");
    }

    if (showUI) {
      await Get.dialog(
        CallFormPage(),
        barrierDismissible: false,
        barrierColor: Colors.black54,
      );
    }
  }

  // ─────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────
  @override
  void onClose() {
    for (var controller in dynamicControllers.values) {
      controller.dispose();
    }
    super.onClose();
  }
}
