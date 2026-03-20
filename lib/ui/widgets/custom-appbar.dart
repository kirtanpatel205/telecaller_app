import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_text_style.dart' show AppTextStyle;

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
      backgroundColor:
          //AppColors.themeColor.cardColor,
          Colors.transparent,

      leading: leading ??
          IconButton(
            icon: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.themeColor.primaryColor,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                // child: Transform.rotate(
                // angle: -3.14 / 2,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 20,
                    color: AppColors.themeColor.primaryColor,
                  ),
                ),
                //),
              ),
            ),
            // // icon: Icon(Icons.arrow_back_ios,color: AppColors.themeColor.textPrimaryColor,),
            onPressed: () {
              Get.back();
            },
          ),

      title: Center(
          child: title ??
              Text(
                this.titleText ?? "",
                style: AppTextStyle.appBarTitleStyle.copyWith(
                    color: AppColors.themeColor.textPrimaryColor, fontSize: 15),
              )), // Empty title
      actions: actions ?? [],
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
