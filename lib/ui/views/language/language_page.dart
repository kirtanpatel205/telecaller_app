
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
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: AppColors.themeColor.scaffoldBackgroundColor,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── Branded Header ─────────────────────────────────────────
            SliverCustomAppBar(
              titleText: "language".tr,
              pinned: true,
              floating: true,
            ),

            // ─── Search Bar Section ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomSearchBar(
                      controller: controller.searchlangController,
                      onSearch: controller.onSearch,
                    ),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),

            // ─── Language List Section ───────────────────────────────────
            Obx(() {
              if (controller.filteredLanguages.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.translate_rounded,
                          size: 64.sp,
                          color: AppColors.themeColor.textSecondaryColor
                              .withOpacity(0.2),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "no_language_found".tr,
                          style: AppTextStyle.medium7.copyWith(
                            color: AppColors.themeColor.textSecondaryColor,
                            fontSize: AppDimens.fontSize14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final lang = controller.filteredLanguages[index];
                      final isSelected = controller.selectedLanguage.value ==
                          controller.langService.langs.value.indexOf(lang);

                      return _LanguageTile(
                        lang: lang,
                        isSelected: isSelected,
                        onTap: () => controller.onChangeLang(index),
                      );
                    },
                    childCount: controller.filteredLanguages.length,
                  ),
                ),
              );
            }),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

// ─── Internal Widgets ──────────────────────────────────────────────────────

class _LanguageTile extends StatelessWidget {
  final LanguageEntity lang;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.lang,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.themeColor.primaryColor;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withOpacity(0.08)
                : AppColors.themeColor.cardColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isSelected
                  ? primaryColor.withOpacity(0.4)
                  : AppColors.themeColor.bordercolror.withOpacity(0.1),
              width: 1.5.w,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: primaryColor.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              else
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              // Branded Initial Circle
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSelected
                        ? [primaryColor, primaryColor.withOpacity(0.8)]
                        : [
                            primaryColor.withOpacity(0.15),
                            primaryColor.withOpacity(0.05)
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    (lang.name ?? "U").substring(0, 1).toUpperCase(),
                    style: AppTextStyle.bold9.copyWith(
                      color: isSelected ? Colors.white : primaryColor,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              // Language Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.name ?? "",
                      style: AppTextStyle.bold7.copyWith(
                        fontSize: AppDimens.fontSize15,
                        color: isSelected
                            ? primaryColor
                            : AppColors.themeColor.textPrimaryColor,
                      ),
                    ),
                    if (lang.key != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        lang.key!.toUpperCase(),
                        style: AppTextStyle.medium7.copyWith(
                          fontSize: AppDimens.fontSize11,
                          color: isSelected
                              ? primaryColor.withOpacity(0.7)
                              : AppColors.themeColor.textSecondaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Modern Selection Check
              AnimatedScale(
                scale: isSelected ? 1.0 : 0.8,
                duration: const Duration(milliseconds: 200),
                child: AnimatedOpacity(
                  opacity: isSelected ? 1.0 : 0.3,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_off_rounded,
                    color: isSelected
                        ? primaryColor
                        : AppColors.themeColor.textSecondaryColor,
                    size: 24.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
