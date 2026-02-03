import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_text_style.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onClick;
  final String title;
  final bool enabled;
  final bool isLoading;

  CustomButton({
    Key? key,
    required this.onClick,
    required this.title,
    this.enabled = true,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: (enabled && !isLoading) ? onClick : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled
              ? AppColors.themeColor.primaryColor
              : AppColors.themeColor.primaryColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          disabledBackgroundColor: AppColors.themeColor.primaryColor.withOpacity(0.5),
        ),
        child: isLoading
            ? CircularProgressIndicator(
          color: AppColors.themeColor.cardColor,
        )
            : Text(
          title,
          style: AppTextStyle.buttonTextStyle,
        ),
      ),
    );
  }
}