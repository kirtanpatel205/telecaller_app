import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_text_style.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onClick;
  final String title;
  final bool enabled;

  CustomButton({
    Key? key,
    required this.onClick,
    required this.title,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GFButton(
      text: this.title,
      color: enabled
          ? AppColors.themeColor.primaryColor
          : AppColors.themeColor.primaryColor.withOpacity(0.5),
      fullWidthButton: true,
      size: 50,
      textStyle: AppTextStyle.buttonTextStyle,
      borderShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      shape: GFButtonShape.standard,
      onPressed: enabled ? this.onClick : null,
    );
  }
}