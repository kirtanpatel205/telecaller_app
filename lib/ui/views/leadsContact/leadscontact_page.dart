import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/core/models/lead_contact_id_entity.dart';
import 'package:telecaller_app/ui/widgets/CustomSearchBar.dart';
import 'package:telecaller_app/ui/widgets/custom-appbar.dart';
import 'package:telecaller_app/ui/widgets/custome_icon_button.dart';
import 'package:telecaller_app/ui/widgets/statusDashboard.dart';
import 'leadscontact_controller.dart';

class LeadsContactPage extends GetView<LeadsContactController> {
  const LeadsContactPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          'Leads Contact',
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
                'Total': controller.totalLeadsId.value,
                'Completed': controller.completedCount.value,
                'Pending': controller.pendingCount.value,
                'Scheduled': controller.scheduledCount.value,
              },
            ),
            const SizedBox(height: 5),
            StatsDashboard(
              stats: {
                'Interested': controller.interestedCount.value,
                'Not Interested': controller.notInterestedCount.value,
                'Follow Up': controller.followUpCount.value,
                'Invalid': controller.invalidCount.value,
                'No Response': controller.noResponseCount.value,
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
                    title: "Reset",
                    icon: Icons.refresh,
                    onTap: () {
                      controller.resetFilters();
                    },
                  ),
                  const SizedBox(width: 5),
                  CustomActionButton(
                    title: "Filter",
                    icon: Icons.filter_alt_outlined,
                    onTap: () {
                      _showFilterBottomSheet(context);
                    },
                  ),
                  const SizedBox(width: 5),
                  CustomActionButton(
                    title: "Sort",
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
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = controller.getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _hexToColor(color).withOpacity(0.1),
        border: Border.all(color: _hexToColor(color)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          color: _hexToColor(color),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _hexToColor(String hexColor) {
    final hexString = hexColor.replaceAll('#', '');
    final intValue = int.parse(hexString, radix: 16);
    return Color(intValue | 0xFF000000);
  }

  void _showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.themeColor.cardBgColor,
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
                    "Filter Leads",
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
                      const Text("All Time"),
                      const SizedBox(width: 20),
                      Radio<String>(
                        value: "specific_time",
                        groupValue: controller.filterType.value,
                        onChanged: (value) {
                          controller.filterType.value = value!;
                        },
                      ),
                      const Text("Specific Time"),
                    ],
                  )),
              const SizedBox(height: 20),
              Text(
                "Filter by Status",
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
                          {"key": "all", "label": "All"},
                          {"key": "completed", "label": "Completed"},
                          {"key": "scheduled", "label": "Scheduled"},
                          {"key": "pending", "label": "Pending"},
                        ].map((status) {
                          return DropdownMenuItem<String>(
                            value: status["key"],
                            child: Text(status["label"]!),
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
                        "Filter by Date",
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
                                      ? "${controller.startDate.value!
                                      .toString().substring(
                                      0, 10)}   →   ${controller.endDate.value!
                                      .toString().substring(0, 10)}"
                                      : "Start date   →   End date",
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
                        "Cancel",
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
                        backgroundColor: Theme
                            .of(context)
                            .primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        "Apply",
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
          color: AppColors.themeColor.cardBgColor,
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
                  "Sort Leads By",
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
                    title: Text(entry.value),
                    value: entry.key,
                    groupValue: controller.sortBy.value,
                    activeColor: Theme
                        .of(context)
                        .primaryColor,
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
