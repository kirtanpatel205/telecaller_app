import 'dart:io' as java_io;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/core/models/all_lead_entity.dart';
import 'package:telecaller_app/core/services/api_service.dart';
import 'package:telecaller_app/ui/views/call_form/call_form_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_text_style.dart';

const FORM_FIELD_TYPES = {
  "TEXT": "text",
  "NUMBER": "number",
  "EMAIL": "email",
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
  "PHONE":"phone"
};

const MIME_TO_EXT = {
  "image/png": ".png",
  "image/jpeg": ".jpg",
  "image/jpg": ".jpg",
  "image/gif": ".gif",
  "video/mp4": ".mp4",
  "audio/mpeg": ".mp3",
  "application/pdf": ".pdf",
  "application/ogg": ".ogg",
};

const ALLOWED_EXTENSIONS = [
  ".png", ".jpg", ".jpeg", ".gif", 
  ".mp4", 
  ".mp3", 
  ".pdf", 
  ".ogg",
  ".xls", ".xlsx", ".csv", 
  ".doc", ".docx", ".txt", ".zip"
];

const ALLOWED_PICKER_EXTENSIONS = [
  'pdf', 'doc', 'docx', 'txt', 'zip', 'xls', 'xlsx', 'csv', 'mp3', 'ogg', 'png', 'jpg', 'jpeg', 'gif', 'mp4'
];

class CallFormController extends GetxController {
  // ─────────────────────────────────────────────
  // HELPERS — Centralized Type Detection
  // ─────────────────────────────────────────────
  static String getEffectiveType(String? rawType, String? label) {
    String type = (rawType ?? "").toLowerCase();
    String lbl = (label ?? "").toLowerCase();

    bool isExcelByLabel = lbl.contains("excel") || lbl.contains("sheet") || lbl.contains("csv") || lbl.contains("xls");
    bool isFileByLabel = lbl.contains("file") || lbl.contains("document") || lbl.contains("pdf") || lbl.contains("attachment");
    bool isPhoneByLabel = lbl.contains("phone") || lbl.contains("mobile") || lbl.contains("contact") || lbl.contains("whatsapp");
    bool isLinkByLabel = lbl.contains("link") || lbl.contains("url") || lbl.contains("website") || lbl.contains("social") || lbl.contains("linkedin") || lbl.contains("instagram") || lbl.contains("facebook") || lbl.contains("twitter") || lbl.contains("youtube");
    bool isEmailByLabel = lbl.contains("email") || lbl.contains("mail");
    bool isDateByLabel = lbl.contains("date") || lbl.contains("birth");
    bool isTimeByLabel = lbl.contains("time");
    bool isLocationByLabel = lbl.contains("location") || lbl.contains("gps") || lbl.contains("coordinate") || lbl.contains("latitude") || lbl.contains("longitude");

    if (isExcelByLabel && (type != FORM_FIELD_TYPES["IMAGE"] && type != FORM_FIELD_TYPES["VIDEO"])) {
      return FORM_FIELD_TYPES["EXCEL"]!;
    } else if (isFileByLabel && (type != FORM_FIELD_TYPES["IMAGE"] && type != FORM_FIELD_TYPES["VIDEO"])) {
      return FORM_FIELD_TYPES["FILE"]!;
    } else if (isPhoneByLabel && (type == FORM_FIELD_TYPES["TEXT"] || type == FORM_FIELD_TYPES["NUMBER"] || type == "")) {
      return FORM_FIELD_TYPES["PHONE"]!;
    } else if (isLinkByLabel && (type == FORM_FIELD_TYPES["TEXT"] || type == "")) {
      return FORM_FIELD_TYPES["LINK"]!;
    } else if (isEmailByLabel && (type == FORM_FIELD_TYPES["TEXT"] || type == "")) {
      return FORM_FIELD_TYPES["EMAIL"]!;
    } else if (isDateByLabel && (type == FORM_FIELD_TYPES["TEXT"] || type == "")) {
      return FORM_FIELD_TYPES["DATE"]!;
    } else if (isTimeByLabel && (type == FORM_FIELD_TYPES["TEXT"] || type == "")) {
      return FORM_FIELD_TYPES["TIME"]!;
    } else if (isLocationByLabel && (type == FORM_FIELD_TYPES["TEXT"] || type == "")) {
      return FORM_FIELD_TYPES["LOCATION"]!;
    }
    return type;
  }

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
  final RxString formResponseId = "".obs;

  // ─────────────────────────────────────────────
  // LOADING
  // ─────────────────────────────────────────────
  RxBool isLoading = false.obs;
  RxBool canClose = true.obs;
  RxBool isFormVisible = false.obs;

  // ─────────────────────────────────────────────
  // SAVE & SUBMIT
  // ─────────────────────────────────────────────
  Future<void> onSaveAndSubmit() async {
    if (!formKey.currentState!.validate()) return;

    // 🔴 Manual validation for non-text fields
    for (var field in formFields) {
      if (field.required ?? false) {
        final type = field.type;

        if (type == FORM_FIELD_TYPES["SELECT"] ||
            type == FORM_FIELD_TYPES["RADIO"] ||
            type == FORM_FIELD_TYPES["CHECKBOX"] ||
            type == FORM_FIELD_TYPES["FILE"] ||
            type == FORM_FIELD_TYPES["IMAGE"] ||
            type == FORM_FIELD_TYPES["VIDEO"] ||
            type == FORM_FIELD_TYPES["EXCEL"] ||
            type == FORM_FIELD_TYPES["SLIDER"] ||
            type == FORM_FIELD_TYPES["RATING"]) {

          final val = dynamicValues[field.id]?.value;

          if (val == null || val.toString().isEmpty) {
            Get.snackbar(
              "validation_error".tr,
              "${"please_select_a_value_for".tr} ${field.label ?? ''}",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          }
        }
      }
    }

    isLoading.value = true;

    try {
      final Map<String, dynamic> formData = {
        "leadId": leadId.value,
        "formId": formId.value,
        "leadContactId": leadContactId.value,
        "answers": [],
      };

      if (formResponseId.value.isNotEmpty) {
        formData["formResponseId"] = formResponseId.value;
      }

      for (var field in formFields) {
        final fieldId = field.id ?? "";
        if (fieldId.isEmpty) continue;

        dynamic value = "";
        String fType = getEffectiveType(field.type, field.label).toLowerCase();

        // 🔥 MEDIA DETECTION
        bool isMedia = (
            fType == FORM_FIELD_TYPES["FILE"] ||
                fType == FORM_FIELD_TYPES["IMAGE"] ||
                fType == FORM_FIELD_TYPES["VIDEO"] ||
                fType == FORM_FIELD_TYPES["EXCEL"] ||
                fType.contains("file") ||
                fType.contains("excel") ||
                fType.contains("document")
        );

        // 📍 1. MEDIA FIELD (Prioritize dynamicValues)
        if (isMedia && dynamicValues.containsKey(fieldId)) {
          value = dynamicValues[fieldId]!.value;

          print("🟡 MEDIA FIELD: $fType, RAW VALUE: $value");

          // ✅ Case 1: "url|filename"
          if (value is String && value.contains('|')) {
            final parts = value.split('|');
            value = {
              "url": parts[0],
              "name": parts.length > 1 ? parts[1] : parts[0].split('/').last
            };
          }
          // ✅ Case 2: Only valid URL
          else if (value is String && value.isNotEmpty && value.contains('/')) {
            value = {
              "url": value,
              "name": value.split('/').last
            };
          }
          // ✅ Case 3: Already Map
          else if (value is Map) {
            value = {
              "url": value["url"] ?? "",
              "name": value["name"] ?? ""
            };
          }
          // ❌ Empty or invalid
          else {
            print("❌ MEDIA VALUE MISSING for $fType");
            value = ""; 
          }
          print("🟢 FINAL MEDIA VALUE: $value");
        }

        // 📍 2. LOCATION FIELD
        else if (fType == FORM_FIELD_TYPES["LOCATION"]) {
          final lat = dynamicControllers["${fieldId}_lat"]?.text.trim() ?? "";
          final lng = dynamicControllers["${fieldId}_lng"]?.text.trim() ?? "";

          if (lat.isNotEmpty || lng.isNotEmpty) {
            value = {
              "latitude": double.tryParse(lat) ?? lat,
              "longitude": double.tryParse(lng) ?? lng,
              "coordinates": "$lat,$lng"
            };
          }
        }

        // 📍 3. TEXT-BASED FIELDS (Controllers)
        else if (dynamicControllers.containsKey(fieldId)) {
          value = dynamicControllers[fieldId]!.text.trim();
          if (fType == FORM_FIELD_TYPES["PHONE"] && value.isNotEmpty) {
            if (!value.startsWith("+91")) {
              value = "+91$value";
            }
          } else if (fType == FORM_FIELD_TYPES["LINK"] && value.isNotEmpty) {
            value = {
              "url": value,
              "name": field.label ?? "Link"
            };
          }
        }

        // 📍 4. OTHER STATE-BASED FIELDS (Values)
        else if (dynamicValues.containsKey(fieldId)) {
          value = dynamicValues[fieldId]!.value;
        }

        // 🔢 NUMBER / RATING / SLIDER (Exclude PHONE detected fields)
        if ((field.type == FORM_FIELD_TYPES["NUMBER"] && fType != FORM_FIELD_TYPES["PHONE"]) ||
            field.type == FORM_FIELD_TYPES["RATING"] ||
            field.type == FORM_FIELD_TYPES["SLIDER"]) {
          value = num.tryParse(value.toString()) ?? value;
        }

        // ✅ CHECKBOX → List
        if (field.type == FORM_FIELD_TYPES["CHECKBOX"]) {
          if (value is String && value.isNotEmpty) {
            value = value.split(",");
          } else {
            value = [];
          }
        }

        // 📦 ADD TO ANSWERS
        formData["answers"].add({
          "fieldId": fieldId,
          "label": field.label ?? "",
          "type": field.type ?? "",
          "value": value,
        });
      }

      print("📤 FINAL SUBMIT DATA: $formData");

      final apiService = Get.find<ApiService>();
      final response = formResponseId.value.isNotEmpty
          ? await apiService.updateCallForm(formData)
          : await apiService.submitCallForm(formData);

      if (response.status ?? false) {

        // ✅ CLOSE DIALOG
        canClose.value = true;

        if (Get.isDialogOpen == true) {
          Get.back();
        } else {
          try {
            Navigator.of(Get.overlayContext!).pop();
          } catch (_) {}
        }

        // ✅ SUCCESS MESSAGE
        Get.snackbar(
          "Success",
          "Form submitted successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

      } else {
        throw response.message ?? "Submit failed";
      }

    } catch (e) {
      print("❌ ERROR: $e");

      Get.snackbar(
        "Error",
        "Failed to submit form",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
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
    formResponseId.value = "";
    canClose.value = true;
  }

  // ─────────────────────────────────────────────
  // FETCH EXISTING FORM RESPONSE
  // ─────────────────────────────────────────────
  Future<void> fetchExistingResponse(String leadContactId) async {
    if (leadContactId.isEmpty) return;

    isLoading.value = true;
    try {
      final apiService = Get.find<ApiService>();
      final response = await apiService.formResponse(leadContactId: leadContactId);

      if (response.status == true && response.formResponse != null) {
        formResponseId.value = response.formResponse!.id ?? "";
        final answers = response.formResponse!.answers ?? [];
        print("📥 Pre-populating form with ${answers.length} existing answers for contact: $leadContactId");

        for (var answer in answers) {
          final fieldId = answer.fieldId ?? "";
          if (fieldId.isEmpty) continue;

          dynamic rawVal = answer.value;
          if (rawVal == null) continue;
          final type = answer.type ?? "";

          // Try to locate the matching field from our formFields to get the exact effective type
          final fieldObj = formFields.firstWhereOrNull((f) => f.id == fieldId);
          final effectiveType = fieldObj != null 
              ? getEffectiveType(fieldObj.type, fieldObj.label) 
              : type.toLowerCase();

          print("✍️ Restoring field $fieldId ($effectiveType) with raw value: $rawVal");

          // 1. Text-based fields (using controllers)
          if (dynamicControllers.containsKey(fieldId)) {
            if (effectiveType == FORM_FIELD_TYPES["PHONE"]) {
              String valStr = rawVal.toString().trim();
              if (valStr.startsWith("+91")) {
                dynamicControllers[fieldId]!.text = valStr.replaceFirst("+91", "");
              } else {
                dynamicControllers[fieldId]!.text = valStr;
              }
            } else if (effectiveType == FORM_FIELD_TYPES["LINK"]) {
              if (rawVal is Map) {
                dynamicControllers[fieldId]!.text = rawVal["url"]?.toString() ?? "";
              } else {
                String valStr = rawVal.toString().trim();
                if (valStr.contains("url")) {
                  final urlReg = RegExp(r'url[:\s=]+([^\s,}]+)');
                  final urlMatch = urlReg.firstMatch(valStr);
                  if (urlMatch != null) {
                    dynamicControllers[fieldId]!.text = urlMatch.group(1)?.replaceAll(RegExp(r'[{}"]'), "").trim() ?? valStr;
                  } else {
                    dynamicControllers[fieldId]!.text = valStr;
                  }
                } else {
                  dynamicControllers[fieldId]!.text = valStr;
                }
              }
            } else {
              dynamicControllers[fieldId]!.text = rawVal.toString().trim();
            }
          }

          // 2. Location fields
          if (effectiveType == FORM_FIELD_TYPES["LOCATION"]) {
            if (rawVal is Map) {
              dynamicControllers["${fieldId}_lat"]?.text = (rawVal["latitude"] ?? rawVal["lat"] ?? "").toString().trim();
              dynamicControllers["${fieldId}_lng"]?.text = (rawVal["longitude"] ?? rawVal["lng"] ?? "").toString().trim();
            } else {
              String valStr = rawVal.toString().trim();
              try {
                if (valStr.isNotEmpty) {
                  // If it looks like a Map representation: "{latitude: ..., longitude: ...}" or similar
                  if (valStr.contains("latitude") || valStr.contains("lat")) {
                    final latReg = RegExp(r'(?:latitude|lat)[:\s=]+([-\d.]+)');
                    final lngReg = RegExp(r'(?:longitude|lng)[:\s=]+([-\d.]+)');
                    final latMatch = latReg.firstMatch(valStr);
                    final lngMatch = lngReg.firstMatch(valStr);
                    
                    if (latMatch != null && lngMatch != null) {
                      dynamicControllers["${fieldId}_lat"]?.text = latMatch.group(1) ?? "";
                      dynamicControllers["${fieldId}_lng"]?.text = lngMatch.group(1) ?? "";
                    }
                  } else if (valStr.contains(",")) {
                    final parts = valStr.split(",");
                    if (parts.length >= 2) {
                      dynamicControllers["${fieldId}_lat"]?.text = parts[0].replaceAll(RegExp(r'[^\d.-]'), "").trim();
                      dynamicControllers["${fieldId}_lng"]?.text = parts[1].replaceAll(RegExp(r'[^\d.-]'), "").trim();
                    }
                  }
                }
              } catch (e) {
                print("Error parsing location value: $e");
              }
            }
          }

          // 3. State-based fields (RxString values)
          if (dynamicValues.containsKey(fieldId)) {
            if (effectiveType == FORM_FIELD_TYPES["CHECKBOX"]) {
              if (rawVal is List) {
                dynamicValues[fieldId]!.value = rawVal.map((e) => e.toString()).join(",");
              } else {
                String valStr = rawVal.toString().trim();
                // Convert List representations like "[Option A, Option B]" to comma-separated
                if (valStr.startsWith("[") && valStr.endsWith("]")) {
                  valStr = valStr.substring(1, valStr.length - 1);
                  final options = valStr.split(",").map((s) => s.trim()).toList();
                  dynamicValues[fieldId]!.value = options.join(",");
                } else {
                  dynamicValues[fieldId]!.value = valStr;
                }
              }
            } else if (effectiveType == FORM_FIELD_TYPES["FILE"] ||
                       effectiveType == FORM_FIELD_TYPES["IMAGE"] ||
                       effectiveType == FORM_FIELD_TYPES["VIDEO"] ||
                       effectiveType == FORM_FIELD_TYPES["EXCEL"] ||
                       effectiveType.contains("excel") ||
                       effectiveType.contains("file")) {
              
              if (rawVal is Map) {
                final url = rawVal["url"]?.toString() ?? "";
                final name = rawVal["name"]?.toString() ?? url.split('/').last;
                dynamicValues[fieldId]!.value = "$url|$name";
              } else {
                String valStr = rawVal.toString().trim();
                // If backend returned a map representation: "{url: http://..., name: file.png}"
                if (valStr.contains("url")) {
                  final urlReg = RegExp(r'url[:\s=]+([^\s,}]+)');
                  final nameReg = RegExp(r'name[:\s=]+([^\s,}]+)');
                  
                  final urlMatch = urlReg.firstMatch(valStr);
                  final nameMatch = nameReg.firstMatch(valStr);
                  
                  if (urlMatch != null) {
                    final url = urlMatch.group(1)?.replaceAll(RegExp(r'[{}"]'), "").trim() ?? "";
                    final name = nameMatch?.group(1)?.replaceAll(RegExp(r'[{}"]'), "").trim() ?? url.split('/').last;
                    dynamicValues[fieldId]!.value = "$url|$name";
                  } else {
                    dynamicValues[fieldId]!.value = valStr;
                  }
                } else {
                  dynamicValues[fieldId]!.value = valStr;
                }
              }
            } else {
              dynamicValues[fieldId]!.value = rawVal.toString().trim();
            }
          }
        }
      }
    } catch (e) {
      print("❌ Error fetching existing form response: $e");
    } finally {
      isLoading.value = false;
    }
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Get.isDarkMode 
              ? const ColorScheme.dark(
                  primary: Color(0xff3298CC),
                  onPrimary: Colors.white,
                  surface: Color(0xFF1E1E1E),
                  onSurface: Colors.white,
                )
              : ColorScheme.light(
                  primary: AppColors.themeColor.primaryColor,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.themeColor.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
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
    Duration initialDuration = Duration.zero;

    // Attempt to parse existing time if any
    String? currentVal = dynamicValues[fieldId]?.value;
    if (currentVal != null && currentVal.isNotEmpty) {
      try {
        final parts = currentVal.split(':');
        if (parts.length >= 3) {
          initialDuration = Duration(
            hours: int.parse(parts[0]),
            minutes: int.parse(parts[1]),
            seconds: int.parse(parts[2]),
          );
        }
      } catch (e) {
        print("Error parsing time: $e");
      }
    } else {
      // Default to current time if empty
      final now = DateTime.now();
      initialDuration = Duration(hours: now.hour, minutes: now.minute, seconds: now.second);
    }

    Get.bottomSheet(
      Container(
        height: 350,
        decoration: BoxDecoration(
          color: AppColors.themeColor.cardColor,
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
          children: [
            // Drag Handle
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            // Header with title and buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      "cancel".tr,
                      style: AppTextStyle.medium8.copyWith(color: Colors.redAccent, fontSize: 16),
                    ),
                  ),
                  Text(
                    "select_time".tr,
                    style: AppTextStyle.bold11.copyWith(
                      fontSize: 19,
                      color: AppColors.themeColor.textPrimaryColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final formatted =
                          "${initialDuration.inHours.toString().padLeft(2, '0')}:${(initialDuration.inMinutes % 60).toString().padLeft(2, '0')}:${(initialDuration.inSeconds % 60).toString().padLeft(2, '0')}";
                      dynamicControllers[fieldId]?.text = formatted;
                      dynamicValues[fieldId]?.value = formatted;
                      Get.back();
                    },
                    child: Text(
                      "done".tr,
                      style: AppTextStyle.bold11.copyWith(
                        color: AppColors.themeColor.primaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Picker
            Expanded(
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    pickerTextStyle: AppTextStyle.medium8.copyWith(
                      fontSize: 22,
                      color: AppColors.themeColor.textPrimaryColor,
                    ),
                  ),
                ),
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hms,
                  initialTimerDuration: initialDuration,
                  onTimerDurationChanged: (Duration newDuration) {
                    initialDuration = newDuration;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ─────────────────────────────────────────────
  // LOCATION PICKER
  // ─────────────────────────────────────────
  Future<void> fetchLocation(String fieldId) async {
    bool serviceEnabled;
    LocationPermission permission;

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.back();
        Get.snackbar("Location Error", "Location services are disabled.",
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.back();
          Get.snackbar("Location Error", "Location permissions are denied",
              snackPosition: SnackPosition.BOTTOM);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.back();
        Get.snackbar("Location Error", "Location permissions are permanently denied.",
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      
      Get.back();
      
      dynamicControllers["${fieldId}_lat"]?.text = position.latitude.toString();
      dynamicControllers["${fieldId}_lng"]?.text = position.longitude.toString();
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar("Location Error", "Failed to get location: $e",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // MEDIA PICKER (IMAGE/VIDEO/FILE)
  // ─────────────────────────────────────────────────────────────────
  Future<void> pickMedia(String fieldId, String type) async {
    final ImagePicker picker = ImagePicker();

    if (type == FORM_FIELD_TYPES["EXCEL"] || type == FORM_FIELD_TYPES["FILE"]) {
      FileType fileType = FileType.any;
      List<String>? allowedExtensions;

      if (type == FORM_FIELD_TYPES["EXCEL"]) {
        fileType = FileType.custom;
        allowedExtensions = ['xls', 'xlsx', 'csv'];
      } else if (type == FORM_FIELD_TYPES["FILE"]) {
        // Explicitly allow common doc types including PDF and audio
        fileType = FileType.custom;
        allowedExtensions = ['pdf', 'doc', 'docx', 'txt', 'zip', 'mp3', 'ogg'];
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: fileType, 
        allowedExtensions: allowedExtensions, 
        allowMultiple: false
      );
      if (result != null && result.files.single.path != null) {
        String path = result.files.single.path!;
        String ext = "." + path.split('.').last.toLowerCase();
        
        if (!ALLOWED_EXTENSIONS.contains(ext)) {
          Get.snackbar(
            "Invalid File Type", 
            "Selected file type ($ext) is not allowed.", 
            snackPosition: SnackPosition.BOTTOM, 
            backgroundColor: Colors.redAccent, 
            colorText: Colors.white
          );
          return;
        }

        if (result.files.single.size > 2 * 1024 * 1024) {
          Get.snackbar(
            "File Too Large", 
            "Please select a file smaller than 2 MB.", 
            snackPosition: SnackPosition.BOTTOM, 
            backgroundColor: Colors.redAccent, 
            colorText: Colors.white
          );
          return;
        }
        _uploadToApi(fileId: fieldId, filePath: result.files.single.path!, type: type);
      }
      return;
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.themeColor.cardColor,
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
              "${"select".tr} ${type.toUpperCase()} ${"source".tr}",
              style: AppTextStyle.bold11.copyWith(
                fontSize: 18,
                color: AppColors.themeColor.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (type == FORM_FIELD_TYPES["IMAGE"] ||
                    type == FORM_FIELD_TYPES["VIDEO"]) ...[
                  _buildOptionTile(
                    icon: Icons.camera_alt_rounded,
                    label: "openCamera".tr,
                    color: AppColors.themeColor.primaryColor,
                    onTap: () async {
                      if (Get.isBottomSheetOpen ?? false) {
                        Get.back();
                      }
                      final XFile? file =
                          type == FORM_FIELD_TYPES["VIDEO"]
                              ? await picker.pickVideo(
                                source: ImageSource.camera,
                              )
                              : await picker.pickImage(
                                source: ImageSource.camera,
                              );
                      if (file != null) {
                        final length = await file.length();
                        if (length > 5 * 1024 * 1024) {
                          Get.snackbar(
                            "File Too Large", 
                            "Please select a file smaller than 5 MB.", 
                            snackPosition: SnackPosition.BOTTOM, 
                            backgroundColor: Colors.redAccent, 
                            colorText: Colors.white
                          );
                          return;
                        }
                        _uploadToApi(fileId: fieldId, filePath: file.path, type: type);
                      }
                    },
                  ),
                  _buildOptionTile(
                    icon: Icons.photo_library_rounded,
                    label: "openGallery".tr,
                    color: Colors.purple,
                    onTap: () async {
                      if (Get.isBottomSheetOpen ?? false) {
                        Get.back();
                      }
                      final XFile? file =
                          type == FORM_FIELD_TYPES["VIDEO"]
                              ? await picker.pickVideo(
                                source: ImageSource.gallery,
                              )
                              : await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                      if (file != null) {
                        final length = await file.length();
                        if (length > 5 * 1024 * 1024) {
                          Get.snackbar(
                            "File Too Large", 
                            "Please select a file smaller than 5 MB.", 
                            snackPosition: SnackPosition.BOTTOM, 
                            backgroundColor: Colors.redAccent, 
                            colorText: Colors.white
                          );
                          return;
                        }
                        _uploadToApi(fileId: fieldId, filePath: file.path, type: type);
                      }
                    },
                  ),
                ],
                _buildOptionTile(
                  icon: Icons.folder_rounded,
                  label: "files".tr,
                  color: Colors.orange,
                  onTap: () async {
                    if (Get.isBottomSheetOpen ?? false) {
                      Get.back();
                    }
                    FileType fileType = FileType.any;
                    List<String>? allowedExtensions;

                    if (type == FORM_FIELD_TYPES["IMAGE"]) {
                      fileType = FileType.image;
                    } else if (type == FORM_FIELD_TYPES["VIDEO"]) {
                      fileType = FileType.video;
                    } else if (type == FORM_FIELD_TYPES["EXCEL"]) {
                      print("My file type is excel ${FileType.custom}");
                      fileType = FileType.custom;
                      allowedExtensions = ['xls', 'xlsx', 'csv'];
                    }

                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(type: fileType, allowedExtensions: allowedExtensions, allowMultiple: false);
                    if (result != null && result.files.single.path != null) {
                      _uploadToApi(fileId: fieldId, filePath: result.files.single.path!, type: type);
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

  Future<void> _uploadToApi({
    required String fileId,
    required String filePath,
    required String type,
  }) async {
    isLoading.value = true;

    try {
      final response = await Get.find<ApiService>().uploadMedia(
        file: java_io.File(filePath),
        type: type,
      );

      print("📥 UPLOAD RESPONSE: $response");

      String? uploadedUrl;

      // 🔥 DIRECT RESPONSE HANDLING (IMPORTANT)
      if (response['downloadUrl'] != null) {
        uploadedUrl = response['downloadUrl'];
      } else if (response['url'] != null) {
        uploadedUrl = response['url'];
      }

      if (uploadedUrl != null) {
        String fileName = filePath.split('/').last;

        dynamicValues[fileId]?.value =
        "$uploadedUrl|$fileName";

        print("✅ FINAL STORED: ${dynamicValues[fileId]?.value}");

        Get.snackbar(
          "Success",
          "File uploaded successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

      } else {
        print("❌ URL NOT FOUND IN RESPONSE");

        Get.snackbar(
          "Error",
          "Upload failed: URL missing",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

    } catch (e) {
      print("❌ UPLOAD ERROR: $e");

      Get.snackbar(
        "Error",
        "File upload failed",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
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

        String effectiveType = getEffectiveType(field.type, field.label);

        // 1. Initialize TextEditingControllers for text-based or display-as-text fields
        if (effectiveType == FORM_FIELD_TYPES["LOCATION"]) {
          controller.dynamicControllers["${fieldId}_lat"] = TextEditingController();
          controller.dynamicControllers["${fieldId}_lng"] = TextEditingController();
        } else if (effectiveType == FORM_FIELD_TYPES["TEXT"] ||
            effectiveType == FORM_FIELD_TYPES["NUMBER"] ||
            effectiveType == FORM_FIELD_TYPES["EMAIL"] ||
            effectiveType == FORM_FIELD_TYPES["TEXTAREA"] ||
            effectiveType == FORM_FIELD_TYPES["DATE"] ||
            effectiveType == FORM_FIELD_TYPES["TIME"] ||
            effectiveType == FORM_FIELD_TYPES["LINK"] ||
            effectiveType == FORM_FIELD_TYPES["PHONE"]) {
          controller.dynamicControllers[fieldId] = TextEditingController();
        }

        // 2. Initialize RxString values for state-based fields
        if (effectiveType == FORM_FIELD_TYPES["SELECT"] ||
            effectiveType == FORM_FIELD_TYPES["RADIO"] ||
            effectiveType == FORM_FIELD_TYPES["CHECKBOX"] ||
            effectiveType == FORM_FIELD_TYPES["DATE"] ||
            effectiveType == FORM_FIELD_TYPES["TIME"] ||
            effectiveType == FORM_FIELD_TYPES["SLIDER"] ||
            effectiveType == FORM_FIELD_TYPES["RATING"] ||
            effectiveType == FORM_FIELD_TYPES["FILE"] ||
            effectiveType == FORM_FIELD_TYPES["IMAGE"] ||
            effectiveType == FORM_FIELD_TYPES["VIDEO"] ||
            effectiveType == FORM_FIELD_TYPES["EXCEL"]) {
          controller.dynamicValues[fieldId] = "".obs;
        }
      }

      // Load existing form response if leadContactId is not empty
      if (leadContactId.isNotEmpty) {
        controller.fetchExistingResponse(leadContactId);
      }
    } else {
      print("🔄 Using already primed form: ${controller.formId.value}");
    }

    if (showUI) {
      controller.canClose.value = false; // Lock the form initially
      controller.isFormVisible.value = true;
      try {
        await Get.dialog(
          CallFormPage(),
          barrierDismissible: false,
          barrierColor: Colors.black54,
        );
      } finally {
        controller.isFormVisible.value = false;
        print("📥 CallFormController.show: isFormVisible = false");
      }
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
