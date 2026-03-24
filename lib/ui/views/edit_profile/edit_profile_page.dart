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
import 'package:telecaller_app/ui/widgets/custom_button.dart';
import 'package:telecaller_app/ui/widgets/custome_text_filed.dart';

import 'edit_profile_controller.dart';

class EditProfilePage extends GetView<EditProfileController> {
  AuthController authController = Get.find();
  @override
  Widget build(BuildContext context) {
    return AppSafeArea(child: Obx(() => Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: AppColors.themeColor.bgColor,
          leading: IconButton(
            icon: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.themeColor.primaryColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 25,
                    color: AppColors.themeColor.primaryColor,
                  ),
                ),
              ),
            ),
            onPressed: () {
              Get.back();
            },
          ),
          title: Text(
            "editProfile".tr,
            style: AppTextStyle.appBarTitleStyle
                .copyWith(fontWeight: FontWeight.w500, fontSize: 15),
          ),
          centerTitle: true,
          actions: [
            Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.more_horiz,
                  color: Colors.transparent,
                  size: 30,
                ))
          ],
        ),
        body: controller.isLoading.value
            ? Utils.loading
            : SingleChildScrollView(
                child: Form(
                  key: controller.formKey,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height:
                                      80, // or use a responsive unit like 40.h if you're using flutter_screenutil
                                  width: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    // border: Border.all(
                                    //   color: AppColors.themeColor.primaryColor,
                                    //   width: 2.0,
                                    // ),
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
                                                    : "No Name",
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
                                    top: 40,
                                    left: 36,
                                    child: IconButton(
                                        onPressed: () {
                                          Get.bottomSheet(Container(
                                            height: 120.h,
                                            width: 100.w,
                                            decoration: BoxDecoration(
                                                color: AppColors
                                                    .themeColor.cardBgColor,
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20),
                                                    topRight:
                                                        Radius.circular(20))),
                                            child: Column(
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
                                        icon: Icon(
                                          Icons.camera_alt,
                                          color: Colors.blue,
                                          size: 40,
                                        )))
                                // ]
                              ],
                            ),
                            SizedBox(
                              width: 25,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller
                                          .authController.profile.value?.name ??
                                      "No Name",
                                  // "Mahesh Talaviya",
                                  // controller.name,
                                  style: AppTextStyle.bold14.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: AppDimens.fontSize17),
                                ),
                                Text(
                                  controller.authController.profile.value
                                          ?.phone ??
                                      "",
                                  // "+91 63545 31472",
                                  style: AppTextStyle.regular9.copyWith(
                                      color: AppColors
                                          .themeColor.textSecondaryColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: AppDimens.fontSize10),
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Name".tr,
                              style: AppTextStyle.medium9.copyWith(
                                  color: AppColors.themeColor.textPrimaryColor,
                                  fontSize: 13),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            CustomTextFormField(
                              hint: "entername".tr,
                              controller: controller.firstNameController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "fisrstrequired".tr;
                                } else {
                                  bool Fullname = RegExp(r'^[a-zA-Z\s\-]+$')
                                      .hasMatch(value);
                                  if (!Fullname) {
                                    return "entervalidfirstname".tr;
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
                          height: 5,
                        ),
                        Text(
                          "Email".tr,
                          style: AppTextStyle.medium9.copyWith(
                              color: AppColors.themeColor.textPrimaryColor,
                              fontSize: 13),
                        ),
                        CustomTextFormField(
                          hint: "enteremail".tr,
                          inputType: TextInputType.emailAddress,
                          controller: controller.emailAddressController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'emailrequired'.tr;
                            } else {
                              bool emailValid = RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(value);
                              if (!emailValid) {
                                return 'entervalidemail'.tr;
                              }
                            }
                          },
                        ).paddingOnly(top: 5),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "address".tr,
                          style: AppTextStyle.bold12
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "addressLine1".tr,
                          style: AppTextStyle.medium9.copyWith(
                            color: AppColors.themeColor.textPrimaryColor,
                            fontSize: 13,
                          ),
                        ),
                        CustomTextFormField(
                          hint: "enteraddressline1".tr,
                          controller: controller.addressLine1Controller,
                          validator: (value) {
                            if (value!.isEmpty &&
                                controller
                                    .addressLine1Controller.text.isEmpty) {
                              return "addressrequired1".tr;
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
                          height: 5,
                        ),
                        Text(
                          "addressline2".tr,
                          style: AppTextStyle.medium9.copyWith(
                            color: AppColors.themeColor.textPrimaryColor,
                            fontSize: 13,
                          ),
                        ),
                        CustomTextFormField(
                          hint: "enteraddressline2".tr,
                          controller: controller.addressLine2Controller,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "addressrequired2".tr;
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
                          height: 5,
                        ),
                        Text(
                          "city".tr,
                          style: AppTextStyle.medium9.copyWith(
                            color: AppColors.themeColor.textPrimaryColor,
                            fontSize: 13,
                          ),
                        ),
                        CustomTextFormField(
                          hint: "entercityname".tr,
                          controller: controller.cityController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'cityrequired'.tr;
                            } else {
                              bool Cityvalid =
                                  RegExp(r'^[a-zA-Z\s\-]+$').hasMatch(value);
                              if (!Cityvalid) {
                                return 'entervalidcity'.tr;
                              }
                            }
                          },
                        ).paddingOnly(top: 5),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "state".tr,
                          style: AppTextStyle.medium9.copyWith(
                              color: AppColors.themeColor.textPrimaryColor,
                              fontSize: 13),
                        ),
                        CustomTextFormField(
                          hint: "enterstatename".tr,
                          controller: controller.stateController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'staterequired'.tr;
                            } else {
                              bool Statevalid =
                                  RegExp(r'^[a-zA-Z\s\-]+$').hasMatch(value);
                              if (!Statevalid) {
                                return 'entervalidstate'.tr;
                              }
                            }
                          },
                        ).paddingOnly(top: 5),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Country".tr,
                          style: AppTextStyle.medium9.copyWith(
                              color: AppColors.themeColor.textPrimaryColor,
                              fontSize: 13),
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
                            child: DropdownButton<String>(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              value: selectedCode,
                              isExpanded: true,
                              underline: Container(),
                              dropdownColor: AppColors.themeColor.cardBgColor,
                              hint: Text("Select Country".tr),

                              items: countries.map((country) {
                                return DropdownMenuItem<String>(
                                  value: country["code"],
                                  child: Text(country["name"] ?? ""),
                                );
                              }).toList(),

                              onChanged: (String? newCode) {
                                if (newCode != null) {
                                  controller.onChangeCountry(newCode);
                                }
                              },
                            ),
                          );
                        }),

                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "zipcode".tr,
                          style: AppTextStyle.medium9.copyWith(
                              color: AppColors.themeColor.textPrimaryColor,
                              fontSize: 13),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        CustomTextFormField(
                            hint: "enterzipCode".tr,
                            inputType: TextInputType.number,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(6),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            controller: controller.zipCodeController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'ziprequired'.tr;
                              }
                            }),
                        SizedBox(
                          height: 15,
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
    ;
  }
}
