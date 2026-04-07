import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/core/controllers/call_form_controller.dart';
import 'package:telecaller_app/core/models/all_lead_entity.dart';

class CallFormPage extends StatelessWidget {
  final CallFormController controller = Get.find<CallFormController>();

  CallFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => PopScope(
      canPop: controller.canClose.value,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 12,
        clipBehavior: Clip.antiAlias,
        child: Container(
          color: AppColors.themeColor.cardBgColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header Bar ────────────────────────────────────────
              _buildHeader(),

              // ── Scrollable Body ───────────────────────────────────
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Form Title Section ────────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.themeColor.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.assignment_outlined,
                                color: AppColors.themeColor.primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(() => Text(
                                    controller.leadId.value.isNotEmpty ? "Call Feedback: ${controller.leadId.value}" : "call_survey_form".tr,
                                    style: AppTextStyle.bold11.copyWith(
                                      fontSize: 20,
                                      color: AppColors.themeColor.textPrimaryColor,
                                      letterSpacing: -0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                  const SizedBox(height: 2),
                                  Text(
                                    "complete_the_following_fields_to_save_call_details".tr,
                                    style: AppTextStyle.regular5.copyWith(
                                      fontSize: 13,
                                      color: AppColors.themeColor.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ── Important Notice Banner ───────────────
                        _buildNoticeBanner(),
                        const SizedBox(height: 28),

                        // ── Dynamic Fields ────────────────────────
                        Obx(
                          () => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: controller.formFields.map((field) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: _buildDynamicField(context, field),
                              );
                            }).toList(),
                          ),
                        ),
                        
                        // ── Bottom Note ───────────────────────────
                        _buildBottomNote(),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Footer Buttons ────────────────────────────────────
              _buildFooter(),
            ],
          ),
        ),
      ),
    ));
  }

  // ─────────────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.themeColor.cardBgColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.remove_red_eye_outlined,
            size: 18,
            color: AppColors.themeColor.primaryColor,
          ),
          const SizedBox(width: 10),
          Text(
            "form_preview".tr,
            style: AppTextStyle.bold11.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.themeColor.textSecondaryColor,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              controller.canClose.value = true;
              Get.back();
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 20, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // NOTICE BANNER
  // ─────────────────────────────────────────────────────────────────
  Widget _buildNoticeBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD0E3FF), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.themeColor.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "please_fill_in_all_required_fields_your_responses_ensure_acc".tr,
              style: AppTextStyle.regular5.copyWith(
                fontSize: 12.5,
                color: const Color(0xFF2C5282),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // BOTTOM NOTE
  // ─────────────────────────────────────────────────────────────────
  Widget _buildBottomNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFEE2E2), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_rounded, color: Color(0xFFDC2626), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "fields_marked_with_are_mandatory_for_submission".tr,
              style: AppTextStyle.medium8.copyWith(
                fontSize: 12,
                color: const Color(0xFF991B1B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // REQUIRED LABEL
  // ─────────────────────────────────────────────────────────────────
  Widget _buildLabel(String label, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: label,
              style: AppTextStyle.semiBold11.copyWith(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: AppColors.themeColor.textPrimaryColor,
              ),
            ),
            if (isRequired)
              TextSpan(
                text: " *",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // DYNAMIC FIELD BUILDER
  // ─────────────────────────────────────────────────────────────────
  Widget _buildDynamicField(
    BuildContext context,
    AllLeadLeadsFormIdFields field,
  ) {
    final String type = field.type ?? "";
    final String label = field.label ?? "untitled_field".tr;
    final String hint = field.placeholder ?? "Enter $label";
    final bool isRequired = field.required ?? false;
    final String fieldId = field.id ?? "";

    if (fieldId.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isRequired),
        if (type == FORM_FIELD_TYPES["TEXT"] ||
            type == FORM_FIELD_TYPES["NUMBER"] ||
            type == FORM_FIELD_TYPES["TEXTAREA"] ||
            type == FORM_FIELD_TYPES["LINK"] ||
            type == FORM_FIELD_TYPES["LOCATION"] ||
            type == FORM_FIELD_TYPES["IMAGE"] ||
            type == FORM_FIELD_TYPES["VIDEO"]||type == FORM_FIELD_TYPES["EXCEL"] )
          _buildTextField(
            controller: controller.dynamicControllers[fieldId],
            hint: hint,
            keyboardType: type == FORM_FIELD_TYPES["NUMBER"] ? TextInputType.number : TextInputType.text,
            maxLines: (type == FORM_FIELD_TYPES["TEXTAREA"]) ? 4 : 1,
            prefixIcon: _getIconForType(type),
            validator: isRequired
                ? (val) => (val == null || val.trim().isEmpty) ? "$label is required" : null
                : null,
          )
        else if (type == FORM_FIELD_TYPES["SELECT"])
          _buildDropdown(
            selectedValue: controller.dynamicValues[fieldId],
            options: field.options ?? [],
            hint: hint,
          )
        else if (type == FORM_FIELD_TYPES["RADIO"])
          _buildRadioGroup(
            options: field.options ?? [],
            selectedValue: controller.dynamicValues[fieldId],
          )
        else if (type == FORM_FIELD_TYPES["CHECKBOX"])
          _buildCheckboxGroup(
            options: field.options ?? [],
            selectedValue: controller.dynamicValues[fieldId],
          )
        else if (type == FORM_FIELD_TYPES["DATE"])
          _buildDateField(context, fieldId, hint)
        else if (type == FORM_FIELD_TYPES["TIME"])
          _buildTimeField(context, fieldId, hint)
        else if (type == FORM_FIELD_TYPES["SLIDER"])
          _buildSlider(fieldId)
        else if (type == FORM_FIELD_TYPES["RATING"])
          _buildRating(fieldId)
        else if (type == FORM_FIELD_TYPES["FILE"])
          _buildFilePicker(fieldId, hint, type)
        else
          Text("Field type '$type' is currently not supported in UI", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
      ],
    );
  }

  IconData? _getIconForType(String type) {
    if (type == FORM_FIELD_TYPES["LINK"]) return Icons.link_rounded;
    if (type == FORM_FIELD_TYPES["LOCATION"]) return Icons.location_on_outlined;
    if (type == FORM_FIELD_TYPES["NUMBER"]) return Icons.onetwothree_rounded;
    if (type == FORM_FIELD_TYPES["IMAGE"]) return Icons.image_outlined;
    if (type == FORM_FIELD_TYPES["VIDEO"]) return Icons.videocam_outlined;
    return null;
  }

  // ─────────────────────────────────────────────────────────────────
  // TEXT FIELD
  // ─────────────────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController? controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    IconData? prefixIcon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller ?? TextEditingController(),
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      style: AppTextStyle.medium8.copyWith(fontSize: 14, color: AppColors.themeColor.textPrimaryColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyle.regular5.copyWith(fontSize: 14, color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.03),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20, color: Colors.grey) : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.themeColor.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // DROPDOWN
  // ─────────────────────────────────────────────────────────────────
  Widget _buildDropdown({
    required RxString? selectedValue,
    required List<String> options,
    required String hint,
  }) {
    if (selectedValue == null) return const SizedBox();
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedValue.value.isEmpty ? null : selectedValue.value,
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
          icon: const Icon(Icons.expand_more_rounded, color: Colors.grey),
          onChanged: (value) => selectedValue.value = value ?? "",
          items: options.map<DropdownMenuItem<String>>((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option, style: AppTextStyle.medium8.copyWith(fontSize: 14)),
            );
          }).toList(),
        ),
      ),
    ));
  }

  // ─────────────────────────────────────────────────────────────────
  // RADIO GROUP
  // ─────────────────────────────────────────────────────────────────
  Widget _buildRadioGroup({
    required List<String> options,
    required RxString? selectedValue,
  }) {
    if (selectedValue == null) return const SizedBox();
    return Obx(() => Wrap(
      spacing: 12,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selectedValue.value == option;
        return InkWell(
          onTap: () => selectedValue.value = option,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.themeColor.primaryColor.withOpacity(0.08) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.themeColor.primaryColor : Colors.grey.shade200,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  size: 18,
                  color: isSelected ? AppColors.themeColor.primaryColor : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  option,
                  style: AppTextStyle.medium8.copyWith(
                    fontSize: 14,
                    color: isSelected ? AppColors.themeColor.primaryColor : AppColors.themeColor.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ));
  }

  // ─────────────────────────────────────────────────────────────────
  // CHECKBOX GROUP
  // ─────────────────────────────────────────────────────────────────
  Widget _buildCheckboxGroup({
    required List<String> options,
    required RxString? selectedValue,
  }) {
    if (selectedValue == null) return const SizedBox();
    // For simplicity with RxString, we store as comma-separated
    return Obx(() {
      final List<String> selected = selectedValue.value.isEmpty ? [] : selectedValue.value.split(",");
      return Wrap(
        spacing: 12,
        runSpacing: 8,
        children: options.map((option) {
          final isSelected = selected.contains(option);
          return InkWell(
            onTap: () {
              if (isSelected) {
                selected.remove(option);
              } else {
                selected.add(option);
              }
              selectedValue.value = selected.join(",");
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.themeColor.primaryColor.withOpacity(0.08) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.themeColor.primaryColor : Colors.grey.shade200,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                    size: 18,
                    color: isSelected ? AppColors.themeColor.primaryColor : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    option,
                    style: AppTextStyle.medium8.copyWith(
                      fontSize: 14,
                      color: isSelected ? AppColors.themeColor.primaryColor : AppColors.themeColor.textPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────
  // DATE FIELD
  // ─────────────────────────────────────────────────────────────────
  Widget _buildDateField(BuildContext context, String fieldId, String hint) {
    return _buildTextField(
      controller: controller.dynamicControllers[fieldId],
      hint: hint,
      readOnly: true,
      onTap: () => controller.pickDate(context, fieldId),
      suffixIcon: Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.themeColor.primaryColor),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // TIME FIELD
  // ─────────────────────────────────────────────────────────────────
  Widget _buildTimeField(BuildContext context, String fieldId, String hint) {
    return _buildTextField(
      controller: controller.dynamicControllers[fieldId],
      hint: hint,
      readOnly: true,
      onTap: () => controller.pickTime(context, fieldId),
      suffixIcon: Icon(Icons.access_time_rounded, size: 18, color: AppColors.themeColor.primaryColor),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // SLIDER
  // ─────────────────────────────────────────────────────────────────
  Widget _buildSlider(String fieldId) {
    final rx = controller.dynamicValues[fieldId];
    if (rx == null) return const SizedBox();
    return Obx(() {
      double val = double.tryParse(rx.value) ?? 0.0;
      return Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(Get.context!).copyWith(
              activeTrackColor: AppColors.themeColor.primaryColor,
              inactiveTrackColor: AppColors.themeColor.primaryColor.withOpacity(0.1),
              thumbColor: AppColors.themeColor.primaryColor,
              overlayColor: AppColors.themeColor.primaryColor.withOpacity(0.1),
              trackHeight: 4,
            ),
            child: Slider(
              value: val,
              min: 0,
              max: 100,
              onChanged: (v) => rx.value = v.toStringAsFixed(0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("0", style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text(rx.value, style: AppTextStyle.bold11.copyWith(color: AppColors.themeColor.primaryColor)),
                Text("100", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────
  // RATING
  // ─────────────────────────────────────────────────────────────────
  Widget _buildRating(String fieldId) {
    final rx = controller.dynamicValues[fieldId];
    if (rx == null) return const SizedBox();
    return Obx(() {
      int rating = int.tryParse(rx.value) ?? 0;
      return Row(
        children: List.generate(5, (index) {
          final isSelected = index < rating;
          return IconButton(
            onPressed: () => rx.value = (index + 1).toString(),
            icon: Icon(
              isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
              color: isSelected ? Colors.amber : Colors.grey.shade300,
              size: 32,
            ),
          );
        }),
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────
  // FILE PICKER
  // ─────────────────────────────────────────────────────────────────
  Widget _buildFilePicker(String fieldId, String hint, String type) {
    final rx = controller.dynamicValues[fieldId];
    if (rx == null) return const SizedBox();
    
    IconData icon = Icons.upload_file_rounded;
    Color accentColor = Colors.orange;
    if (type == FORM_FIELD_TYPES["IMAGE"]) {
      icon = Icons.image_outlined;
      accentColor = Colors.blue;
    } else if (type == FORM_FIELD_TYPES["VIDEO"]) {
      icon = Icons.videocam_outlined;
      accentColor = Colors.purple;
    }

    return Obx(() {
      final isSelected = rx.value.isNotEmpty;
      return InkWell(
        onTap: () => controller.pickMedia(fieldId, type),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? accentColor.withOpacity(0.04) : Colors.grey.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? accentColor : Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? accentColor.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: isSelected ? accentColor : Colors.grey, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSelected ? rx.value : hint,
                      style: AppTextStyle.medium8.copyWith(
                        fontSize: 14,
                        color: isSelected ? AppColors.themeColor.textPrimaryColor : Colors.grey.shade400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isSelected)
                      Text(
                        "tap_to_change_file".tr,
                        style: TextStyle(fontSize: 11, color: accentColor.withOpacity(0.7)),
                      ),
                  ],
                ),
              ),
              if (isSelected)
                IconButton(
                  onPressed: () => rx.value = "",
                  icon: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              else
                Icon(Icons.add_circle_outline_rounded, color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────
  // FOOTER
  // ─────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.themeColor.cardBgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Cancel Button ─────────────────────────────
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                controller.canClose.value = true;
                Get.back();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
              child: Text(
                "Cancel",
                style: AppTextStyle.bold11.copyWith(fontSize: 14, color: AppColors.themeColor.textSecondaryColor),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // ── Save & Submit Button ──────────────────────
          Expanded(
            flex: 2,
            child: Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : () => controller.onSaveAndSubmit(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.themeColor.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: controller.isLoading.value
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Text("save_submit".tr, style: AppTextStyle.bold11.copyWith(fontSize: 15, color: Colors.white)),
            )),
          ),
        ],
      ),
    );
  }
}
