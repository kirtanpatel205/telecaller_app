import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_dimens.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/core/controllers/call_form_controller.dart';
import 'package:telecaller_app/core/models/all_lead_entity.dart';

class CallFormPage extends StatelessWidget {
  final CallFormController controller = Get.find<CallFormController>();

  CallFormPage({super.key});

  IconData? _getIconForType(String type) {
    if (type == FORM_FIELD_TYPES["LINK"]) return Icons.link_rounded;
    if (type == FORM_FIELD_TYPES["LOCATION"]) return Icons.location_on_outlined;
    if (type == FORM_FIELD_TYPES["NUMBER"]) return Icons.onetwothree_rounded;
    if (type == FORM_FIELD_TYPES["IMAGE"]) return Icons.image_outlined;
    if (type == FORM_FIELD_TYPES["VIDEO"]) return Icons.videocam_outlined;
    if (type == FORM_FIELD_TYPES["EXCEL"]) return Icons.table_chart_outlined;
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Obx(() => PopScope(
      canPop: controller.canClose.value,
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
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
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
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
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: AppColors.themeColor.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.assignment_outlined,
                                color: AppColors.themeColor.primaryColor,
                                size: 24.sp,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(() => Text(
                                    controller.leadId.value.isNotEmpty ? "${"call_feedback:".tr} ${controller.leadId.value}" : "call_survey_form".tr,
                                    style: AppTextStyle.bold7.copyWith(
                                      fontSize: AppDimens.fontSize20,
                                      color: AppColors.themeColor.textPrimaryColor,
                                      letterSpacing: -0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                  SizedBox(height: 2.h),
                                  Text(
                                    "complete_the_following_fields_to_save_call_details".tr,
                                    style: AppTextStyle.regular7.copyWith(
                                      fontSize: AppDimens.fontSize13,
                                      color: AppColors.themeColor.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),

                        // ── Important Notice Banner ───────────────
                        _buildNoticeBanner(),
                        SizedBox(height: 28.h),

                        // ── Dynamic Fields ────────────────────────
                        Obx(
                          () => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: controller.formFields.map((field) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 24.h),
                                child: _buildDynamicField(context, field),
                              );
                            }).toList(),
                          ),
                        ),
                        
                        // ── Bottom Note ───────────────────────────
                        _buildBottomNote(),
                        SizedBox(height: 12.h),
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
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.themeColor.cardBgColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1.5.w),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.remove_red_eye_outlined,
            size: 18.sp,
            color: AppColors.themeColor.primaryColor,
          ),
          SizedBox(width: 10.w),
          Text(
            "form_preview".tr,
            style: AppTextStyle.bold7.copyWith(
              fontSize: AppDimens.fontSize12,
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
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 20.sp, color: Colors.grey),
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
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFD0E3FF), width: 1.w),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.themeColor.primaryColor, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              "please_fill_in_all_required_fields_your_responses_ensure_acc".tr,
              style: AppTextStyle.regular7.copyWith(
                fontSize: AppDimens.fontSize12,
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
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFFEE2E2), width: 1.w),
      ),
      child: Row(
        children: [
          Icon(Icons.info_rounded, color: const Color(0xFFDC2626), size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              "fields_marked_with_are_mandatory_for_submission".tr,
              style: AppTextStyle.medium7.copyWith(
                fontSize: AppDimens.fontSize12,
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
      padding: EdgeInsets.only(bottom: 10.h),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: label,
              style: AppTextStyle.bold7.copyWith(
                fontSize: AppDimens.fontSize14,
                fontWeight: FontWeight.w600,
                color: AppColors.themeColor.textPrimaryColor,
              ),
            ),
            if (isRequired)
              TextSpan(
                text: " *",
                style: AppTextStyle.bold7.copyWith(
                  fontSize: AppDimens.fontSize16,
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
    final String type = (field.type ?? "").toLowerCase();
    final String label = (field.label ?? "untitled_field".tr).toLowerCase();
    final String hint = field.placeholder ?? "Enter ${field.label ?? ''}";
    final bool isRequired = field.required ?? false;
    final String fieldId = field.id ?? "";

    final String effectiveType = CallFormController.getEffectiveType(field.type, field.label);

    if (fieldId.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isRequired),
        if (effectiveType == FORM_FIELD_TYPES["TEXT"] ||
            effectiveType == FORM_FIELD_TYPES["NUMBER"] ||
            effectiveType == FORM_FIELD_TYPES["TEXTAREA"] ||
            effectiveType == FORM_FIELD_TYPES["LINK"])
          _buildTextField(
            controller: controller.dynamicControllers[fieldId],
            hint: hint,
            keyboardType: effectiveType == FORM_FIELD_TYPES["NUMBER"] ? TextInputType.number : TextInputType.text,
            maxLines: (effectiveType == FORM_FIELD_TYPES["TEXTAREA"]) ? 4 : 1,
            prefixIcon: _getIconForType(effectiveType),
            validator: isRequired
                ? (val) => (val == null || val.trim().isEmpty) ? "$label is required" : null
                : null,
          )
        else if (effectiveType == FORM_FIELD_TYPES["LOCATION"])
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: controller.dynamicControllers["${fieldId}_lat"],
                  hint: "Latitude",
                  keyboardType: TextInputType.number,
                  validator: isRequired
                      ? (val) => (val == null || val.trim().isEmpty) ? "Latitude is required" : null
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: controller.dynamicControllers["${fieldId}_lng"],
                  hint: "Longitude",
                  keyboardType: TextInputType.number,
                  validator: isRequired
                      ? (val) => (val == null || val.trim().isEmpty) ? "Longitude is required" : null
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.themeColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: IconButton(
                  icon: Icon(Icons.my_location_rounded, color: AppColors.themeColor.primaryColor, size: 24.sp),
                  onPressed: () => controller.fetchLocation(fieldId),
                ),
              ),
            ],
          )
        else if (effectiveType == FORM_FIELD_TYPES["SELECT"])
          _buildDropdown(
            selectedValue: controller.dynamicValues[fieldId],
            options: field.options ?? [],
            hint: hint,
          )
        else if (effectiveType == FORM_FIELD_TYPES["RADIO"])
          _buildRadioGroup(
            options: field.options ?? [],
            selectedValue: controller.dynamicValues[fieldId],
          )
        else if (effectiveType == FORM_FIELD_TYPES["CHECKBOX"])
          _buildCheckboxGroup(
            options: field.options ?? [],
            selectedValue: controller.dynamicValues[fieldId],
          )
        else if (effectiveType == FORM_FIELD_TYPES["DATE"])
          _buildDateField(context, fieldId, hint)
        else if (effectiveType == FORM_FIELD_TYPES["TIME"])
          _buildTimeField(context, fieldId, hint)
        else if (effectiveType == FORM_FIELD_TYPES["SLIDER"])
          _buildSlider(fieldId)
        else if (effectiveType == FORM_FIELD_TYPES["RATING"])
          _buildRating(fieldId)
        else if (effectiveType == FORM_FIELD_TYPES["FILE"] ||
                 effectiveType == FORM_FIELD_TYPES["IMAGE"] ||
                 effectiveType == FORM_FIELD_TYPES["VIDEO"] ||
                 effectiveType == FORM_FIELD_TYPES["EXCEL"] ||
                 effectiveType.contains("excel") || 
                 effectiveType.contains("file"))
          _buildFilePicker(fieldId, hint, effectiveType)
        else
          Text("Field type '$effectiveType' is currently not supported in UI", style: AppTextStyle.regular7.copyWith(color: Colors.grey.shade400, fontSize: AppDimens.fontSize12)),
      ],
    );
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
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: AppTextStyle.medium7.copyWith(fontSize: AppDimens.fontSize14, color: AppColors.themeColor.textPrimaryColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyle.regular7.copyWith(fontSize: AppDimens.fontSize14, color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.03),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20.sp, color: Colors.grey) : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5.w),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5.w),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.themeColor.primaryColor, width: 1.5.w),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.redAccent, width: 1.5.w),
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200, width: 1.5.w),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedValue.value.isEmpty ? null : selectedValue.value,
          hint: Text(hint, style: AppTextStyle.regular7.copyWith(color: Colors.grey.shade400, fontSize: AppDimens.fontSize14)),
          icon: Icon(Icons.expand_more_rounded, color: Colors.grey, size: 24.sp),
          onChanged: (value) => selectedValue.value = value ?? "",
          items: options.map<DropdownMenuItem<String>>((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option, style: AppTextStyle.medium7.copyWith(fontSize: AppDimens.fontSize14, color: AppColors.themeColor.textPrimaryColor)),
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
      spacing: 12.w,
      runSpacing: 8.h,
      children: options.map((option) {
        final isSelected = selectedValue.value == option;
        return InkWell(
          onTap: () => selectedValue.value = option,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.themeColor.primaryColor.withOpacity(0.08) : Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected ? AppColors.themeColor.primaryColor : Colors.grey.shade200,
                width: 1.5.w,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  size: 18.sp,
                  color: isSelected ? AppColors.themeColor.primaryColor : Colors.grey,
                ),
                SizedBox(width: 8.w),
                Text(
                  option,
                  style: AppTextStyle.medium7.copyWith(
                    fontSize: AppDimens.fontSize14,
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
        spacing: 12.w,
        runSpacing: 8.h,
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
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.themeColor.primaryColor.withOpacity(0.08) : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? AppColors.themeColor.primaryColor : Colors.grey.shade200,
                  width: 1.5.w,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                    size: 18.sp,
                    color: isSelected ? AppColors.themeColor.primaryColor : Colors.grey,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    option,
                    style: AppTextStyle.medium7.copyWith(
                      fontSize: AppDimens.fontSize14,
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
      suffixIcon: Icon(Icons.calendar_today_rounded, size: 18.sp, color: AppColors.themeColor.primaryColor),
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
      suffixIcon: Icon(Icons.access_time_rounded, size: 18.sp, color: AppColors.themeColor.primaryColor),
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
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("0", style: AppTextStyle.regular7.copyWith(color: Colors.grey, fontSize: AppDimens.fontSize12)),
                Text(rx.value, style: AppTextStyle.bold7.copyWith(color: AppColors.themeColor.primaryColor, fontSize: AppDimens.fontSize14)),
                Text("100", style: AppTextStyle.regular7.copyWith(color: Colors.grey, fontSize: AppDimens.fontSize12)),
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
              size: 32.sp,
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
    String displayHint = "Upload Document (Max 2MB)";

    if (type == FORM_FIELD_TYPES["IMAGE"]) {
      icon = Icons.image_outlined;
      accentColor = Colors.blue;
      displayHint = "Upload Image (Max 5MB)";
    } else if (type == FORM_FIELD_TYPES["VIDEO"]) {
      icon = Icons.videocam_outlined;
      accentColor = Colors.purple;
      displayHint = "Upload Video (Max 5MB)";
    } else if (type == FORM_FIELD_TYPES["EXCEL"]) {
      icon = Icons.table_chart_outlined;
      accentColor = Colors.green;
      displayHint = "Upload Excel Sheet (.xls, .csv)\nMax 2MB";
    }

    // Default to the provided hint if it's uniquely set by backend, else use our smart hint
    if (hint.isNotEmpty && hint.toLowerCase() != "upload" && !hint.toLowerCase().contains("select")) {
      displayHint = hint;
    }

    return Obx(() {
      final isSelected = rx.value.isNotEmpty;
      return InkWell(
        onTap: () => controller.pickMedia(fieldId, type),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: isSelected ? accentColor.withOpacity(0.04) : Colors.grey.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? accentColor : Colors.grey.shade200,
              width: 1.5.w,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isSelected ? accentColor.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: isSelected ? accentColor : Colors.grey, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSelected 
                        ? (rx.value.contains('|') ? rx.value.split('|').last : rx.value) 
                        : displayHint,
                      style: AppTextStyle.medium7.copyWith(
                        fontSize: AppDimens.fontSize14,
                        color: isSelected ? AppColors.themeColor.textPrimaryColor : Colors.grey.shade400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isSelected)
                      Text(
                        "tap_to_change_file".tr,
                        style: AppTextStyle.regular7.copyWith(fontSize: AppDimens.fontSize11, color: accentColor.withOpacity(0.7)),
                      ),
                  ],
                ),
              ),
              if (isSelected)
                IconButton(
                  onPressed: () => rx.value = "",
                  icon: Icon(Icons.close_rounded, color: Colors.redAccent, size: 20.sp),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              else
                Icon(Icons.add_circle_outline_rounded, color: Colors.grey.shade400, size: 20.sp),
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
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.themeColor.cardBgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, -5.h),
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
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                side: BorderSide(color: Colors.grey.shade300, width: 1.5.w),
              ),
              child: Text(
                "cancel".tr,
                style: AppTextStyle.bold7.copyWith(fontSize: AppDimens.fontSize14, color: AppColors.themeColor.textSecondaryColor),
              ),
            ),
          ),
          SizedBox(width: 16.w),

          // ── Save & Submit Button ──────────────────────
          Expanded(
            flex: 2,
            child: Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : () => controller.onSaveAndSubmit(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.themeColor.primaryColor,
                foregroundColor: AppColors.themeColor.cardColor,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
              child: controller.isLoading.value
                ? SizedBox(width: 20.sp, height: 20.sp, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.themeColor.cardColor))
                : Text("save_submit".tr, style: AppTextStyle.bold7.copyWith(fontSize: AppDimens.fontSize15, color: AppColors.themeColor.cardColor)),
            )),
          ),
        ],
      ),
    );
  }
}
