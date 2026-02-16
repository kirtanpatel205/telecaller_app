import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_routes.dart';
import 'package:telecaller_app/core/helpers/utils.dart';
import 'package:telecaller_app/ui/views/overlay/overlay_controller.dart';

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

                        /// Call Duration
                        Obx(() => Text(
                          "Call Duration : ${controller.formattedCallLogDuration.value}",
                          style: TextStyle(
                            color: AppColors.themeColor.textPrimaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        )),

                        const SizedBox(height: 15),

                        /// Name + Number
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor:
                              AppColors.themeColor.cardColor,
                              child: Text(
                                controller.lastCalledName.value.isNotEmpty
                                    ? controller
                                    .lastCalledName.value[0]
                                    .toUpperCase()
                                    : "U",
                                style: TextStyle(
                                  fontSize: 30,
                                  color:
                                  AppColors.themeColor.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Obx(() => Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.lastCalledName.value
                                        .isNotEmpty
                                        ? controller
                                        .lastCalledName.value
                                        : "No previous call",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    controller.lastCalledNumber
                                        .value ??
                                        "",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              )),
                            )
                          ],
                        ),

                        const SizedBox(height: 15),

                        /// Dropdown
                        Obx(() => DropdownButton<String>(
                          isExpanded: true,
                          value: controller
                              .dropdownValue.value.isEmpty
                              ? null
                              : controller.dropdownValue.value,
                          hint: const Text("Select an option"),
                          onChanged: (value) {
                            if (value != null) {
                              controller.ondropdownchange(value);
                            }
                          },
                          items: controller.leadOptions
                              .map<DropdownMenuItem<String>>(
                                  (option) {
                                return DropdownMenuItem<String>(
                                  value: option["value"],
                                  child:
                                  Text(option["label"] ?? ""),
                                );
                              }).toList(),
                        )),

                        const SizedBox(height: 15),

                        /// Redial
                        InkWell(
                          onTap: () {
                            controller.dropdownValue.value = "";
                            FlutterPhoneDirectCaller.callNumber(
                              controller.lastCalledName.value.isNotEmpty
                                  ? controller.lastCalledNumber.value
                                  : controller.customerphoneNum.value,
                            );
                            Get.back();
                          },
                          child: Container(
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius:
                              BorderRadius.circular(5),
                            ),
                            child: const Text(
                              "Redial Call",
                              style:
                              TextStyle(color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// Next Call
                        InkWell(
                          onTap: () async {
                            if (controller
                                .dropdownValue.value.isEmpty) {
                              Utils.showToast(
                                  "Please select an option");
                              return;
                            }

                            Get.back();
                            Get.back();

                            await controller
                                .getUpdateleadsbyid();

                            controller.isCallStarted.value =
                            false;

                            controller.countdown.value =
                                int.parse(controller
                                    .timeBetweenCalls.text);

                            controller.dropdownValue.value = "";

                            // if (controller
                            //     .pendingCustomersController
                            //     .loadedItems!
                            //     .isEmpty) {
                            //   Utils.showToast(
                            //       "No more numbers to call");
                            // }
                          },
                          child: Container(
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius:
                              BorderRadius.circular(5),
                            ),
                            child: Obx(() => Text(
                              controller.dropdownValue.value
                                  .isEmpty
                                  ? "Next Call (${controller.countdownEnd.value})"
                                  : "Next Call",
                              style: const TextStyle(
                                  color: Colors.white),
                            )),
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
                    controller.timer?.cancel();
                    controller.isCallStarted.value = true;

                    Get.back();
                    Get.back();

                    await controller.getUpdateleadsbyid();

                    controller.dropdownValue.value = "";
                    controller.countdown.value = int.parse(
                        controller.timeBetweenCalls.text);

                    // if (controller
                    //     .pendingCustomersController
                    //     .loadedItems ==
                    //     null ||
                    //     controller
                    //         .pendingCustomersController
                    //         .loadedItems!
                    //         .isEmpty) {
                    //   controller.isCallTask.value = false;
                    //   Utils.showToast(
                    //       "No more numbers to call");
                    // }
                  },
                  icon: Icon(
                    Icons.close,
                    color: AppColors
                        .themeColor.textSecondaryColor,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
