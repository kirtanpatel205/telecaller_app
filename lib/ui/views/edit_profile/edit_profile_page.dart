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
                                          Get.bottomSheet(Container(
                                            decoration: BoxDecoration(
                                                color: AppColors.themeColor.cardColor,
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20.r),
                                                    topRight:
                                                        Radius.circular(20.r))),
                                            padding: EdgeInsets.symmetric(vertical: 20.h),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 40.w,
                                                  height: 4.h,
                                                  margin: EdgeInsets.only(bottom: 20.h),

                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.withOpacity(0.3),
                                                    borderRadius: BorderRadius.circular(10.r),
                                                  ),
                                                ),
                                                ListTile(
                                                  title: Text("openCamera".tr, style: AppTextStyle.medium7.copyWith(color: AppColors.themeColor.textPrimaryColor)),
                                                  leading: Container(
                                                    padding: EdgeInsets.all(8.w),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.themeColor.primaryColor.withOpacity(0.1),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(Icons.camera_alt_outlined, color: AppColors.themeColor.primaryColor),
                                                  ),
                                                  onTap: () {
                                                    controller.getImage1();
                                                  },
                                                ),
                                                ListTile(
                                                  title: Text('openGallery'.tr, style: AppTextStyle.medium7.copyWith(color: AppColors.themeColor.textPrimaryColor)),
                                                  leading: Container(
                                                    padding: EdgeInsets.all(8.w),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.themeColor.primaryColor.withOpacity(0.1),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(Icons.image_outlined, color: AppColors.themeColor.primaryColor),
                                                  ),
                                                  onTap: () {
                                                    controller.getImage();
                                                  },
                                                )
                                              ],
                                            ),
                                          ));
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
                              hint: "Enter Name",
                              controller: controller.firstNameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Name is required";
                                } else {
                                  bool fullName = RegExp(r'^[a-zA-Z\s\-]+$')
                                      .hasMatch(value);
                                  if (!fullName) {
                                    return "Please enter a valid name";
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
                          hint: "Enter Email",
                          inputType: TextInputType.emailAddress,
                          controller: controller.emailAddressController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            } else {
                              bool emailValid = RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(value);
                              if (!emailValid) {
                                return 'Please enter a valid email';
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
                              .copyWith(fontSize: AppDimens.fontSize16, color: AppColors.themeColor.primaryColor),
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
                          hint: "Enter Address Line 1",
                          controller: controller.addressLine1Controller,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Address Line 1 is required";
                            }
                            return null;
                          },
                        ).paddingOnly(top: 5),


                        SizedBox(
                          height: 15.h,
                        ),
                        Text(
                          "${"addressLine1".tr} 2" ,
                          style: AppTextStyle.bold7.copyWith(
                            color: AppColors.themeColor.textPrimaryColor,
                            fontSize: AppDimens.fontSize14,
                          ),
                        ),
                        CustomTextFormField(
                          hint: "Enter Address Line 2",
                          controller: controller.addressLine2Controller,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Address Line 2 is required";
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
                          hint: "Enter City",
                          controller: controller.cityController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'City is required';
                            } else {
                              bool cityValid =
                                  RegExp(r'^[a-zA-Z\s\-]+$').hasMatch(value);
                              if (!cityValid) {
                                return 'Please enter a valid city';
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
                          hint: "Enter State",
                          controller: controller.stateController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'State is required';
                            } else {
                              bool stateValid =
                                  RegExp(r'^[a-zA-Z\s\-]+$').hasMatch(value);
                              if (!stateValid) {
                                return 'Please enter a valid state';
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
                                return "Please select a country";
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
                                        ? Border.all(color: Colors.red, width: 1) 
                                        : null,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 1.0,
                                          blurRadius: 2.0,
                                          offset: Offset(1.0, 1.0),
                                        ),
                                      ],
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                                        value: selectedCode,
                                        isExpanded: true,
                                        dropdownColor: AppColors.themeColor.cardBgColor,
                                        hint: Text("Select Country", style: AppTextStyle.medium8.copyWith(color: Colors.grey.shade400, fontSize: 14)),
                                        icon: Icon(Icons.expand_more_rounded, color: Colors.grey, size: 24.sp),
                                        items: countries.map((country) {
                                          return DropdownMenuItem<String>(
                                            value: country.countryCode,
                                            child: Text(country.countryNameEn ?? "", style: AppTextStyle.medium7.copyWith(fontSize: 14, color: AppColors.themeColor.textPrimaryColor)),
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
                                        style: TextStyle(color: Colors.red, fontSize: 12.sp),
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
                            hint: "Enter Zip Code",
                            inputType: TextInputType.number,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(6),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            controller: controller.zipCodeController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Zip Code is required';
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
