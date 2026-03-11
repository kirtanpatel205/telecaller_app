import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/core/controllers/call_form_controller.dart';

class CallFormPage extends StatelessWidget {
  final CallFormController controller = Get.find<CallFormController>();

  CallFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header Bar ────────────────────────────────────────
            _buildHeader(),

            // ── Scrollable Body ───────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Title ─────────────────────────────────
                      Text(
                        "Customer Lead Form",
                        style: AppTextStyle.semiBold8.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.themeColor.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Form to collect customer lead details",
                        style: AppTextStyle.regular5.copyWith(
                          fontSize: 13,
                          color: AppColors.themeColor.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Important Notice Banner ───────────────
                      _buildNoticeBanner(),
                      const SizedBox(height: 24),

                      // ── Full Name ─────────────────────────────
                      _buildRequiredLabel("Full Name"),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: controller.fullNameController,
                        hint: "Enter full name",
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Full name is required";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // ── Phone Number ──────────────────────────
                      _buildRequiredLabel("Phone Number"),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: controller.phoneNumberController,
                        hint: "Enter phone number",
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(15),
                        ],
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Phone number is required";
                          }
                          if (val.trim().length < 10) {
                            return "Enter a valid phone number";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // ── Interested Product ────────────────────
                      _buildRequiredLabel("Interested Product"),
                      const SizedBox(height: 8),
                      _buildDropdown(
                        selectedValue: controller.selectedProduct,
                        items: controller.productOptions,
                        hint: "Select a product",
                      ),
                      const SizedBox(height: 20),

                      // ── Contact Preference ────────────────────
                      _buildRequiredLabel("Contact Preference"),
                      const SizedBox(height: 8),
                      _buildRadioGroup(
                        options: controller.contactPreferences,
                        selectedValue: controller.selectedContactPreference,
                      ),
                      const SizedBox(height: 20),

                      // ── Documents Available ───────────────────
                      Text(
                        "Documents Available",
                        style: AppTextStyle.semiBold8.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.themeColor.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildRadioGroup(
                        options: controller.documentOptions,
                        selectedValue: controller.selectedDocument,
                      ),
                      const SizedBox(height: 20),

                      // ── Preferred Callback Date ───────────────
                      Text(
                        "Preferred Callback Date",
                        style: AppTextStyle.semiBold8.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.themeColor.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDateField(context),
                      const SizedBox(height: 20),

                      // ── Customer Interest Level ───────────────
                      Text(
                        "Customer Interest Level",
                        style: AppTextStyle.semiBold8.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.themeColor.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDropdown(
                        selectedValue: controller.selectedInterestLevel,
                        items: controller.interestLevelOptions,
                        hint: "Enter customer interest level",
                      ),
                      const SizedBox(height: 10),
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
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // HEADER — "Form Preview" bar with close button
  // ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.themeColor.cardColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.settings, size: 18, color: AppColors.themeColor.textSecondaryColor),
          const SizedBox(width: 8),
          Text(
            "Form Preview",
            style: AppTextStyle.semiBold8.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.themeColor.textPrimaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "* Required Fields",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.red[600],
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () => Get.back(),
            child: Icon(
              Icons.close,
              size: 20,
              color: AppColors.themeColor.textSecondaryColor,
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFE082), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Colors.orange[700], size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Important Notice",
                  style: AppTextStyle.semiBold8.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Please fill in all required fields before submitting. Your data will be saved and can be edited later.",
                  style: AppTextStyle.regular5.copyWith(
                    fontSize: 12,
                    color: Colors.orange[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // REQUIRED LABEL — red asterisk before and after label
  // ─────────────────────────────────────────────────────────────────
  Widget _buildRequiredLabel(String label) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "* ",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
            ),
          ),
          TextSpan(
            text: "$label ",
            style: AppTextStyle.semiBold8.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.themeColor.textPrimaryColor,
            ),
          ),
          TextSpan(
            text: "*",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // TEXT FIELD
  // ─────────────────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyle.medium8.copyWith(
          fontSize: 14,
          color: AppColors.themeColor.textSecondaryColor,
        ),
        filled: true,
        fillColor: const Color(0xFFFFFDE7),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: const Color(0xFFFFE082), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: const Color(0xFFFFE082), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.themeColor.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // DROPDOWN
  // ─────────────────────────────────────────────────────────────────
  Widget _buildDropdown({
    required RxString selectedValue,
    required List<Map<String, String>> items,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDE7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFE082), width: 1),
      ),
      child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedValue.value.isEmpty ? null : selectedValue.value,
              hint: Text(
                hint,
                style: AppTextStyle.medium8.copyWith(
                  fontSize: 14,
                  color: AppColors.themeColor.textSecondaryColor,
                ),
              ),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.themeColor.textSecondaryColor,
              ),
              onChanged: (value) {
                if (value != null) {
                  selectedValue.value = value;
                }
              },
              items: items.map<DropdownMenuItem<String>>((option) {
                return DropdownMenuItem<String>(
                  value: option["value"],
                  child: Text(
                    option["label"] ?? "",
                    style: AppTextStyle.medium8.copyWith(
                      fontSize: 14,
                      color: AppColors.themeColor.textPrimaryColor,
                    ),
                  ),
                );
              }).toList(),
            ),
          )),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // RADIO GROUP
  // ─────────────────────────────────────────────────────────────────
  Widget _buildRadioGroup({
    required List<String> options,
    required RxString selectedValue,
  }) {
    return Obx(() => Column(
          children: options.map((option) {
            final isSelected = selectedValue.value == option;
            return InkWell(
              onTap: () => selectedValue.value = option,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Colors.green
                              : AppColors.themeColor.textSecondaryColor,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      option,
                      style: AppTextStyle.medium8.copyWith(
                        fontSize: 14,
                        color: AppColors.themeColor.textPrimaryColor,
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
  // DATE FIELD
  // ─────────────────────────────────────────────────────────────────
  Widget _buildDateField(BuildContext context) {
    return _buildTextField(
      controller: controller.callbackDateController,
      hint: "Enter preferred callback date",
      readOnly: true,
      onTap: () => controller.pickCallbackDate(context),
      suffixIcon: InkWell(
        onTap: () => controller.pickCallbackDate(context),
        child: Icon(
          Icons.calendar_month,
          color: AppColors.themeColor.textSecondaryColor,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // FOOTER — Cancel + Save & Submit buttons
  // ─────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.themeColor.cardColor,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // ── Cancel Button ─────────────────────────────
          InkWell(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.close, size: 16, color: AppColors.themeColor.textPrimaryColor),
                  const SizedBox(width: 6),
                  Text(
                    "Cancel",
                    style: AppTextStyle.medium8.copyWith(
                      fontSize: 13,
                      color: AppColors.themeColor.textPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // ── Save & Submit Button ──────────────────────
          Obx(() => InkWell(
                onTap: controller.isLoading.value
                    ? null
                    : () => controller.onSaveAndSubmit(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      controller.isLoading.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save, size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        "Save & Submit",
                        style: AppTextStyle.medium8.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
