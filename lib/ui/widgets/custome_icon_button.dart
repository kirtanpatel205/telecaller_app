import 'package:flutter/material.dart';
import 'package:telecaller_app/constants/app_colors.dart';

class CustomActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isFullWidth;
  final bool showBadge;

  const CustomActionButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
    this.isFullWidth = false,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: isFullWidth ? 18 : 16),
      label: Text(
        title,
        style: TextStyle(
          fontSize: isFullWidth ? 15 : 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: OutlinedButton.styleFrom(
        elevation: 0,
        backgroundColor: isPrimary
            ? AppColors.themeColor.primaryColor
            : Colors.transparent,
        foregroundColor: isPrimary
            ? Colors.white
            : AppColors.themeColor.primaryColor,
        side: BorderSide(
          color: isPrimary
              ? Colors.transparent
              : (showBadge ? AppColors.themeColor.primaryColor : AppColors.themeColor.bordercolror),
          width: 1.2,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isFullWidth ? 24 : 16,
          vertical: isFullWidth ? 14 : 10,
        ),
        shape: const StadiumBorder(),
      ),
    );

    Widget content = showBadge
        ? Stack(
            clipBehavior: Clip.none,
            children: [
              button,
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.themeColor.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.themeColor.primaryColor.withOpacity(0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        : button;

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: content,
      );
    }

    return content;
  }
}
