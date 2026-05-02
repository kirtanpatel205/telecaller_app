import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_dimens.dart';
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
    return Obx(() => RefreshIndicator(
      onRefresh: () async {
        await controller.resetAndReload();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          MultiSliver(
            children: [
              SliverCustomAppBar(
                titleText: "leads".tr,
                showBackButton: false,
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: 10.h),
                    CustomSearchBar(
                      controller: controller.searchController,
                      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      onSearch: (value) {
                        controller.searchText.value = value;
                      },
                    ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Obx(() {
                        final hasActiveFilters = controller.isApplyFilter.value;
                        final hasActiveSort = controller.sortBy.value != "create";
                        final showReset = hasActiveFilters || hasActiveSort;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (showReset) ...[
                              CustomActionButton(
                                title: "reset".tr,
                                icon: Icons.refresh,
                                onTap: () {
                                  controller.resetFilters();
                                },
                              ),
                              SizedBox(width: 8.w),
                            ],
                            CustomActionButton(
                              title: "filter".tr,
                              icon: Icons.filter_alt_outlined,
                              showBadge: hasActiveFilters,
                              onTap: () {
                                _showFilterBottomSheet(context);
                              },
                            ),
                            SizedBox(width: 8.w),
                            CustomActionButton(
                              title: "sort".tr,
                              icon: Icons.sort,
                              showBadge: hasActiveSort,
                              onTap: () {
                                _showSortBottomSheet(context);
                              },
                            ),
                            SizedBox(width: 8.w),
                          ],
                        );
                      }),
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
    ));
  }

  // Widget buildHorizontalDateList() {
  //   return Obx(() {
  //     final dates = controller.dates;
  //
  //     if (dates.isEmpty) {
  //       return const SizedBox(
  //         height: 50,
  //         child: Center(child: Text("no_dates".tr)),
  //       );
  //     }
  //
  //     return SizedBox(
  //       height: 50,
  //       child: ListView.builder(
  //         padding: const EdgeInsets.symmetric(horizontal: 8),
  //         scrollDirection: Axis.horizontal,
  //         itemCount: dates.length,
  //         reverse: true,
  //         itemBuilder: (context, index) {
  //           final isSelected = controller.selectedDateIndex.value == index;
  //
  //           final parts = dates[index].split('/');
  //           final day = int.parse(parts[0]);
  //           final month = int.parse(parts[1]);
  //           final year = int.parse(parts[2]);
  //
  //           final date = DateTime(year, month, day);
  //           final dayName = DateFormat('EEE').format(date);
  //           final monthName = DateFormat('MMM').format(date);
  //
  //           return GestureDetector(
  //             onTap: () {
  //               controller.selectedDateIndex.value = index;
  //               controller.selectedLeadId.value = "";
  //               controller.selectedDateString.value = DateFormat(
  //                 'yyyy-MM-dd',
  //               ).format(date);
  //             },
  //             child: Container(
  //               width: 70,
  //               margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
  //               decoration: BoxDecoration(
  //                 color:
  //                     isSelected
  //                         ? AppColors.themeColor.primaryColor
  //                         : AppColors.themeColor.primaryColor.withOpacity(0.1),
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Text(
  //                     '$day $monthName',
  //                     style: TextStyle(
  //                       fontSize: 9,
  //                       color:
  //                           isSelected
  //                               ? Colors.white
  //                               : AppColors.themeColor.textPrimaryColor,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 2),
  //                   Text(
  //                     dayName.toUpperCase(),
  //                     style: TextStyle(
  //                       fontSize: 9,
  //                       color:
  //                           isSelected
  //                               ? Colors.white
  //                               : AppColors.themeColor.textPrimaryColor,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       ),
  //     );
  //   });
  // }

  Widget LeadPaginatedListWidget(BuildContext context) {
    if (controller.pagewiseAllLeadLoadController == null) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return PagewiseSliverList<AllLeadLeads>(
      pageLoadController: controller.pagewiseAllLeadLoadController!,
      noItemsFoundBuilder: (context) {
        return Padding(
          padding: EdgeInsets.all(40.w),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48.sp,
                  color: AppColors.themeColor.textSecondaryColor.withOpacity(0.5),
                ),
                SizedBox(height: 16.h),
                Text(
                  'No leads found',
                  style: AppTextStyle.medium7.copyWith(
                    fontSize: AppDimens.fontSize16,
                    color: AppColors.themeColor.textSecondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      retryBuilder: (context, retryFn) {
        return Padding(
          padding: EdgeInsets.all(40.w),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.sp, color: Colors.red.shade400),
                SizedBox(height: 16.h),
                Text(
                  'Failed to load leads',
                  style: AppTextStyle.medium7.copyWith(
                    fontSize: AppDimens.fontSize16,
                    color: AppColors.themeColor.textSecondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: retryFn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.themeColor.primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
      itemBuilder: (context, lead, index) {
        return Obx(() {
          final isSelected = controller.selectedLeadId.value == lead.id;
          
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.themeColor.primaryColor.withOpacity(0.04) 
                    : AppColors.themeColor.cardColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isSelected 
                      ? AppColors.themeColor.primaryColor.withOpacity(0.5) 
                      : AppColors.themeColor.bordercolror.withOpacity(0.3),
                  width: isSelected ? 1.5.w : 1.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected 
                        ? AppColors.themeColor.primaryColor.withOpacity(0.15) 
                        : Colors.black.withOpacity(0.03),
                    blurRadius: isSelected ? 12.r : 8.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      controller.selectedLeadId.value = lead.id ?? '';
                      controller.LedadContectId(id: lead.id.toString());
                    },
                    splashColor: AppColors.themeColor.primaryColor.withOpacity(0.1),
                    highlightColor: AppColors.themeColor.primaryColor.withOpacity(0.05),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Name and Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lead.name ?? 'Unknown',
                                      style: AppTextStyle.bold11.copyWith(
                                        fontSize: AppDimens.fontSize17,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.themeColor.textPrimaryColor,
                                        letterSpacing: -0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 6.h),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.assignment_outlined,
                                          size: 14.sp,
                                          color: AppColors.themeColor.primaryColor.withOpacity(0.7),
                                        ),
                                        SizedBox(width: 6.w),
                                        Expanded(
                                          child: Text(
                                            lead.formId?.title ?? 'no_form_assigned'.tr,
                                            style: AppTextStyle.medium7.copyWith(
                                              fontSize: AppDimens.fontSize12,
                                              color: AppColors.themeColor.textSecondaryColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              _buildStatusBadge(lead.status),
                            ],
                          ),
                          
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            child: Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.themeColor.bordercolror.withOpacity(0.1),
                            ),
                          ),
                          
                          // Dates Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  'start_date'.tr,
                                  lead.schedule?.startDate.toString(),
                                  Icons.calendar_today_rounded,
                                  isDate: true,
                                ),
                              ),
                              _buildVerticalSeparator(),
                              Expanded(
                                child: _buildStatItem(
                                  'end_date'.tr,
                                  lead.schedule?.endDate.toString(),
                                  Icons.event_available_rounded,
                                  isDate: true,
                                ),
                              ),
                              _buildVerticalSeparator(),
                              Expanded(
                                child: _buildStatItem(
                                  'created'.tr,
                                  lead.createdAt.toString(),
                                  Icons.history_rounded,
                                  isDate: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
      },

      loadingBuilder: (context) {
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildStatusBadge(String? status) {
    final color = _getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Text(
        (status ?? 'Unknown').tr,
        style: AppTextStyle.bold7.copyWith(
          fontSize: AppDimens.fontSize10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String? value, IconData icon, {bool isDate = false}) {
    String displayValue = value ?? 'n_a'.tr;
    if (isDate && displayValue.isNotEmpty && displayValue != 'null' && displayValue != 'n_a'.tr) {
      try {
        final date = DateTime.parse(displayValue);
        displayValue = DateFormat('dd MMM, yy').format(date);
      } catch (_) {
        displayValue = value ?? 'n_a'.tr;
      }
    } else if (isDate && (value == null || value == 'null')) {
      displayValue = 'n_a'.tr;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 13.sp,
              color: AppColors.themeColor.primaryColor.withOpacity(0.8),
            ),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(
                label,
                style: AppTextStyle.medium7.copyWith(
                  fontSize: 10.sp,
                  color: AppColors.themeColor.textSecondaryColor,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 5.h),
        Text(
          displayValue,
          style: AppTextStyle.bold7.copyWith(
            fontSize: 12.sp,
            color: AppColors.themeColor.textPrimaryColor,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVerticalSeparator() {
    return Container(
      height: 30.h,
      width: 1.w,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      color: AppColors.themeColor.bordercolror.withOpacity(0.15),
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

  void _showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.themeColor.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
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
                    style: AppTextStyle.appBarTitleStyle.copyWith(
                      color: AppColors.themeColor.textPrimaryColor,
                      fontSize: AppDimens.fontSize18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close, size: 24.sp),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Obx(
                () => Row(
                  children: [
                    Radio<String>(
                      value: "all_time",
                      groupValue: controller.filterType.value,
                      onChanged: (value) {
                        controller.filterType.value = value!;
                      },
                    ),
                    Text("all_time".tr, style: AppTextStyle.regular7.copyWith(fontSize: AppDimens.fontSize14, color: AppColors.themeColor.textPrimaryColor)),
                    SizedBox(width: 20.w),

                    Radio<String>(
                      value: "specific_time",
                      groupValue: controller.filterType.value,
                      onChanged: (value) {
                        controller.filterType.value = value!;
                      },
                    ),
                    Text("specific_time".tr, style: AppTextStyle.regular7.copyWith(fontSize: AppDimens.fontSize14, color: AppColors.themeColor.textPrimaryColor)),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "filter_by_status".tr,
                style: AppTextStyle.medium7.copyWith(
                  fontSize: AppDimens.fontSize14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.themeColor.textPrimaryColor.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 10.h),
              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.themeColor.bordercolror,
                    ),
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: controller.status.value,
                      items:
                          [
                            {"key": "all", "label": "all"},
                            {"key": "completed", "label": "completed"},
                            {"key": "scheduled", "label": "scheduled"},
                            {"key": "pending", "label": "pending"},
                          ].map((status) {
                            return DropdownMenuItem<String>(
                              value: status["key"],
                              child: Text(status["label"]!.tr, style: AppTextStyle.regular7.copyWith(fontSize: AppDimens.fontSize14, color: AppColors.themeColor.textPrimaryColor)),
                            );
                          }).toList(),
                      onChanged: (value) {
                        controller.status.value = value!;
                      },
                    ),
                  ),
                ),
              ),
              Obx(() {
                if (controller.filterType.value == "specific_time") {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      Text(
                        "filter_by_date".tr,
                        style: AppTextStyle.medium7.copyWith(
                          fontSize: AppDimens.fontSize14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.themeColor.textPrimaryColor
                              .withOpacity(0.8),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      GestureDetector(
                        onTap: () async {
                          final DateTimeRange? picked =
                              await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                                initialDateRange:
                                    controller.startDate.value != null &&
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
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.themeColor.bordercolror,
                            ),
                            borderRadius: BorderRadius.circular(25.r),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  controller.startDate.value != null &&
                                          controller.endDate.value != null
                                      ? "${DateFormat('yyyy-MM-dd').format(controller.startDate.value!)}   →   ${DateFormat('yyyy-MM-dd').format(controller.endDate.value!)}"
                                      : "start_date_end_date".tr,
                                  style: AppTextStyle.regular7.copyWith(
                                    fontSize: AppDimens.fontSize13,
                                    color:
                                        controller.startDate.value != null
                                            ? AppColors
                                                .themeColor
                                                .textPrimaryColor
                                            : AppColors
                                                .themeColor
                                                .textSecondaryColor,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 18.sp,
                                color: AppColors.themeColor.textSecondaryColor,
                              ),
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
              SizedBox(height: 30.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                        side: BorderSide(
                          color: AppColors.themeColor.bordercolror,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                      ),
                      child: Text(
                        "cancel".tr,
                        style: AppTextStyle.medium7.copyWith(
                          fontSize: AppDimens.fontSize14,
                          color: AppColors.themeColor.textPrimaryColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.applyFilters();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.themeColor.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                      ),
                      child:  Text(
                        "apply".tr,
                        style: AppTextStyle.bold7.copyWith(color: AppColors.themeColor.onPrimaryColor, fontSize: AppDimens.fontSize14),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
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
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.themeColor.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
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
                    "sort_leads_by".tr,
                    style: AppTextStyle.appBarTitleStyle.copyWith(
                      color: AppColors.themeColor.textPrimaryColor,
                      fontSize: AppDimens.fontSize18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close, size: 24.sp),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              ...controller.sortOptions.entries.map((entry) {
                return Obx(
                  () => RadioListTile<String>(
                    title: Text(entry.value.tr,
                        style: AppTextStyle.regular7.copyWith(
                            fontSize: AppDimens.fontSize14,
                            color: AppColors.themeColor.textPrimaryColor)),
                    value: entry.key,
                    groupValue: controller.sortBy.value,
                    activeColor: AppColors.themeColor.primaryColor,
                    onChanged: (value) {
                      controller.sortBy.value = value!;
                      controller.resetAndReload();
                      Get.back();
                    },
                  ),
                );
              }).toList(),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
