import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/core/controllers/overlay_controller.dart';
import 'package:telecaller_app/ui/widgets/custom_dropdown_call.dart';

class OverlayPages extends GetView<OverlayController> {
  final controller = Get.put(OverlayController());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Material(
        type: MaterialType.transparency,
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          width: double.infinity,
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.themeColor.cardColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Last Dialed call",
                          style: TextStyle(
                            color: AppColors.themeColor.textPrimaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        /// Call Duration
                        Obx(
                          () => Text(
                            "Call Duration : ${controller.formattedCallLogDuration.value}",
                            style: TextStyle(
                              color: AppColors.themeColor.textPrimaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.themeColor.primaryColor,
                                  width: 3,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: AppColors.themeColor.cardColor,
                                child: Center(
                                  child: Text(
                                    "R",
                                    // (controllerhome.lastCalledName.value.isNotEmpty)
                                    //     ? controllerhome.lastCalledName.value[0].toUpperCase()
                                    //     : "U",
                                    style: TextStyle(
                                      fontSize: 30,
                                      color: AppColors.themeColor.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),

                            /// 👇 Wrap Column inside Expanded to avoid overflow
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "No previous call",
                                    // controllerhome.lastCalledName.value.isNotEmpty
                                    //     ? controllerhome.lastCalledName.value
                                    //     : 'No previous call',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          AppColors.themeColor.textPrimaryColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.0),
                                  // changed from width to height
                                  Text(
                                    "+916355736782",

                                    // controllerhome.lastCalledName.isNotEmpty
                                    //     ? controllerhome.lastCalledNumber.value ?? ""
                                    //     : 'No previous call',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          AppColors.themeColor.textPrimaryColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),
                        Text(
                          "What Happened On Call",
                          style: TextStyle(
                            color: AppColors.themeColor.textPrimaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),

                        /// Dropdown
                        ///
                        CustomDropdown(
                          selectedValue: controller.callDropdownValue ,
                          items: controller.leadOptions,
                          onChanged: (value) {
                            controller.onDropdownChange(value);

                          },
                        ),

                        const SizedBox(height: 15),

                        Obx(
                          () =>
                              controller.callDropdownValue .value == "reschedule"
                                  ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Reschedule Call",
                                        style: TextStyle(
                                          color:
                                              AppColors
                                                  .themeColor
                                                  .textPrimaryColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.themeColor.bgColor,
                                          borderRadius: BorderRadius.circular(
                                            8.0,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Obx(
                                                () => Text(
                                                  controller
                                                          .rescheduleDate
                                                          .value
                                                          .isEmpty
                                                      ? DateFormat(
                                                        'dd-MM-yyyy',
                                                      ).format(
                                                        DateTime.now().add(
                                                          Duration(days: 1),
                                                        ),
                                                      )
                                                      : DateFormat(
                                                        'dd-MM-yyyy',
                                                      ).format(
                                                        DateFormat(
                                                          'yyyy-MM-dd',
                                                        ).parse(
                                                          controller
                                                              .rescheduleDate
                                                              .value,
                                                        ),
                                                      ),
                                                  style: AppTextStyle.medium8
                                                      .copyWith(
                                                        color:
                                                            AppColors
                                                                .themeColor
                                                                .textPrimaryColor,
                                                      ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap:
                                                    () => controller.pickDate(
                                                      context,
                                                    ),
                                                child: Icon(
                                                  Icons.calendar_month,
                                                  color:
                                                      AppColors
                                                          .themeColor
                                                          .primaryColor,
                                                ),
                                              ),
                                              // InkWell(
                                              //   onTap: () => controllerhome.statuschange(),
                                              //   child: Icon(Icons.arrow_back))
                                            ],
                                          ),
                                        ),
                                      ),
                                      // SizedBox(height: 10,),
                                      // Container(
                                      //   padding: EdgeInsets.only(right: 5),
                                      //   alignment: Alignment.centerRight,
                                      //   child: InkWell(
                                      //             onTap: () => controllerhome.statuschange(),
                                      //             child: Text("submit")),
                                      // )
                                    ],
                                  )
                                  : Container(),
                        ),

                        /// Redial
                        const SizedBox(height: 10),

                        InkWell(
                          onTap: () {
                            //  Get.toNamed('/customer-detail-page');
                            // Get.toNamed(Routes.CUSTOMERDETAILPAGE,
                            //     arguments: {
                            //       'phone': controllerhome.customerphoneNum
                            //           .toString(),
                            //       'id': controllerhome.lastCalledId
                            //           .toString() ??
                            //           "",
                            //       // controllerhome.currentCallId.toString(),
                            //     });
                          },
                          child: Row(
                            children: [
                              SizedBox(
                                height: 30,
                                width: 30,
                                child: CircleAvatar(
                                  backgroundColor: AppColors.themeColor.bgColor,
                                  child: Icon(
                                    Icons.edit,
                                    color: AppColors.themeColor.primaryColor,
                                    size: 17,
                                  ),
                                ),
                              ),
                              SizedBox(width: 5),
                              Text(
                                "Edit Contact",
                                style: TextStyle(
                                  color: AppColors.themeColor.textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            Get.toNamed('/create-note-page');
                          },
                          child: Row(
                            children: [
                              SizedBox(
                                height: 30,
                                width: 30,
                                child: CircleAvatar(
                                  backgroundColor: AppColors.themeColor.bgColor,
                                  child: Icon(
                                    Icons.note,
                                    color: AppColors.themeColor.primaryColor,
                                    size: 17,
                                  ),
                                ),
                              ),
                              SizedBox(width: 5),
                              Text(
                                "Note",
                                style: TextStyle(
                                  color: AppColors.themeColor.textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),

                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  // FlutterPhoneDirectCaller.callNumber(
                                  //   "+917698085149",
                                  // );

                                  Get.back();
                                },
                                child: Container(
                                  width: 200,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[500],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.threesixty_outlined,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "Redial Call",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  // controllerhome.getendcall();
                                  // if (controllerhome.dropdownValue.value ==
                                  //     "reschedule") {
                                  // controllerhome.statuschange();
                                  // }

                                  // Get.back();
                                  // Get.back();
                                },
                                child: Container(
                                  width: 200,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: Colors.orange[400],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.pause, color: Colors.white),
                                      SizedBox(width: 5),
                                      Text(
                                        "Pause Call",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),

                        InkWell(
                          onTap: () async {},
                          child: Container(
                            width: double.maxFinite,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.green[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.skip_next, color: Colors.white),
                                SizedBox(width: 5),
                                Obx(
                                  () => Text(
                                    controller.callDropdownValue .value.isEmpty
                                        ? "Next Call (${controller.countdown.value})"
                                        : "Next Call",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              /// Close Button
              Positioned(
                top: Get.height * .24,
                right: 0,
                child: IconButton(
                  onPressed: () async {
                    Get.back();
                  },
                  icon: Icon(
                    Icons.close,
                    color: AppColors.themeColor.textSecondaryColor,
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
