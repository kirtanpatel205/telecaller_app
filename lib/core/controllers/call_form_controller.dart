import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/core/models/all_lead_entity.dart';
import 'package:telecaller_app/core/services/api_service.dart';
import 'package:telecaller_app/ui/views/call_form/call_form_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_text_style.dart';

const FORM_FIELD_TYPES = {
  "TEXT": "text",
  "NUMBER": "number",
  "TEXTAREA": "textarea",
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
  "EXCEL": "excel",
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

        // Handle Checkbox (send as List<String>)
        if (field.type == FORM_FIELD_TYPES["CHECKBOX"]) {
          if (value is String && value.isNotEmpty) {
            value = value.split(",");
          } else if (value == null || (value is String && value.isEmpty)) {
            value = [];
          }
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

  // ─────────────────────────────────────────────────────────────────
  // MEDIA PICKER (IMAGE/VIDEO/FILE)
  // ─────────────────────────────────────────────────────────────────
  Future<void> pickMedia(String fieldId, String type) async {
    final ImagePicker picker = ImagePicker();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select ${type.toUpperCase()} Source",
              style: AppTextStyle.bold11.copyWith(
                fontSize: 18,
                color: AppColors.themeColor.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (type == FORM_FIELD_TYPES["FILE"] ||
                    type == FORM_FIELD_TYPES["IMAGE"] ||
                    type == FORM_FIELD_TYPES["VIDEO"]) ...[
                  _buildOptionTile(
                    icon: Icons.camera_alt_rounded,
                    label: "Camera",
                    color: Colors.blue,
                    onTap: () async {
                      Get.back();
                      // For generic FILE type, we'll default to Image picker for camera
                      final XFile? file =
                          type == FORM_FIELD_TYPES["VIDEO"]
                              ? await picker.pickVideo(
                                source: ImageSource.camera,
                              )
                              : await picker.pickImage(
                                source: ImageSource.camera,
                              );
                      if (file != null)
                        dynamicValues[fieldId]?.value = file.name;
                    },
                  ),
                  _buildOptionTile(
                    icon: Icons.photo_library_rounded,
                    label: "Gallery",
                    color: Colors.purple,
                    onTap: () async {
                      Get.back();
                      // For generic FILE type, we'll search both but Image is safer default here
                      final XFile? file =
                          type == FORM_FIELD_TYPES["VIDEO"]
                              ? await picker.pickVideo(
                                source: ImageSource.gallery,
                              )
                              : await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                      if (file != null)
                        dynamicValues[fieldId]?.value = file.name;
                    },
                  ),
                ],
                _buildOptionTile(
                  icon: Icons.folder_rounded,
                  label: "Files",
                  color: Colors.orange,
                  onTap: () async {
                    Get.back();
                    FileType fileType = FileType.any;
                    if (type == FORM_FIELD_TYPES["IMAGE"])
                      fileType = FileType.image;
                    if (type == FORM_FIELD_TYPES["VIDEO"])
                      fileType = FileType.video;

                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(type: fileType, allowMultiple: false);
                    if (result != null) {
                      dynamicValues[fieldId]?.value = result.files.single.name;
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyle.medium8.copyWith(fontSize: 14)),
        ],
      ),
    );
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
    if (showUI &&
        (formid == null || formid.isEmpty) &&
        controller.formId.value.isEmpty) {
      print(
        "🚫 Suppressing empty form popup (no primed data and no incoming formId)",
      );
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
            type == FORM_FIELD_TYPES["LOCATION"] ||
            type == FORM_FIELD_TYPES["IMAGE"] ||
            type == FORM_FIELD_TYPES["VIDEO"] ||
            type == FORM_FIELD_TYPES["EXCEL"]) {
          controller.dynamicControllers[fieldId] = TextEditingController();
        }

        // 2. Initialize RxString values for state-based fields
        if (type == FORM_FIELD_TYPES["SELECT"] ||
            type == FORM_FIELD_TYPES["RADIO"] ||
            type == FORM_FIELD_TYPES["CHECKBOX"] ||
            type == FORM_FIELD_TYPES["DATE"] ||
            type == FORM_FIELD_TYPES["TIME"] ||
            type == FORM_FIELD_TYPES["SLIDER"] ||
            type == FORM_FIELD_TYPES["RATING"] ||
            type == FORM_FIELD_TYPES["FILE"] ||
            type == FORM_FIELD_TYPES["IMAGE"] ||
            type == FORM_FIELD_TYPES["VIDEO"]) {
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
