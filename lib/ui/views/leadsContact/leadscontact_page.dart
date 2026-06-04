import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_dimens.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/core/models/lead_contact_id_entity.dart';
import 'package:telecaller_app/ui/widgets/CustomSearchBar.dart';
import 'package:telecaller_app/ui/widgets/custom-appbar.dart';
import 'package:telecaller_app/ui/widgets/custome_icon_button.dart';
import 'package:telecaller_app/ui/widgets/app_safe_area.dart';
import 'leadscontact_controller.dart';

class _StatItem {
  final String title;
  final String value;
  final Color color;

  _StatItem(this.title, this.value, this.color);
}

class LeadsContactPage extends GetView<LeadsContactController> {
  const LeadsContactPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppSafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: AppColors.themeColor.scaffoldBackgroundColor,
          appBar: CustomAppBar(
            titleText: 'leads_contact'.tr,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              controller.resetAndReload();
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // 1. Stats Cards
                SliverToBoxAdapter(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return SizedBox(
                        height: 200.h,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }
                    return Column(
                      children: [
                        SizedBox(height: 12.h),
                        _buildStatsCards(),
                        SizedBox(height: 12.h),
                      ],
                    );
                  }),
                ),

                // 2. Pinned Search and Filters
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverHeaderDelegate(
                    minHeight: 125.h,
                    maxHeight: 125.h,
                    child: Container(
                      color: AppColors.themeColor.scaffoldBackgroundColor,
                      child: Column(
                        children: [
                          SizedBox(height: 12.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: CustomSearchBar(
                              controller: controller.searchController,
                              onSearch: (value) {
                                controller.searchText.value = value;
                                controller.resetAndReload();
                              },
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Obx(() {
                              final hasActiveFilters = controller.isApplyFilter
                                  .value;
                              final hasActiveSort = controller.sortBy.value !=
                                  "create";
                              final showReset = hasActiveFilters ||
                                  hasActiveSort;

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
                                ],
                              );
                            }),
                          ),
                          SizedBox(height: 8.h),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Leads List
                _buildLeadsTableSliver(context),

                // Bottom padding
                SliverToBoxAdapter(child: SizedBox(height: 20.h)),
              ],
            ),
          ),
        ));
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.4,
        ),
        children: [
          _buildGridCard('total'.tr, controller.totalLeadsId.value.toString(),
              const Color(0xFF6366F1), Icons.people_outline),
          _buildGridCard(
              'completed'.tr, controller.completedCount.value.toString(),
              const Color(0xFF10B981), Icons.check_circle_outline),
          _buildGridCard('pending'.tr, controller.pendingCount.value.toString(),
              const Color(0xFFF59E0B), Icons.pending_actions),
          _buildGridCard(
              'scheduled'.tr, controller.scheduledCount.value.toString(),
              const Color(0xFF3B82F6), Icons.calendar_today),
          _buildGridCard(
              'interested'.tr, controller.interestedCount.value.toString(),
              const Color(0xFF8B5CF6), Icons.thumb_up_outlined),
          _buildGridCard('not_interested'.tr,
              controller.notInterestedCount.value.toString(),
              const Color(0xFFEF4444), Icons.thumb_down_outlined),
          _buildGridCard(
              'follow_up'.tr, controller.followUpCount.value.toString(),
              const Color(0xFFEC4899), Icons.phone_callback_outlined),
          _buildGridCard('invalid'.tr, controller.invalidCount.value.toString(),
              const Color(0xFF6B7280), Icons.block),
          _buildGridCard(
              'no_response'.tr, controller.noResponseCount.value.toString(),
              const Color(0xFF14B8A6), Icons.phone_missed),
        ],
      ),
    );
  }

  Widget _buildGridCard(String title, String value, Color color,
      IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.themeColor.cardBgColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1.w),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16.sp, color: color),
              SizedBox(width: 6.w),
              Text(
                value,
                style: AppTextStyle.bold11.copyWith(
                  fontSize: AppDimens.fontSize18,
                  color: AppColors.themeColor.textPrimaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              title,
              style: AppTextStyle.medium7.copyWith(
                fontSize: AppDimens.fontSize11,
                color: AppColors.themeColor.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadsTableSliver(BuildContext context) {
    if (controller.pagewiseLoadLeadIdController == null) {
      return const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator()));
    }
    return PagewiseSliverList<LeadContactIdLeadContacts>(
      pageLoadController: controller.pagewiseLoadLeadIdController,
      showRetry: true,
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
                  color: AppColors.themeColor.textSecondaryColor.withOpacity(
                      0.5),
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
                Icon(Icons.error_outline, size: 48.sp,
                    color: Colors.red.shade400),
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
                    padding: EdgeInsets.symmetric(
                        horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r)),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
      loadingBuilder: (context) =>
      const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      ),
      itemBuilder: (context, item, index) => _buildLeadCardMobile(item),
    );
  }

  Widget _buildLeadCardMobile(LeadContactIdLeadContacts lead) {
    final name = lead.contact?.name ?? 'Unknown';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final phone = lead.contact?.phone;
    final email = lead.contact?.email;
    final statusColor = controller.getStatusColor(lead.status ?? 'Unknown');

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.themeColor.cardBgColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15.r,
            offset: Offset(0, 4.h),
          ),
        ],
        border: Border.all(
          color: AppColors.themeColor.bordercolror.withOpacity(0.4),
          width: 0.8.w,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Circle
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusColor.withOpacity(0.15),
                        statusColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: AppTextStyle.bold9.copyWith(
                        fontSize: 18.sp,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                // Main Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: AppTextStyle.bold8.copyWith(
                                fontSize: 16.sp,
                                color: AppColors.themeColor.textPrimaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildStatusBadge(lead.status ?? 'Unknown'),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Obx(() => _buildContactLink(Icons.phone_outlined, phone ?? 'N/A',
                          onTap: (phone != null && phone != 'N/A' && controller.currentMode.value != 'web')
                              ? () => controller.makeCall(lead.contact?.phone)
                              : null)),
                      if (email != null && email.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        _buildContactLink(Icons.mail_outline_rounded, email,
                            onTap: () => controller.sendEmail(email)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1,
              color: AppColors.themeColor.bordercolror.withOpacity(0.15)),

          // Stats Row: Telecaller, Logs, Duration
          Container(
            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.themeColor.scaffoldBackgroundColor.withOpacity(
                  0.3),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                Expanded(child: _buildInfoBlock(
                    'telecaller'.tr, lead.assignedTo?.name ?? 'N/A',
                    Icons.person_pin_rounded)),
                _buildVerticalSeparator(),
                Expanded(child: _buildInfoBlock(
                    'logs'.tr, '${lead.logs?.length ?? 0}',
                    Icons.history_edu_rounded)),
                _buildVerticalSeparator(),
                Expanded(child: _buildInfoBlock('duration'.tr,
                    controller.formatDuration(
                        controller.getTotalDuration(lead.logs)),
                    Icons.timer_rounded)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalSeparator() {
    return Container(
      height: 24.h,
      width: 1.w,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      color: AppColors.themeColor.bordercolror.withOpacity(0.2),
    );
  }

  Widget _buildContactLink(IconData icon, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Row(
          children: [
            Icon(icon,
                size: 14.sp,
                color: AppColors.themeColor.textSecondaryColor.withOpacity(
                    0.7)),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                value,
                style: AppTextStyle.regular7.copyWith(
                  fontSize: 12.sp,
                  color: onTap != null
                      ? AppColors.themeColor.primaryColor
                      : AppColors.themeColor.textSecondaryColor,
                  decoration: onTap != null ? TextDecoration.underline : null,
                  decorationColor: AppColors.themeColor.primaryColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBlock(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12.sp,
                color: AppColors.themeColor.primaryColor.withOpacity(0.7)),
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
        SizedBox(height: 4.h),
        Text(
          value,
          style: AppTextStyle.bold7.copyWith(
            fontSize: 13.sp,
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

  Widget _buildDetailItem(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: AppColors.themeColor.textSecondaryColor),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            value,
            style: AppTextStyle.regular7.copyWith(
              fontSize: 13.sp,
              color: AppColors.themeColor.textSecondaryColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }


  Widget _buildStatusBadge(String status) {
    final color = controller.getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        status.tr,
        style: AppTextStyle.bold6.copyWith(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
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
              Obx(() =>
                  Row(
                    children: [
                      Radio<String>(
                        value: "all_time",
                        groupValue: controller.filterType.value,
                        activeColor: AppColors.themeColor.primaryColor,
                        onChanged: (value) {
                          controller.filterType.value = value!;
                        },
                      ),
                      Text("all_time".tr, style: AppTextStyle.regular7.copyWith(
                          fontSize: AppDimens.fontSize14,
                          color: AppColors.themeColor.textPrimaryColor)),
                      SizedBox(width: 20.w),
                      Radio<String>(
                        value: "specific_time",
                        groupValue: controller.filterType.value,
                        activeColor: AppColors.themeColor.primaryColor,
                        onChanged: (value) {
                          controller.filterType.value = value!;
                        },
                      ),
                      Text("specific_time".tr,
                          style: AppTextStyle.regular7.copyWith(
                              fontSize: AppDimens.fontSize14,
                              color: AppColors.themeColor.textPrimaryColor)),
                    ],
                  )),
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
              Obx(() =>
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.themeColor.bordercolror, width: 1.w),
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: controller.status.value,
                        icon: Icon(Icons.arrow_drop_down,
                            color: AppColors.themeColor.primaryColor),
                        dropdownColor: AppColors.themeColor.cardColor,
                        items: [
                          {"key": "all", "label": "all"},
                          {"key": "completed", "label": "completed"},
                          {"key": "scheduled", "label": "scheduled"},
                          {"key": "pending", "label": "pending"},
                        ].map((status) {
                          return DropdownMenuItem<String>(
                            value: status["key"],
                            child: Text(status["label"]!.tr,
                                style: AppTextStyle.regular7.copyWith(
                                    fontSize: AppDimens.fontSize14,
                                    color: AppColors.themeColor
                                        .textPrimaryColor)),
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
                          final DateTimeRange? picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            initialDateRange: controller.startDate.value !=
                                null && controller.endDate.value != null
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
                              horizontal: 12.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.themeColor.bordercolror),
                            borderRadius: BorderRadius.circular(25.r),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  controller.startDate.value != null &&
                                      controller.endDate.value != null
                                      ? "${DateFormat('yyyy-MM-dd').format(
                                      controller.startDate
                                          .value!)}   →   ${DateFormat(
                                      'yyyy-MM-dd').format(
                                      controller.endDate.value!)}"
                                      : "start_date_end_date".tr,
                                  style: AppTextStyle.regular7.copyWith(
                                    fontSize: AppDimens.fontSize13,
                                    color: controller.startDate.value != null
                                        ? AppColors.themeColor.textPrimaryColor
                                        : AppColors.themeColor
                                        .textSecondaryColor,
                                  ),
                                ),
                              ),
                              Icon(Icons.calendar_today_outlined, size: 18.sp,
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
              SizedBox(height: 30.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.r)),
                        side: BorderSide(
                            color: AppColors.themeColor.bordercolror),
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
                            borderRadius: BorderRadius.circular(25.r)),
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                      ),
                      child: Text(
                        "apply".tr,
                        style: AppTextStyle.bold7.copyWith(
                          fontSize: AppDimens.fontSize14,
                          color: AppColors.themeColor.onPrimaryColor,
                        ),
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
              return Obx(() =>
                  RadioListTile<String>(
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
                  ));
            }).toList(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context,
      double shrinkOffset,
      bool overlapsContent,) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
