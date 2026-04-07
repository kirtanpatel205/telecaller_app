
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_colors.dart';
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
                height: 45,
                child: ValueListenableBuilder(
                  valueListenable: controller ?? TextEditingController(),
                  builder: (context, value, child) {
                    return TextField(
                      textInputAction: TextInputAction.search,
                      controller: controller,
                      style: TextStyle(
                        color: AppColors.themeColor.textPrimaryColor,
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
                        EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        fillColor: AppColors.themeColor.bgColor,
                        filled: true,
                        hintText: "search_name_phone_email".tr,
                        hintStyle: AppTextStyle.medium7.copyWith(
                          color: AppColors.themeColor.textPrimaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        suffixIcon: controller != null &&
                            controller!.text.isNotEmpty
                            ? IconButton(
                          icon: Icon(
                            Icons.close_outlined,
                            color: AppColors.themeColor.textPrimaryColor,
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
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: AppColors.themeColor.primaryColor,
              borderRadius: BorderRadius.circular(5),
            ),
            margin: EdgeInsets.only(right: 7),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 2),
            child: InkWell(
              onTap: onSearch,
              child: Icon(
                Icons.search,
                color: AppColors.themeColor.cardColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
