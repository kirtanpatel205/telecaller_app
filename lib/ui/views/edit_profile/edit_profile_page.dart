import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
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
                                            height: null, // Allow dynamic height
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                                color: AppColors
                                                    .themeColor.cardBgColor,
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20.r),
                                                    topRight:
                                                        Radius.circular(20.r))),
                                            padding: EdgeInsets.only(bottom: 20.h),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ListTile(
                                                  title: Text(
                                                      //'Open Camera'
                                                      "openCamera".tr),
                                                  leading: Icon(Icons
                                                      .camera_alt_outlined),
                                                  onTap: () {
                                                    controller.getImage1();
                                                  },
                                                ),
                                                ListTile(
                                                  title: Text('openGallery'.tr),
                                                  leading: Icon(Icons.image),
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
                                if (value!.isEmpty) {
                                  return "Fisrst Required";
                                } else {
                                  bool Fullname = RegExp(r'^[a-zA-Z\s\-]+$')
                                      .hasMatch(value);
                                  if (!Fullname) {
                                    return "Enter Valid Firstname";
                                  }
                                }
                              },
                            ) //4
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
                              return 'Email Required';
                            } else {
                              bool emailValid = RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(value);
                              if (!emailValid) {
                                return 'Enter Valid Email';
                              }
                            }
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
                            if (value!.isEmpty &&
                                controller
                                    .addressLine1Controller.text.isEmpty) {
                              return "Address Required 1".tr;
                            } /*else {
                              bool Fullname =
                                  RegExp(r'^[a-zA-Z\s\-]+$').hasMatch(value);
                              if (!Fullname) {
                                return "entervalidaddress".tr;
                              }
                            }*/
                          },
                        ).paddingOnly(top: 5),
                        SizedBox(
                          height: 15.h,
                        ),
                        Text(
                          "${"addressline1".tr} 2" ,
                          style: AppTextStyle.bold7.copyWith(
                            color: AppColors.themeColor.textPrimaryColor,
                            fontSize: AppDimens.fontSize14,
                          ),
                        ),
                        CustomTextFormField(
                          hint: "Enter Address Line2",
                          controller: controller.addressLine2Controller,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Address R 2".tr;
                            } /*else {
                              bool Fullname =
                                  RegExp(r'^[a-zA-Z\s\-]+$').hasMatch(value);
                              if (!Fullname) {
                                return "enterValidaddress".tr;
                              }
                            }*/
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
                          hint: "Enter City Name",
                          controller: controller.cityController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'City Required';
                            } else {
                              bool Cityvalid =
                                  RegExp(r'^[a-zA-Z\s\-]+$').hasMatch(value);
                              if (!Cityvalid) {
                                return 'Enter Valid City';
                              }
                            }
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
                          hint: "Enter State Name",
                          controller: controller.stateController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'State Required';
                            } else {
                              bool Statevalid =
                                  RegExp(r'^[a-zA-Z\s\-]+$').hasMatch(value);
                              if (!Statevalid) {
                                return 'Enter Valid State'.tr;
                              }
                            }
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
                          final countries = controller.countryList;

                          String? selectedCode = controller.selectedCountryIndex.value;

                          // ✅ VALIDATION
                          final validCodes = countries.map((e) => e["code"]).toList();

                          if (!validCodes.contains(selectedCode)) {
                            selectedCode = null;
                          }

                          return Card(
                            color: AppColors.themeColor.cardBgColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                value: selectedCode,
                                isExpanded: true,
                                dropdownColor: AppColors.themeColor.cardBgColor,
                                hint: Text("select_country".tr, style: AppTextStyle.regular7.copyWith(color: Colors.grey.shade400, fontSize: AppDimens.fontSize14)),
                                icon: Icon(Icons.expand_more_rounded, color: Colors.grey, size: 24.sp),
                                items: countries.map((country) {
                                  return DropdownMenuItem<String>(
                                    value: country["code"],
                                    child: Text(country["name"] ?? "", style: AppTextStyle.medium7.copyWith(fontSize: AppDimens.fontSize14, color: AppColors.themeColor.textPrimaryColor)),
                                  );
                                }).toList(),
                                onChanged: (String? newCode) {
                                  if (newCode != null) {
                                    controller.onChangeCountry(newCode);
                                  }
                                },
                              ),
                            ),
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
                              if (value!.isEmpty) {
                                return 'Zip Required'.tr;
                              }
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
