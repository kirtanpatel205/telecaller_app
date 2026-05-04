import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/constants/app_dimens.dart';

class CustomDropdown extends StatelessWidget {
  final RxString selectedValue;
  final List<Map<String, String>> items;
  final String hintText;
  final Function(String) onChanged;

  const CustomDropdown({
    Key? key,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    this.hintText = "select_an_option",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: AppColors.themeColor.scaffoldBackgroundColor.withOpacity(Get.isDarkMode ? 0.4 : 0.6),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.themeColor.textPrimaryColor.withOpacity(0.08)),
      ),
      child: Obx(() => DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: AppColors.themeColor.cardColor,
          borderRadius: BorderRadius.circular(16.r),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.themeColor.primaryColor),
          value: selectedValue.value.isEmpty ? null : selectedValue.value,
          hint: Text(
            hintText.tr,
            style: AppTextStyle.bold7.copyWith(
              color: AppColors.themeColor.textPrimaryColor.withOpacity(0.4),
              fontSize: AppDimens.fontSize13,
            ),
          ),
          onChanged: (value) {
            if (value != null) {
              selectedValue.value = value;
              onChanged(value);
            }
          },
          items: items.map<DropdownMenuItem<String>>((option) {
            return DropdownMenuItem<String>(
              value: option["value"],
              child: Text(
                (option["label"] ?? "").tr,
                style: AppTextStyle.bold7.copyWith(
                  color: AppColors.themeColor.textPrimaryColor,
                  fontSize: AppDimens.fontSize14,
                ),
              ),
            );
          }).toList(),
        ),
      )),
    );
  }
}
