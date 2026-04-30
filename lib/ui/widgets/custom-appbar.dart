import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_dimens.dart';
import 'package:telecaller_app/constants/app_text_style.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final Widget? title;
  final String? titleText;
  final List<Widget>? actions;
  final double height;
  final bool showBackButton;

  const CustomAppBar({
    Key? key,
    this.actions,
    this.leading,
    this.title,
    this.bottom,
    this.height = kToolbarHeight,
    this.titleText,
    this.showBackButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leading: leading ?? (showBackButton ? _buildBackButton() : null),
      title: title ??
          Text(
            titleText ?? "",
            style: AppTextStyle.appBarTitleStyle.copyWith(
              color: AppColors.themeColor.textPrimaryColor,
              fontSize: AppDimens.fontSize18,
              fontWeight: FontWeight.bold,
            ),
          ),
      actions: actions ?? [],
      bottom: bottom,
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: EdgeInsets.all(10.w),
      child: InkWell(
        onTap: () => Get.back(),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.themeColor.primaryColor.withOpacity(0.05),
            border: Border.all(
              color: AppColors.themeColor.primaryColor.withOpacity(0.2),
              width: 1.w,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18.sp,
            color: AppColors.themeColor.primaryColor,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
