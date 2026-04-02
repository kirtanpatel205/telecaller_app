
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_colors.dart';
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
              padding: const EdgeInsets.all(10.0),
              child: Icon(
                Icons.more_horiz,
                color: Colors.transparent,
                size: 24,
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
                margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                color: AppColors.themeColor.cardColor,
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
                          style: AppTextStyle.regular7.copyWith(
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
