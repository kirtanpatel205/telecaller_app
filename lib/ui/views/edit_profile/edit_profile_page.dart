import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_dimens.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/core/controllers/auth_controller.dart';
import 'package:telecaller_app/core/helpers/utils.dart';
import 'package:telecaller_app/core/services/theme_service.dart';
import 'package:telecaller_app/ui/widgets/app_safe_area.dart';
import 'package:telecaller_app/ui/widgets/custom-appbar.dart';
import 'package:telecaller_app/ui/widgets/custom_button.dart';
import 'package:telecaller_app/ui/widgets/custome_text_filed.dart';

import 'edit_profile_controller.dart';

class EditProfilePage extends GetView<EditProfileController> {
  AuthController authController = Get.find();
  @override
  Widget build(BuildContext context) {
    return AppSafeArea(
        top: false,
        child: Obx(() => Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar(
          titleText: "editProfile".tr,
        ),
        body: controller.isLoading.value
            ? Utils.loading
            : SingleChildScrollView(
                child: Form(
                  key: controller.formKey,
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 80.h,
                                  width: 80.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.themeColor.cardColor,
                                    border: Border.all(
                                      color: AppColors.themeColor.primaryColor.withOpacity(0.2),
                                      width: 2.w,
                                    ),
                                  ),

                                  // padding: EdgeInsets.all(2),
                                  clipBehavior: Clip
                                      .antiAlias, // ensures child respects circle shape
                                  child: controller.imagepath.value.isNotEmpty
                                      ? Image.file(
                                          File(controller.imagepath.value),
                                          fit: BoxFit.cover,
                                        )
                                      : controller.authController.profile.value
                                                  ?.profile?.isNotEmpty ==
                                              true
                                          ? Image.network(
                                              "https://api-test.digibulkmarketing.com${controller.authController.profile.value!.profile!}",
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return const Icon(Icons.error);
                                              },
                                            )
                                          : Center(
                                              child: Text(
                                                controller
                                                            .authController
                                                            .profile
                                                            .value
                                                            ?.name
                                                            ?.isNotEmpty ==
                                                        true
                                                    ? controller.authController
                                                        .profile.value!.name![0]
                                                    : "no_name".tr,
                                                style: AppTextStyle.regular12
                                                    .copyWith(
                                                  fontSize: 40,
                                                  color: AppColors
                                                      .themeColor.primaryColor,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                ),

                                // if (controller.imagepath.value ==
                                //     "null") ...[
                                Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: InkWell(
                                        onTap: () {
                                          Get.bottomSheet(
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                                              decoration: BoxDecoration(
                                                color: AppColors.themeColor.cardColor,
                                                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.1),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, -2),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "select_image".tr,
                                                    style: AppTextStyle.bold11.copyWith(
                                                      fontSize: 18.sp,
                                                      color: AppColors.themeColor.textPrimaryColor,
                                                    ),
                                                  ),
                                                  SizedBox(height: 20.h),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          if (Get.isBottomSheetOpen ?? false) Get.back();
                                                          controller.getImage1();
                                                        },
                                                        borderRadius: BorderRadius.circular(16.r),
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                              padding: EdgeInsets.all(16.w),
                                                              decoration: BoxDecoration(
                                                                color: AppColors.themeColor.primaryColor.withOpacity(0.1),
                                                                shape: BoxShape.circle,
                                                              ),
                                                              child: Icon(Icons.camera_alt_rounded, color: AppColors.themeColor.primaryColor, size: 28.sp),
                                                            ),
                                                            SizedBox(height: 8.h),
                                                            Text(
                                                              "openCamera".tr,
                                                              style: AppTextStyle.medium7.copyWith(
                                                                fontSize: 14.sp,
                                                                color: AppColors.themeColor.textPrimaryColor,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          if (Get.isBottomSheetOpen ?? false) Get.back();
                                                          controller.getImage();
                                                        },
                                                        borderRadius: BorderRadius.circular(16.r),
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                              padding: EdgeInsets.all(16.w),
                                                              decoration: BoxDecoration(
                                                                color: Colors.purple.withOpacity(0.1),
                                                                shape: BoxShape.circle,
                                                              ),
                                                              child: Icon(Icons.photo_library_rounded, color: Colors.purple, size: 28.sp),
                                                            ),
                                                            SizedBox(height: 8.h),
                                                            Text(
                                                              "openGallery".tr,
                                                              style: AppTextStyle.medium7.copyWith(
                                                                fontSize: 14.sp,
                                                                color: AppColors.themeColor.textPrimaryColor,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 12.h),
                                                ],
                                              ),
                                            ),
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                          );
                                        },

                                        child: Container(
                                          padding: EdgeInsets.all(8.w),
                                          decoration: BoxDecoration(
                                            color: AppColors.themeColor.primaryColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2.w),
                                          ),
                                          child: Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 16.sp,
                                          ),
                                        )))
                                // ]
                              ],
                            ),
                            SizedBox(
                              width: 20.w,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller
                                          .authController.profile.value?.name ??
                                      "no_name".tr,
                                  style: AppTextStyle.bold7.copyWith(
                                      color: AppColors.themeColor.textPrimaryColor,
                                      fontSize: AppDimens.fontSize18),
                                ),
                                Text(
                                  controller.authController.profile.value
                                          ?.phone ??
                                      "",
                                  style: AppTextStyle.medium7.copyWith(
                                      color: AppColors.themeColor.textSecondaryColor,
                                      fontSize: AppDimens.fontSize12),
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "name".tr,
                              style: AppTextStyle.bold7.copyWith(
                                  color: AppColors.themeColor.textPrimaryColor,
                                  fontSize: AppDimens.fontSize14),
                            ),
                            SizedBox(
                              height: 8.h,
                            ),
                            CustomTextFormField(
                              hint: "enter_name".tr,
                              controller: controller.firstNameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "name_required".tr;
                                } else {
                                  bool fullName = RegExp(r'^[a-zA-Z\s\-]+$')
                                      .hasMatch(value);
                                  if (!fullName) {
                                    return "enter_valid_name".tr;
                                  }
                                }
                                return null;
                              },
                            )


                          ],
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        Text(
                          "email".tr,
                          style: AppTextStyle.bold7.copyWith(
                              color: AppColors.themeColor.textPrimaryColor,
                              fontSize: AppDimens.fontSize14),
                        ),
                        CustomTextFormField(
                          hint: "enter_email".tr,
                          inputType: TextInputType.emailAddress,
                          controller: controller.emailAddressController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'email_required'.tr;
                            } else {
                              bool emailValid = RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(value);
                              if (!emailValid) {
                                return 'enter_valid_email'.tr;
                              }
                            }
                            return null;
                          },
                        ).paddingOnly(top: 5),


                        SizedBox(
                          height: 20.h,
                        ),
                        Text(
                          "address".tr,
                          style: AppTextStyle.bold7
                              .copyWith(fontSize: AppDimens.fontSize16, color: AppColors.themeColor.textPrimaryColor),
                        ),
                        SizedBox(
                          height: 12.h,
                        ),
                        Text(
                          "addressLine1".tr,
                          style: AppTextStyle.bold7.copyWith(
                            color: AppColors.themeColor.textPrimaryColor,
                            fontSize: AppDimens.fontSize14,
                          ),
                        ),
                        CustomTextFormField(
                          hint: "enter_address_line_1".tr,
                          controller: controller.addressLine1Controller,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "address_line_1_required".tr;
                            }
                            return null;
                          },
                        ).paddingOnly(top: 5),


                        SizedBox(
                          height: 15.h,
                        ),
                        Text(
                          "addressLine2".tr ,
                          style: AppTextStyle.bold7.copyWith(
                            color: AppColors.themeColor.textPrimaryColor,
                            fontSize: AppDimens.fontSize14,
                          ),
                        ),
                        CustomTextFormField(
                          hint: "enter_address_line_2".tr,
                          controller: controller.addressLine2Controller,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "address_line_2_required".tr;
                            }
                            return null;
                          },
                        ).paddingOnly(top: 5),


                        SizedBox(
                          height: 15.h,
                        ),
                        Text(
                          "city".tr,
                          style: AppTextStyle.bold7.copyWith(
                            color: AppColors.themeColor.textPrimaryColor,
                            fontSize: AppDimens.fontSize14,
                          ),
                        ),
                        CustomTextFormField(
                          hint: "enter_city".tr,
                          controller: controller.cityController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'city_required'.tr;
                            } else {
                              bool cityValid =
                                  RegExp(r'^[a-zA-Z\s\-]+$').hasMatch(value);
                              if (!cityValid) {
                                return 'enter_valid_city'.tr;
                              }
                            }
                            return null;
                          },
                        ).paddingOnly(top: 5),


                        SizedBox(
                          height: 15.h,
                        ),
                        Text(
                          "state".tr,
                          style: AppTextStyle.bold7.copyWith(
                              color: AppColors.themeColor.textPrimaryColor,
                              fontSize: AppDimens.fontSize14),
                        ),
                        CustomTextFormField(
                          hint: "enter_state".tr,
                          controller: controller.stateController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'state_required'.tr;
                            } else {
                              bool stateValid =
                                  RegExp(r'^[a-zA-Z\s\-]+$').hasMatch(value);
                              if (!stateValid) {
                                return 'enter_valid_state'.tr;
                              }
                            }
                            return null;
                          },
                        ).paddingOnly(top: 5),


                        SizedBox(
                          height: 15.h,
                        ),
                        Text(
                          "country".tr,
                          style: AppTextStyle.bold7.copyWith(
                              color: AppColors.themeColor.textPrimaryColor,
                              fontSize: AppDimens.fontSize14),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Obx(() {
                          final countries = controller.countryService.country.value;
                          String? selectedCode = controller.selectedCountryCode.value;

                          // ✅ VALIDATION
                          final validCodes = countries.map((e) => e.countryCode).toList();
                          if (!validCodes.contains(selectedCode)) {
                            selectedCode = null;
                          }

                          return FormField<String>(
                            initialValue: selectedCode,
                            validator: (value) {
                              if (controller.selectedCountryCode.value.isEmpty) {
                                return "select_country_required".tr;
                              }
                              return null;
                            },
                            builder: (formFieldState) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.themeColor.cardColor,
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: formFieldState.hasError 
                                        ? Border.all(color: AppColors.themeColor.otpWrongColor, width: 1) 
                                        : null,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Get.find<ThemeService>().isDarkMode.value
                                              ? Colors.black.withOpacity(0.4)
                                              : Colors.grey.withOpacity(0.3),
                                          spreadRadius: 1.0,
                                          blurRadius: 3.0,
                                          offset: const Offset(1.0, 1.0),
                                        ),
                                      ],
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                                        value: selectedCode,
                                        isExpanded: true,
                                        dropdownColor: AppColors.themeColor.cardColor,
                                        borderRadius: BorderRadius.circular(8.r),
                                        hint: Text(
                                          "select_country".tr, 
                                          style: AppTextStyle.medium8.copyWith(
                                            color: AppColors.themeColor.textSecondaryColor, 
                                            fontSize: AppDimens.fontSize14,
                                          ),
                                        ),
                                        icon: Icon(
                                          Icons.expand_more_rounded, 
                                          color: AppColors.themeColor.textSecondaryColor, 
                                          size: 24.sp,
                                        ),
                                        items: countries.map((country) {
                                          return DropdownMenuItem<String>(
                                            value: country.countryCode,
                                            child: Text(
                                              country.countryNameEn ?? "", 
                                              style: AppTextStyle.medium7.copyWith(
                                                fontSize: AppDimens.fontSize14, 
                                                color: AppColors.themeColor.textPrimaryColor,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? newCode) {
                                          if (newCode != null) {
                                            controller.onChangeCountry(newCode);
                                            formFieldState.didChange(newCode);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  if (formFieldState.hasError)
                                    Padding(
                                      padding: EdgeInsets.only(left: 12.w, top: 8.h),
                                      child: Text(
                                        formFieldState.errorText ?? "",
                                        style: TextStyle(
                                          color: AppColors.themeColor.otpWrongColor, 
                                          fontSize: AppDimens.fontSize12,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          );
                        }),




                        SizedBox(
                          height: 15.h,
                        ),
                        Text(
                          "zipcode".tr,
                          style: AppTextStyle.bold7.copyWith(
                              color: AppColors.themeColor.textPrimaryColor,
                              fontSize: AppDimens.fontSize14),
                        ),
                        SizedBox(
                          height: 8.h,
                        ),
                        CustomTextFormField(
                            hint: "enter_zip_code".tr,
                            inputType: TextInputType.number,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(6),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            controller: controller.zipCodeController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'zip_code_required'.tr;
                              }
                              return null;
                            }),


                        SizedBox(
                          height: 25.h,
                        ),
                        controller.buttonLoading.value
                            ? Utils.loading
                            : CustomButton(
                                onClick: () {
                                   controller.customerSave();
                                },
                                title: "save".tr)
                      ],
                    ),
                  ),
                ),
              ))));
  }
}
