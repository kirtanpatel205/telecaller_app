import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_text_style.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onClick;
  final String title;
  final bool enabled;
  final bool isLoading;

  const CustomButton({
    Key? key,
    required this.onClick,
    required this.title,
    this.enabled = true,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56, // Increased height for premium feel
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: enabled && !isLoading
            ? LinearGradient(
                colors: [
                  AppColors.themeColor.primaryColor,
                  AppColors.themeColor.primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: !enabled || isLoading 
            ? AppColors.themeColor.primaryColor.withOpacity(0.4)
            : null,
        boxShadow: enabled && !isLoading
            ? [
                BoxShadow(
                  color: AppColors.themeColor.primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (enabled && !isLoading) ? onClick : null,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.themeColor.onPrimaryColor,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    title,
                    style: AppTextStyle.buttonTextStyle.copyWith(
                      color: AppColors.themeColor.onPrimaryColor,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}