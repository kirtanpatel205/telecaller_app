import 'package:flutter/material.dart';
import 'package:telecaller_app/constants/app_colors.dart';

class CustomActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isFullWidth;

  const CustomActionButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: isFullWidth?18:12),
      label: Text(title,style: TextStyle(fontSize: isFullWidth?15:8),),
      style: ElevatedButton.styleFrom(
        elevation: 0,


        /// Style Control
        backgroundColor: isPrimary
            ? AppColors.themeColor.primaryColor
            : Colors.transparent,

        foregroundColor:
        isPrimary ? Colors.white : AppColors.themeColor.textPrimaryColor,

        side: isPrimary
            ? BorderSide.none
            : BorderSide(color: AppColors.themeColor.bordercolror),

        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 12,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    /// Width Control
    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}
