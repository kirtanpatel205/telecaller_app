import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/core/models/all_lead_entity.dart';
import 'package:telecaller_app/ui/views/home/home_controller.dart';
import 'package:telecaller_app/ui/views/leads/leads_controller.dart';
import 'package:telecaller_app/ui/widgets/CustomSearchBar.dart';
import 'package:telecaller_app/ui/widgets/custom-appbar.dart';
import 'package:telecaller_app/ui/widgets/custome_icon_button.dart';

class LeadsPage extends GetView<LeadsController> {
  LeadsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.resetAndReload();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          MultiSliver(
            children: [
              SliverAppBar(
                pinned: true,
                floating: true,
                backgroundColor: AppColors.themeColor.cardColor,
                title: Text(
                  "Leads",
                  style: AppTextStyle.appBarTitleStyle.copyWith(
                    color: AppColors.themeColor.textPrimaryColor,
                    fontSize: 15,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    CustomSearchBar(),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: buildHorizontalDateList(),
                    ),
                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomActionButton(
                            title: "Reset",
                            icon: Icons.refresh,
                            onTap: () {},
                          ),
                          SizedBox(width: 5),
                          CustomActionButton(
                            title: "Filter",
                            icon: Icons.filter,
                            onTap: () {},
                          ),
                          SizedBox(width: 5,),
                          CustomActionButton(
                            title: "Auto Dial Next",
                            icon: Icons.call,
                            onTap: () {},
                            isFullWidth: false,
                            isPrimary: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10).sliverBox,

              controller.isLoading.value
                  ? CircularProgressIndicator()
                  : LeadPaginatedListWidget(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildHorizontalDateList() {
    return Obx(() {
      final dates = controller.dates;

      if (dates.isEmpty) {
        return const SizedBox(
          height: 50,
          child: Center(child: Text("No dates")),
        );
      }

      return SizedBox(
        height: 50,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          scrollDirection: Axis.horizontal,
          itemCount: dates.length,
          reverse: true,
          itemBuilder: (context, index) {
            final isSelected = controller.selectedDateIndex.value == index;

            final parts = dates[index].split('/');
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year = int.parse(parts[2]);

            final date = DateTime(year, month, day);
            final dayName = DateFormat('EEE').format(date);
            final monthName = DateFormat('MMM').format(date);

            return GestureDetector(
              onTap: () {
                controller.selectedDateIndex.value = index;
                controller.selectedLeadId.value = "";
                controller.selectedDateString.value = DateFormat(
                  'yyyy-MM-dd',
                ).format(date);
              },
              child: Container(
                width: 70,
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppColors.themeColor.primaryColor
                          : AppColors.themeColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day $monthName',
                      style: TextStyle(
                        fontSize: 9,
                        color:
                            isSelected
                                ? Colors.white
                                : AppColors.themeColor.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dayName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        color:
                            isSelected
                                ? Colors.white
                                : AppColors.themeColor.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget LeadPaginatedListWidget(BuildContext context) {
    if (controller.pagewiseAllLeadLoadController == null) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return PagewiseSliverList<AllLeadLeads>(
      pageLoadController: controller.pagewiseAllLeadLoadController!,
      noItemsFoundBuilder: (context) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No leads found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      retryBuilder: (context, retryFn) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text(
                  'Failed to load leads',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: retryFn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.themeColor.primaryColor,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
      itemBuilder: (context, lead, index) {
        final isSelected = controller.selectedLeadId.value == lead.id;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: GestureDetector(
            onTap: () {
              controller.selectedLeadId.value = lead.id ?? '';
              controller.LedadContectId(lead.id.toString());
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Lead Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            lead.name ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              lead.status,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getStatusColor(
                                lead.status,
                              ).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            lead.status ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(lead.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Form Info
                    Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            lead.formId?.title ?? 'No form',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Dates Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateInfo(
                            'Start',
                            lead.schedule?.startDate.toString(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDateInfo(
                            'End',
                            lead.schedule?.endDate.toString(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDateInfo(
                            'Created',
                            lead.createdAt.toString(),
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
                    //       // Call logic here
                    //       Get.dialog(
                    //         AlertDialog(
                    //           title: const Text('Call Lead'),
                    //           content: Text(
                    //             'Calling ${lead.name}',
                    //           ),
                    //           actions: [
                    //             TextButton(
                    //               onPressed: () => Get.back(),
                    //               child: const Text('Close'),
                    //             ),
                    //           ],
                    //         ),
                    //       );
                    //     },
                    //     icon: const Icon(Icons.call, size: 16),
                    //     label: const Text('Call Lead'),
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor:
                    //       AppColors.themeColor.primaryColor,
                    //       foregroundColor: Colors.white,
                    //       padding: const EdgeInsets.symmetric(
                    //         vertical: 10,
                    //       ),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(8),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    CustomActionButton(
                      title: "Call Lead",
                      icon: Icons.call,
                      isPrimary: true,
                      isFullWidth: true,
                      onTap: () {
                        print("Auto Dial Click");
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loadingBuilder: (context) {
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildDateInfo(String label, String? dateTime) {
    String formattedDate = 'N/A';
    if (dateTime != null) {
      formattedDate = DateFormat(
        'dd MMM, h:mm a',
      ).format(DateTime.parse(dateTime));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          formattedDate,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'scheduled':
        return const Color(0xFF4F46E5);
      case 'completed':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
