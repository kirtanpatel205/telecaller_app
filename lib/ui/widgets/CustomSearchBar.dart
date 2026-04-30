
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_dimens.dart';
import 'package:telecaller_app/constants/app_text_style.dart';

import 'custom_card.dart';


class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final VoidCallback? onSearch;

  const CustomSearchBar({
    Key? key,
    this.controller,
    this.onSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Row(
        children: [
          Expanded(
            child: CustomCard(
              child: SizedBox(
                height: 45.h,
                child: ValueListenableBuilder(
                  valueListenable: controller ?? TextEditingController(),
                  builder: (context, value, child) {
                    return TextField(
                      textInputAction: TextInputAction.search,
                      controller: controller,
                      style: TextStyle(
                        color: AppColors.themeColor.textPrimaryColor,
                        fontSize: AppDimens.fontSize14,
                      ),
                      onChanged: (_) {
                        if (onSearch != null) {
                          onSearch!();
                        }
                      },
                      onSubmitted: (_) {
                        if (onSearch != null) {
                          onSearch!();
                        }
                      },
                      decoration: InputDecoration(
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(5.r)),
                        ),
                        fillColor: AppColors.themeColor.bgColor,
                        filled: true,
                        hintText: "search_name_phone_email".tr,
                        hintStyle: AppTextStyle.medium7.copyWith(
                          color: AppColors.themeColor.textPrimaryColor,
                          fontWeight: FontWeight.w400,
                          fontSize: AppDimens.fontSize14,
                        ),
                        suffixIcon: controller != null &&
                            controller!.text.isNotEmpty
                            ? IconButton(
                          icon: Icon(
                            Icons.close_outlined,
                            color: AppColors.themeColor.textPrimaryColor,
                            size: 20.sp,
                          ),
                          onPressed: () {
                            controller!.clear();
                            if (onSearch != null) {
                              onSearch!();
                            }
                          },
                        )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Container(
            height: 45.h,
            width: 45.w,
            decoration: BoxDecoration(
              color: AppColors.themeColor.primaryColor,
              borderRadius: BorderRadius.circular(5.r),
            ),
            margin: EdgeInsets.only(right: 7.w),
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 2.w),
            child: InkWell(
              onTap: onSearch,
              child: Icon(
                Icons.search,
                color: AppColors.themeColor.onPrimaryColor,
                size: 24.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
