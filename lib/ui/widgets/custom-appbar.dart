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

  const CustomAppBar({
    Key? key,
    this.actions,
    this.leading,
    this.title,
    this.bottom,
    this.height = kToolbarHeight,
    this.titleText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leading: leading ??
          Padding(
            padding: EdgeInsets.all(8.w),
            child: InkWell(
              onTap: () => Get.back(),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.themeColor.primaryColor,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(left: 6.w),
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 16.sp,
                      color: AppColors.themeColor.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
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

  @override
  Size get preferredSize => Size.fromHeight(height);
}
