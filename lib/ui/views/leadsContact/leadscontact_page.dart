import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/core/models/lead_contact_id_entity.dart';
import 'package:telecaller_app/ui/widgets/CustomSearchBar.dart';
import 'package:telecaller_app/ui/widgets/custom-appbar.dart';
import 'package:telecaller_app/ui/widgets/custome_icon_button.dart';
import 'package:telecaller_app/ui/widgets/statusDashboard.dart';
import 'package:intl/intl.dart';
import 'leadscontact_controller.dart';

class LeadsContactPage extends GetView<LeadsContactController> {
  const LeadsContactPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          'leads_contact'.tr,
          style: TextStyle(color: AppColors.themeColor.textPrimaryColor),
        ),
      ),
      body: Obx(
            () =>
        controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            StatsDashboard(
              stats: {
                'total'.tr: controller.totalLeadsId.value,
                'completed'.tr: controller.completedCount.value,
                'pending'.tr: controller.pendingCount.value,
                'scheduled'.tr: controller.scheduledCount.value,
              },
            ),
            const SizedBox(height: 5),
            StatsDashboard(
              stats: {
                'interested'.tr: controller.interestedCount.value,
                'not_interested'.tr: controller.notInterestedCount.value,
                'follow_up'.tr: controller.followUpCount.value,
                'invalid'.tr: controller.invalidCount.value,
                'no_response'.tr: controller.noResponseCount.value,
              },
            ),
            CustomSearchBar(
              controller: controller.searchController,
              onSearch: () {
                controller.searchText.value =
                    controller.searchController.text;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomActionButton(
                    title: "reset".tr,
                    icon: Icons.refresh,
                    onTap: () {
                      controller.resetFilters();
                    },
                  ),
                  const SizedBox(width: 5),
                  CustomActionButton(
                    title: "filter".tr,
                    icon: Icons.filter_alt_outlined,
                    onTap: () {
                      _showFilterBottomSheet(context);
                    },
                  ),
                  const SizedBox(width: 5),
                  CustomActionButton(
                    title: "sort".tr,
                    icon: Icons.sort,
                    onTap: () {
                      _showSortBottomSheet(context);
                    },
                  ),
                  const SizedBox(width: 5),
                ],
              ),
            ),
            Expanded(child: _buildLeadsTable(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadsTable(BuildContext context) {
    return controller.isLoading.value
        ? const Center(child: CircularProgressIndicator())
        : PagewiseListView<LeadContactIdLeadContacts>(
      pageLoadController: controller.pagewiseLoadLeadIdController,
      showRetry: true,
      noItemsFoundBuilder:
          (context) => const Center(child: Text('No leads found')),
      loadingBuilder:
          (context) => const Center(child: CircularProgressIndicator()),
      itemBuilder: (context, item, index) => _buildLeadCardMobile(item),
    );
  }

  Widget _buildLeadCardMobile(LeadContactIdLeadContacts lead) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.themeColor.cardBgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.themeColor.bordercolror),
        boxShadow: [
          BoxShadow(
            color: AppColors.themeColor.scaffoldBackgroundColor.withOpacity(
                0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + Status + Call Now button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  lead.contact?.name ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildStatusBadge(lead.status ?? 'N/A'),
              const SizedBox(width: 10),
            ],
          ),


          Row(
            children: [
              const Icon(Icons.phone, size: 14, color: Colors.blueGrey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  lead.contact?.phone ?? 'N/A',
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(Icons.email, size: 14, color: Colors.blueGrey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  lead.contact?.email ?? 'N/A',
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Telecaller',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.themeColor.textSecondaryColor,
                      ),
                    ),
                    Text(
                      lead.assignedTo?.name ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logs',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blueGrey[600],
                      ),
                    ),
                    Text(
                      '${lead.logs?.length ?? 0}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Duration',
                      style: TextStyle(fontSize: 10,
                          color: AppColors.themeColor.textSecondaryColor),
                    ),
                    Text(
                      controller.formatDuration(
                        controller.getTotalDuration(lead.logs),
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Action Button
          // SizedBox(
          //   width: double.infinity,
          //   child: ElevatedButton.icon(
          //     onPressed: () {
          //       Get.dialog(
          //         AlertDialog(
          //           title: const Text('Call Lead'),
          //           content: Text('Calling ${lead.contact?.name ?? "N/A"}'),
          //           actions: [
          //             TextButton(
          //               onPressed: () => Get.back(),
          //               child: const Text('Cancel'),
          //             ),
          //             ElevatedButton(
          //               onPressed: () {
          //                 Get.back();
          //                 controller.makeCall(lead.contact?.phone);
          //               },
          //               style: ElevatedButton.styleFrom(
          //                 backgroundColor: AppColors.themeColor.primaryColor,
          //                 foregroundColor: Colors.white,
          //               ),
          //               child: const Text('Call'),
          //             ),
          //           ],
          //         ),
          //       );
          //     },
          //     icon: const Icon(Icons.call, size: 16),
          //     label: const Text('Call Now'),
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: AppColors.themeColor.primaryColor,
          //       foregroundColor: Colors.white,
          //       padding: const EdgeInsets.symmetric(vertical: 10),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = controller.getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.themeColor.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "filter_leads".tr,
                    style: TextStyle(
                      color: AppColors.themeColor.textPrimaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Obx(() =>
                  Row(
                    children: [
                      Radio<String>(
                        value: "all_time",
                        groupValue: controller.filterType.value,
                        onChanged: (value) {
                          controller.filterType.value = value!;
                        },
                      ),
                       Text("all_time".tr),
                      const SizedBox(width: 20),
                      Radio<String>(
                        value: "specific_time",
                        groupValue: controller.filterType.value,
                        onChanged: (value) {
                          controller.filterType.value = value!;
                        },
                      ),
                       Text("specific_time".tr),
                    ],
                  )),
               SizedBox(height: 20),
              Text(
                "filter_by_status".tr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.themeColor.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Obx(() =>
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.themeColor.bordercolror),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: controller.status.value,
                        items: [
                          {"key": "all", "label": "all"},
                          {"key": "completed", "label": "completed"},
                          {"key": "scheduled", "label": "scheduled"},
                          {"key": "pending", "label": "pending"},
                        ].map((status) {
                          return DropdownMenuItem<String>(
                            value: status["key"],
                            child: Text(status["label"]!.tr),
                          );
                        }).toList(),
                        onChanged: (value) {
                          controller.status.value = value!;
                        },
                      ),
                    ),
                  )),
              Obx(() {
                if (controller.filterType.value == "specific_time") {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        "filter_by_date".tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.themeColor.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          final DateTimeRange? picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            initialDateRange: controller.startDate.value !=
                                null &&
                                controller.endDate.value != null
                                ? DateTimeRange(
                              start: controller.startDate.value!,
                              end: controller.endDate.value!,
                            )
                                : null,
                          );
                          if (picked != null) {
                            controller.startDate.value = picked.start;
                            controller.endDate.value = picked.end;
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.themeColor.bordercolror),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  controller.startDate.value != null &&
                                      controller.endDate.value != null
                                      ? "${DateFormat('yyyy-MM-dd').format(controller.startDate.value!)}   →   ${DateFormat('yyyy-MM-dd').format(controller.endDate.value!)}"
                                      : "start_date_end_date".tr,
                                  style: TextStyle(
                                    color: controller.startDate.value != null
                                        ? AppColors.themeColor.textPrimaryColor
                                        : AppColors.themeColor.textSecondaryColor,
                                  ),
                                ),
                              ),
                              Icon(Icons.calendar_today_outlined,
                                  size: 18,
                                  color: AppColors.themeColor
                                      .textSecondaryColor),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        side: BorderSide(
                            color: AppColors.themeColor.bordercolror),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text(
                        "cancel".tr,
                        style: TextStyle(
                            color: AppColors.themeColor.textPrimaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.applyFilters();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.themeColor.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child:  Text(
                        "apply".tr,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.themeColor.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "sort_leads_by".tr,
                  style: TextStyle(
                    color: AppColors.themeColor.textPrimaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...controller.sortOptions.entries.map((entry) {
              return Obx(() =>
                  RadioListTile<String>(
                    title: Text(entry.value.tr),
                    value: entry.key,
                    groupValue: controller.sortBy.value,
                    activeColor: AppColors.themeColor.primaryColor,
                    onChanged: (value) {
                      controller.sortBy.value = value!;
                      controller.resetAndReload();
                      Get.back();
                    },
                  ));
            }).toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
