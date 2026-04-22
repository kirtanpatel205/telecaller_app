
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_dimens.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/core/models/language_entity.dart';
import 'package:telecaller_app/ui/views/language/language_controller.dart';
import 'package:telecaller_app/ui/widgets/CustomSearchBar.dart';
import 'package:telecaller_app/ui/widgets/app_safe_area.dart';
import 'package:telecaller_app/ui/widgets/custom-appbar.dart';

class LanguagePage extends GetView<LanguageController> {
  @override
  Widget build(BuildContext context) {
    return AppSafeArea(child: Scaffold(
      backgroundColor: AppColors.themeColor.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        titleText: "languageandregion".tr,
        actions: [
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Icon(
                Icons.more_horiz,
                color: Colors.transparent,
                size: 24.sp,
              ),
            ),
            
        ],
      ),
      body: Column(
        children: [
            CustomSearchBar(
              controller: controller.searchlangController,
              onSearch: () {
                controller.onSearch();
              },
            ),
          Expanded(
            child: Card(
                margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                color: AppColors.themeColor.cardBgColor,
                child: Obx(
                  () => ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.filteredLanguages.length,
                    itemBuilder: (context, index) {
                      LanguageEntity lang = controller.filteredLanguages[index];

                      return ListTile(
                        onTap: () => controller.onChangeLang(index),
                        title: Text(
                          lang.name!,
                          style: AppTextStyle.medium7.copyWith(
                            fontSize: AppDimens.fontSize14,
                            color: AppColors.themeColor.textPrimaryColor,
                          ),
                        ),
                        leading: Obx(() {
                          int actualIndex =
                              controller.langService.langs.value.indexOf(lang);
                          return Radio<int>(
                            value: actualIndex,
                            groupValue: controller.selectedLanguage.value,
                            onChanged: (value) {
                              controller.onChangeLang(index);
                              // Get.back();
                            },
                          );
                        }),
                      );
                    },
                  ),
                )),
          ),
        ],
      ),
    ));
  }
}
