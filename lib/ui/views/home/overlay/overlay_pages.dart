import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/core/controllers/overlay_controller.dart';
import 'package:telecaller_app/ui/widgets/custom_dropdown_call.dart';

class OverlayPages extends StatelessWidget {
  // Use find so we get the existing instance placed by PhoneStatusService
  final OverlayController controller = Get.find<OverlayController>();

  OverlayPages({Key? key}) : super(key: key);

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
                        // ── Header ──────────────────────────────────────
                        Text(
                          "Last Dialed Call",
                          style: TextStyle(
                            color: AppColors.themeColor.textPrimaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        // ── Call Duration ────────────────────────────────
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

                        // ── Avatar + Name + Number ────────────────────────
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
                              child: Obx(
                                    () => CircleAvatar(
                                  radius: 30,
                                  backgroundColor:
                                  AppColors.themeColor.cardColor,
                                  child: Text(
                                    controller.lastCalledName.value.isNotEmpty
                                        ? controller.lastCalledName.value[0]
                                        .toUpperCase()
                                        : "?",
                                    style: TextStyle(
                                      fontSize: 30,
                                      color: AppColors.themeColor.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(
                                        () => Text(
                                      controller.lastCalledName.value.isNotEmpty
                                          ? controller.lastCalledName.value
                                          : "No previous call",
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors
                                            .themeColor.textPrimaryColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Obx(
                                        () => Text(
                                      controller.lastCalledNumber.value
                                          .isNotEmpty
                                          ? controller.lastCalledNumber.value
                                          : "N/A",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors
                                            .themeColor.textPrimaryColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        // ── What happened on call ──────────────────────────
                        Text(
                          "What Happened On Call",
                          style: TextStyle(
                            color: AppColors.themeColor.textPrimaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),

                        CustomDropdown(
                          selectedValue: controller.callDropdownValue,
                          items: controller.leadOptions,
                          onChanged: (value) {
                            controller.onDropdownChange(value);
                          },
                        ),

                        const SizedBox(height: 15),

                        // ── Reschedule Date Picker ────────────────────────
                        Obx(
                              () => controller.callDropdownValue.value ==
                              "reschedule"
                              ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Reschedule Call",
                                style: TextStyle(
                                  color: AppColors
                                      .themeColor.textPrimaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.themeColor.bgColor,
                                  borderRadius:
                                  BorderRadius.circular(8.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Obx(
                                            () => Text(
                                          controller.rescheduleDate.value
                                              .isEmpty
                                              ? DateFormat('dd-MM-yyyy')
                                              .format(
                                            DateTime.now().add(
                                              const Duration(
                                                  days: 1),
                                            ),
                                          )
                                              : DateFormat('dd-MM-yyyy')
                                              .format(
                                            DateFormat('yyyy-MM-dd')
                                                .parse(controller
                                                .rescheduleDate
                                                .value),
                                          ),
                                          style: AppTextStyle.medium8
                                              .copyWith(
                                            color: AppColors.themeColor
                                                .textPrimaryColor,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () =>
                                            controller.pickDate(context),
                                        child: Icon(
                                          Icons.calendar_month,
                                          color: AppColors
                                              .themeColor.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          )
                              : const SizedBox.shrink(),
                        ),

                        const SizedBox(height: 10),

                        // ── Edit Contact ──────────────────────────────────
                        InkWell(
                          onTap: () {},
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
                              const SizedBox(width: 5),
                              Text(
                                "Edit Contact",
                                style: TextStyle(
                                  color: AppColors.themeColor.textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // ── Note ──────────────────────────────────────────
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
                              const SizedBox(width: 5),
                              Text(
                                "Note",
                                style: TextStyle(
                                  color: AppColors.themeColor.textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // ── Redial + Pause ─────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => controller.redialLastCall(),
                                child: Container(
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[500],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.threesixty_outlined,
                                          color: Colors.white),
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
                            const SizedBox(width: 10),
                            Expanded(
                              child: Obx(() => InkWell(
                                onTap: () {
                                  if (controller.isPaused.value) {
                                    controller.resumeCountdown();
                                  } else {
                                    controller.pauseCountdown();
                                  }
                                },
                                child: Container(
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: controller.isPaused.value ? Colors.green[500] : Colors.orange[400],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                          controller.isPaused.value ? Icons.play_arrow : Icons.pause,
                                          color: Colors.white
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        controller.isPaused.value ? "Resume Call" : "Pause Call",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // ── Next Call (with countdown) ──────────────────────
                        Obx(() {
                          if (!controller.isAutoCallMode.value) return const SizedBox.shrink();
                          
                          return InkWell(
                            onTap: () => controller.onNextCallTapped(),
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
                                  const Icon(Icons.skip_next,
                                      color: Colors.white),
                                  const SizedBox(width: 5),
                                  Obx(
                                        () {
                                      // In auto mode show countdown
                                      if (controller
                                          .callDropdownValue.value.isEmpty) {
                                        return Text(
                                          "Auto Next (${controller.countdown.value}s)",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        );
                                      }
                                      return const Text(
                                        "Next Call",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),

              // ── Close Button ─────────────────────────────────────────
              Positioned(
                top: Get.height * .24,
                right: 0,
                child: IconButton(
                  onPressed: () {
                    controller.stopCountdown(); // stop auto-dial on close
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