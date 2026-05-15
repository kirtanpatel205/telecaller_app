import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/core/controllers/overlay_controller.dart';
import 'package:telecaller_app/core/helpers/storage.dart';
import 'package:telecaller_app/core/helpers/utils.dart';
import 'package:telecaller_app/core/models/all_lead_entity.dart';
import 'package:telecaller_app/core/models/lead_contact_id_entity.dart';
import 'package:telecaller_app/ui/views/auto_dialer/autodialer_controller.dart';
import 'package:telecaller_app/ui/widgets/custom-appbar.dart';
import 'package:telecaller_app/constants/app_dimens.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/ui/widgets/app_safe_area.dart';
import 'package:telecaller_app/ui/views/home/overlay/overlay_pages.dart';
import 'package:intl/intl.dart';
import 'package:telecaller_app/constants/app_routes.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Note: flutter_pagewise is still needed for the contacts PagewiseSliverList

class AutoDialerPage extends GetView<AutoDialerController> {
  const AutoDialerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery
        .of(context)
        .size
        .shortestSide > 600;
    final bool isStandalone = Get.currentRoute == Routes.AUTO_DIAL ||
        Get.currentRoute == Paths.AUTO_DIAL;

    Widget content = Obx(() =>
        Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async => controller.refreshContacts(),
              displacement: 40,
              color: AppColors.themeColor.primaryColor,
              child: CustomScrollView(
                physics: controller.selectedLeadDataset.value == null
                    ? const NeverScrollableScrollPhysics()
                    : const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // 1. Pinned App Bar
                  SliverCustomAppBar(
                    leading: const SizedBox.shrink(),
                    titleText: 'auto_dialer'.tr,
                    showBackButton: false,
                    actions: [
                      _buildModeSwitch(),
                    ],
                  ),

                  // 2. Lead Dropdown Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        isTablet ? 32.w : 16.w,
                        16.h,
                        isTablet ? 32.w : 16.w,
                        8.h,
                      ),
                      child: _buildLeadDropdownCard(isTablet),
                    ),
                  ),

                  // 3. Campaign Performance (Pinned Header - Only show if lead selected)
                  Obx(() =>
                  controller.selectedLeadDataset.value != null
                      ? SliverPinnedHeader(
                    child: Container(
                      color: AppColors.themeColor.scaffoldBackgroundColor,
                      padding: EdgeInsets.fromLTRB(
                        isTablet ? 32.w : 16.w,
                        0,
                        isTablet ? 32.w : 16.w,
                        8.h,
                      ),
                      child: _buildPremiumDashboardSection(isTablet),
                    ),
                  )
                      : const SliverToBoxAdapter(child: SizedBox.shrink())),

                  // 4. Contact List Header & Content
                  Obx(() {
                    final lead = controller.selectedLeadDataset.value;
                    if (lead == null)
                      return const SliverToBoxAdapter(child: SizedBox.shrink());

                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 32.w : 16.w,
                          vertical: 16.h,
                        ),
                        child: _buildContactSectionHeader(isTablet, lead),
                      ),
                    );
                  }),

                  // 5. The Paginated List
                  Obx(() =>
                  controller.selectedLeadDataset.value != null
                      ? _buildContactsPaginatedSliver(isTablet)
                      : const SliverToBoxAdapter(child: SizedBox.shrink())),

                  // 6. Initial Empty State (When no lead is selected)
                  Obx(() =>
                  controller.selectedLeadDataset.value == null
                      ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildInitialEmptyState(isTablet),
                  )
                      : const SliverToBoxAdapter(child: SizedBox.shrink())),

                  // Bottom padding for the sticky control center (only when lead is selected)
                  Obx(() =>
                  controller.selectedLeadDataset.value != null
                      ? SliverToBoxAdapter(child: SizedBox(height: 10.h))
                      : const SliverToBoxAdapter(child: SizedBox.shrink())),
                ],
              ),
            ),

            // ── STICKY CONTROL CENTER ──────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildStickyControlCenter(isTablet),
            ),
          ],
        ));

    if (isStandalone) {
      return AppSafeArea(
        top: true,
        bottom: true,
        child: Scaffold(
          backgroundColor: AppColors.themeColor.scaffoldBackgroundColor,
          body: content,
        ),
      );
    }

    return content;
  }


  Widget _buildPremiumDashboardSection(bool isTablet) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: AppColors.themeColor.primaryColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'campaign_performance'.tr,
              style: TextStyle(
                fontSize: AppDimens.fontSize10,
                fontWeight: FontWeight.bold,
                color: AppColors.themeColor.primaryColor,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _buildPerformanceStatsRow(isTablet),
      ],
    );
  }

  Widget _buildPerformanceStatsRow(bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(
          'total'.tr,
          controller.overallTotal,
          AppColors.themeColor.primaryColor,
        ),
        _buildStatCard(
          'pending'.tr,
          controller.pending,
          const Color(0xFFF59E0B),
        ),
        _buildStatCard(
          'completed'.tr,
          controller.completed,
          const Color(0xFF4F46E5),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, RxInt value, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Obx(
                  () =>
                  Text(
                    value.value.toString(),
                    style: TextStyle(
                      fontSize: AppDimens.fontSize16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 8.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.themeColor.textSecondaryColor,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadDropdownCard(bool isTablet) {
    return Obx(() {
      final leads = controller.leadsDropdownList;
      final selected = controller.selectedLeadDataset.value;
      final hasMore = controller.hasMoreLeads;
      final isLoadingMore = controller.isLeadsLoadingMore.value;

      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.themeColor.cardBgColor,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 15.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.themeColor.primaryColor.withOpacity(
                          0.1,
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.folder_copy_rounded,
                        color: AppColors.themeColor.primaryColor,
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'lead_dataset'.tr,
                      style: TextStyle(
                        fontSize: AppDimens.fontSize11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.themeColor.textPrimaryColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                if (leads.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.themeColor.primaryColor.withOpacity(
                        0.05,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '${leads.length} ${"active".tr}',
                      style: TextStyle(
                        fontSize: AppDimens.fontSize10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.themeColor.primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: AppColors.themeColor.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.themeColor.bordercolror),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selected?.id,
                  hint: Text(
                    'select_a_campaign…'.tr,
                    style: TextStyle(
                      color: AppColors.themeColor.textSecondaryColor,
                      fontSize: AppDimens.fontSize13,
                    ),
                  ),
                  icon: Icon(
                    Icons.unfold_more_rounded,
                    color: AppColors.themeColor.primaryColor,
                    size: 20.sp,
                  ),
                  items: [
                    ...leads.map(
                          (lead) =>
                          DropdownMenuItem<String>(
                            value: lead.id,
                            child: Text(
                              lead.name ?? 'Unnamed',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: AppDimens.fontSize14,
                                color: AppColors.themeColor.textPrimaryColor,
                              ),
                            ),
                          ),
                    ),
                    if (hasMore)
                      DropdownMenuItem<String>(
                        value: '__load_more__',
                        child: Center(
                          child: Text(
                            isLoadingMore ? 'Loading…' : 'Load More',
                            style: TextStyle(
                              fontSize: AppDimens.fontSize12,
                              color: AppColors.themeColor.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                  onChanged: (val) {
                    if (val == null) return;
                    if (val == '__load_more__') {
                      controller.loadMoreLeadsForDropdown();
                      return;
                    }
                    final match = leads.firstWhere(
                          (l) => l.id == val,
                      orElse: () => leads.first,
                    );
                    if (selected?.id == match.id) {
                      controller.clearLeadSelection();
                    } else {
                      controller.onLeadSelected(match);
                    }
                  },
                ),
              ),
            ),
            if (selected != null) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.themeColor.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.themeColor.primaryColor,
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        '${"active".tr}: ${selected.name}',
                        style: TextStyle(
                          color: AppColors.themeColor.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: AppDimens.fontSize12,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.clearLeadSelection(),
                      child: Icon(
                        Icons.close_rounded,
                        color: AppColors.themeColor.primaryColor,
                        size: 16.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildContactSectionHeader(bool isTablet, AllLeadLeads lead) {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: AppColors.themeColor.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.people_alt_rounded,
            color: AppColors.themeColor.primaryColor,
            size: 20.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'contacts_queue'.tr,
                style: TextStyle(
                  fontSize: AppDimens.fontSize10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.themeColor.textSecondaryColor,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                lead.name ?? 'Dataset',
                style: TextStyle(
                  fontSize: AppDimens.fontSize16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.themeColor.textPrimaryColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Obx(() => Row(children: [_buildStatusFilterDropdown()])),
      ],
    );
  }

  Widget _buildContactsPaginatedSliver(bool isTablet) {
    final hPad = isTablet ? 32.0.w : 16.0.w;

    return GetBuilder<AutoDialerController>(
      builder: (ctrl) {
        final contactsCtrl = ctrl.pagewiseContactsController;
        if (contactsCtrl == null)
          return const SliverToBoxAdapter(child: SizedBox.shrink());

        return PagewiseSliverList<LeadContactIdLeadContacts>(
          pageLoadController: contactsCtrl,
          loadingBuilder:
              (context) =>
              Padding(
                padding: EdgeInsets.all(24.w),
                child: const Center(child: CircularProgressIndicator()),
              ),
          noItemsFoundBuilder:
              (context) =>
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24.h),
                child: Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: AppColors.themeColor.cardBgColor,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.contact_phone_outlined,
                        size: 48.sp,
                        color: AppColors.themeColor.textSecondaryColor,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'no_contacts_found_for_this_lead'.tr,
                        style: AppTextStyle.medium7.copyWith(
                          color: AppColors.themeColor.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          retryBuilder:
              (context, retryFn) =>
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 24.h),
                  Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                  SizedBox(height: 12.h),
                  Text(
                    'Failed to load contacts',
                    style: AppTextStyle.medium7.copyWith(
                      color: AppColors.themeColor.textPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ElevatedButton(
                    onPressed: retryFn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.themeColor.primaryColor,
                    ),
                    child: Text(
                      'Retry',
                      style: AppTextStyle.bold7.copyWith(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
          itemBuilder: (context, LeadContactIdLeadContacts lead, int index) {
            return Obx(() {
              final isOpen = controller.openedContactIndex.value == index;
              final String name = controller.capitalizeEachWord(
                lead.contact?.name ?? 'Unknown',
              );
              final String phone = lead.contact?.phone ?? 'No Phone';
              final String? email = lead.contact?.email;
              final bool hasEmail = email != null && email
                  .trim()
                  .isNotEmpty;
              final String status = lead.status ?? 'pending';
              final isCompleted =
                  controller.selectedContactStatus.value == 'completed';
              final statusColor = controller.getStatusColor(
                isCompleted
                    ? (lead.logs?.isNotEmpty == true
                    ? lead.logs!.first.answer
                    : 'completed')
                    : status,
              );

              return Padding(
                padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 12.h),
                child: InkWell(
                  onTap: () {
                    controller.onContactManualSelect(lead, index);
                  },
                  child: Card(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      side: BorderSide(
                        color:
                        isOpen
                            ? AppColors.themeColor.primaryColor
                            : AppColors.themeColor.bordercolror.withOpacity(
                          0.5,
                        ),
                        width: isOpen ? 1.5.w : 1.w,
                      ),
                    ),
                    color:
                    isOpen
                        ? AppColors.themeColor.primaryColor.withOpacity(
                      0.05,
                    )
                        : AppColors.themeColor.cardBgColor,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color:
                            isOpen
                                ? AppColors.themeColor.primaryColor
                                .withOpacity(0.1)
                                : Colors.black.withOpacity(0.03),
                            blurRadius: 15.r,
                            offset: Offset(0, 8.h),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Status Indicator Bar
                          Positioned(
                            left: 0,
                            top: 20.h,
                            bottom: 20.h,
                            child: Container(
                              width: 4.w,
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.horizontal(
                                  right: Radius.circular(4.r),
                                ),
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  16.w,
                                  12.h,
                                  12.w,
                                  12.h,
                                ),
                                child: Row(
                                  children: [
                                    // Avatar
                                    Container(
                                      height: 40.h,
                                      width: 40.w,
                                      decoration: BoxDecoration(
                                        color: AppColors.themeColor.cardColor,
                                        border: Border.all(
                                          color:
                                          isOpen
                                              ? AppColors
                                              .themeColor
                                              .primaryColor
                                              : statusColor.withOpacity(
                                            0.5,
                                          ),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          20.r,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          name.isNotEmpty
                                              ? name[0].toUpperCase()
                                              : 'N',
                                          style: AppTextStyle.semiBold18
                                              .copyWith(
                                            color: statusColor,
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    // Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.person,
                                                size: 14.sp,
                                                color:
                                                AppColors
                                                    .themeColor
                                                    .textSecondaryColor,
                                              ),
                                              SizedBox(width: 6.w),
                                              Expanded(
                                                child: Text(
                                                  name,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15.sp,
                                                    color:
                                                    AppColors
                                                        .themeColor
                                                        .textPrimaryColor,
                                                  ),
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4.h),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.call,
                                                size: 14.sp,
                                                color:
                                                AppColors
                                                    .themeColor
                                                    .textSecondaryColor,
                                              ),
                                              SizedBox(width: 6.w),
                                              Text(
                                                phone,
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color:
                                                  AppColors
                                                      .themeColor
                                                      .textSecondaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (hasEmail) ...[
                                            SizedBox(height: 4.h),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.email_outlined,
                                                  size: 12.sp,
                                                  color:
                                                  AppColors
                                                      .themeColor
                                                      .textSecondaryColor,
                                                ),
                                                SizedBox(width: 4.w),
                                                Expanded(
                                                  child: Text(
                                                    email!,
                                                    style: TextStyle(
                                                      fontSize: 11.sp,
                                                      color:
                                                      AppColors
                                                          .themeColor
                                                          .textSecondaryColor,
                                                    ),
                                                    overflow:
                                                    TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),

                                    SizedBox(width: 8.w),
                                    _buildStatusBadge(status),
                                  ],
                                ),
                              ),

                              // Expandable Section (Pending & Completed)
                              AnimatedSize(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                child:
                                isOpen
                                    ? Column(
                                  children: [
                                    Divider(
                                      height: 1,
                                      color: statusColor.withOpacity(
                                        0.2,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 8.h,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          _buildActionButton(
                                            icon: Icons.call_rounded,
                                            label: "calls".tr,
                                            onTap:
                                                () =>
                                                controller
                                                    .makeManualCall(
                                                  lead,
                                                ),
                                            color: const Color(
                                              0xFF10B981,
                                            ),
                                          ),
                                          _buildActionButton(
                                            icon: null,
                                            label: "whatsapp".tr,
                                            onTap:
                                                () =>
                                                controller
                                                    .launchWhatsApp(
                                                  lead
                                                      .contact
                                                      ?.phone,
                                                ),
                                            color: const Color(
                                              0xFF25D366,
                                            ),
                                            isSvg: true,
                                            svgPath: 'assets/images/whatsapp-svgrepo-com.svg',
                                          ),
                                          _buildActionButton(
                                            icon: Icons.message_rounded,
                                            label: "sms".tr,
                                            onTap:
                                                () =>
                                                controller
                                                    .launchSms(
                                                  lead
                                                      .contact
                                                      ?.phone,
                                                ),
                                            color: const Color(
                                              0xFF3B82F6,
                                            ),
                                          ),
                                          if (hasEmail)
                                            _buildActionButton(
                                              icon: Icons.email_rounded,
                                              label: "email".tr,
                                              onTap:
                                                  () =>
                                                  controller
                                                      .launchEmail(
                                                    email,
                                                  ),
                                              color: const Color(
                                                0xFFF59E0B,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                                    : const SizedBox.shrink(),
                              ),

                              // Bottom Row (Completed)
                              if (isCompleted) ...[
                                Divider(
                                  height: 1,
                                  color: statusColor.withOpacity(0.1),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    20.w,
                                    12.h,
                                    16.w,
                                    12.h,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDate(lead.updatedAt),
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color:
                                          AppColors
                                              .themeColor
                                              .textSecondaryColor,
                                        ),
                                      ),
                                      Text(
                                        (lead.logs != null &&
                                            lead.logs!.isNotEmpty &&
                                            lead.logs![0].duration != 0)
                                            ? controller.formatDuration(
                                          Duration(
                                            seconds:
                                            lead.logs![0].duration!,
                                          ),
                                        )
                                            : '00:00',
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.bold,
                                          color: statusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            });
          },
        );
      },
    );
  }

  Widget _buildStickyControlCenter(bool isTablet) {
    return Obx(() {
      final status = controller.status.value;
      final isIdle = status == 'idle';

      // ✅ Hide sticky bar when call ends and overlay is shown (settled state)
      if (status == 'settled') return const SizedBox.shrink();

      // ✅ Requirement: Hide if completed and NOT actively dialing it
      if (!isIdle) {
        final current = controller.currentContact.value;
        final isCompleted = controller.isContactCompleted(current);
        final isCompletedTab = controller.selectedContactStatus.value ==
            'completed';

        if (isCompleted && !isCompletedTab) return const SizedBox.shrink();
        if (current == null && status != 'dialing')
          return const SizedBox.shrink();
      }

      return Container(
        margin: EdgeInsets.all(isIdle ? 0 : 16.w),
        decoration: BoxDecoration(
          color:
          isIdle
              ? Colors.transparent
              : AppColors.themeColor.cardColor.withOpacity(0.95),
          borderRadius: BorderRadius.circular(isIdle ? 0 : 32.r),
          boxShadow: [
            if (!isIdle)
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30.r,
                offset: Offset(0, 15.h),
              ),
          ],
          border:
          isIdle
              ? null
              : Border.all(
            color: AppColors.themeColor.bordercolror.withOpacity(0.2),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isIdle ? 0 : 32.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Padding(
              padding: EdgeInsets.all(isIdle ? 0 : 8.w),
              child:
              isIdle
                  ? _buildIdleStartButton(isTablet)
                  : _buildActiveControlBar(isTablet),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildIdleStartButton(bool isTablet) {
    return Obx(() {
      final hasLead = controller.selectedLeadDataset.value != null;
      final totalContacts = controller.totalContacts.value;

      final isCompletedView = controller.selectedContactStatus.value ==
          'completed';

      if (!hasLead || controller.overallTotal.value == 0 || isCompletedView ||
          totalContacts == 0)
        return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 24.h),
        child: _buildPremiumButton(
          onTap: () => controller.startDialing(),
          label: 'start_dialer'.tr,
          icon: Icons.rocket_launch_rounded,
          gradient: [
            AppColors.themeColor.primaryColor,
            AppColors.themeColor.primaryColor.withOpacity(0.8),
          ],
        ),
      );
    });
  }

  Widget _buildActiveControlBar(bool isTablet) {
    final status = controller.status.value;
    final isPaused = status == 'paused';
    final isDialing = status == 'dialing';
    final isCountdown = status == 'counting_down' || status == 'settled';
    final current = controller.currentContact.value;
    final overlayCtrl = Get.isRegistered<OverlayController>() ? Get.find<
        OverlayController>() : null;

    // Fallback data if currentContact is null (e.g. during list refresh)
    Map<String, String>? fallbackLead;
    if (current == null && overlayCtrl != null) {
      final index = overlayCtrl.currentQueueIndex.value;
      if (index >= 0 && index < overlayCtrl.callQueue.length) {
        fallbackLead = overlayCtrl.callQueue[index];
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (overlayCtrl != null) {
                      if (overlayCtrl.isPaused.value) {
                        overlayCtrl.resumeCountdown();
                      } else if (overlayCtrl.countdown.value > 0) {
                        overlayCtrl.countdown.value =
                        0; // Instantly make the call
                      }
                    }
                  },
                  child: _buildActiveAvatar(isDialing),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        current?.contact?.name ??
                            (fallbackLead?['name'] ?? 'prepare_call'.tr),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppDimens.fontSize14,
                          color: AppColors.themeColor.textPrimaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (current?.contact?.phone != null ||
                          fallbackLead?['number'] != null) ...[
                        SizedBox(height: 1.h),
                        Text(
                          current?.contact?.phone ??
                              (fallbackLead?['number'] ?? ''),
                          style: TextStyle(
                            fontSize: AppDimens.fontSize10,
                            color: AppColors.themeColor.textSecondaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      SizedBox(height: 6.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 4.h,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              // Toggle SIM 0 -> 1 -> 0
                              final int? currentSlot = await Storage
                                  .getSelectedSimSlot();
                              final int newSlot = (currentSlot == 0) ? 1 : 0;
                              await Storage.saveToSharedPrefs(
                                  'selected_sim_slot_index', newSlot);
                              Utils.showToast("Switched to SIM ${newSlot + 1}");
                              controller.refreshCurrentContact(); // Refresh UI
                            },
                            child: FutureBuilder<int?>(
                                future: Storage.getSelectedSimSlot(),
                                builder: (context, snapshot) {
                                  final slot = snapshot.data ?? 0;
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: AppColors.themeColor.primaryColor
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4.r),
                                      border: Border.all(
                                          color: AppColors.themeColor
                                              .primaryColor.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                            Icons.sim_card_rounded, size: 10.sp,
                                            color: AppColors.themeColor
                                                .primaryColor),
                                        SizedBox(width: 3.w),
                                        Text(
                                          "SIM ${slot + 1}",
                                          style: TextStyle(
                                            fontSize: AppDimens.fontSize9,
                                            color: AppColors.themeColor
                                                .primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (isPaused && controller.countdown.value == 0) {
                                if (Get.isRegistered<OverlayController>()) {
                                  Get
                                      .find<OverlayController>()
                                      .resumeCountdown();
                                }
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: (isDialing
                                    ? Colors.green
                                    : (isCountdown || (isPaused &&
                                    controller.countdown.value == 0) ? Colors
                                    .orange : Colors.grey))
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                isDialing
                                    ? 'on_call'.tr
                                    : (isCountdown || (isPaused &&
                                    controller.countdown.value == 0)
                                    ? (controller.countdown.value > 0
                                    ? '${'next_dial'.tr} ${controller.countdown
                                    .value}s'
                                    : 'ready_to_dial'.tr)

                                    : 'paused'.tr),
                                style: TextStyle(
                                  fontSize: AppDimens.fontSize9,
                                  color:
                                  isDialing
                                      ? Colors.green
                                      : (isCountdown || (isPaused &&
                                      controller.countdown.value == 0)
                                      ? Colors.orange
                                      : AppColors
                                      .themeColor
                                      .textSecondaryColor),
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Actions
          Row(
            children: [
              _buildMiniControlButton(
                onTap: () {
                  if (isPaused) {
                    controller.resumeDialing();
                  } else {
                    controller.pauseDialing();
                  }
                },
                icon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                color: isPaused ? Colors.green : Colors.orange,
                isPrimary: true,
              ),
              SizedBox(width: 8.w),
              _buildMiniControlButton(
                onTap: () => controller.stopDialing(),
                icon: Icons.stop_rounded,
                color: Colors.red,
                isPrimary: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveAvatar(bool isDialing) {
    return Container(
      width: 42.w,
      height: 42.h,
      decoration: BoxDecoration(
        color:
        isDialing
            ? Colors.green.withOpacity(0.15)
            : AppColors.themeColor.primaryColor.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(
          color:
          isDialing
              ? Colors.green.withOpacity(0.5)
              : AppColors.themeColor.primaryColor.withOpacity(0.3),
          width: 1.5.w,
        ),
        boxShadow:
        isDialing
            ? [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            blurRadius: 10.r,
            spreadRadius: 2.r,
          ),
        ]
            : null,
      ),
      child: Icon(
        isDialing ? Icons.phone_in_talk_rounded : Icons.phone_rounded,
        color: isDialing ? Colors.green : AppColors.themeColor.primaryColor,
        size: 20.sp,
      ),
    );
  }

  Widget _buildMiniControlButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.h,
        decoration: BoxDecoration(
          color: isPrimary ? color : color.withOpacity(0.12),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isPrimary ? 0.4 : 0.15),
              blurRadius: 16.r,
              offset: Offset(0, 6.h),
            ),
          ],
          border:
          isPrimary
              ? null
              : Border.all(color: color.withOpacity(0.4), width: 1.5.w),
        ),
        child: Icon(icon, color: isPrimary ? Colors.white : color, size: 22.sp),
      ),
    );
  }

  Widget _buildPremiumButton({
    required VoidCallback onTap,
    required String label,
    required IconData icon,
    required List<Color> gradient,
    double? width,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52.h,
        width: width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.3),
              blurRadius: 12.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22.sp),
            SizedBox(width: 10.w),
            Text(
              label,
              style: AppTextStyle.bold7.copyWith(
                color: Colors.white,
                fontSize: AppDimens.fontSize14,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialEmptyState(bool isTablet) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Premium Glow Icon
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140.w,
                  height: 140.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.themeColor.primaryColor.withOpacity(0.15),
                        AppColors.themeColor.primaryColor.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(28.w),
                  decoration: BoxDecoration(
                    color: AppColors.themeColor.cardBgColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.themeColor.primaryColor.withOpacity(
                          0.1,
                        ),
                        blurRadius: 20.r,
                        offset: Offset(0, 10.h),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.dashboard_customize_rounded,
                    size: 48.sp,
                    color: AppColors.themeColor.primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),
            // Text Content
            Text(
              'ready_to_start'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppDimens.fontSize22,
                fontWeight: FontWeight.bold,
                color: AppColors.themeColor.textPrimaryColor,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'select_a_lead'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppDimens.fontSize14,
                height: 1.5,
                color: AppColors.themeColor.textSecondaryColor,
              ),
            ),
            SizedBox(height: 48.h),
            // Subtle Indicator Arrow
            Icon(
              Icons.keyboard_double_arrow_up_rounded,
              color: AppColors.themeColor.primaryColor.withOpacity(0.3),
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilterDropdown() {
    return PopupMenuButton<String>(
      onSelected: (val) => controller.onContactStatusChanged(val),
      offset: Offset(0, 48.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.themeColor.cardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppColors.themeColor.bordercolror.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list_rounded,
              color: AppColors.themeColor.primaryColor,
              size: 16.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              controller.selectedContactStatus.value.tr,
              style: AppTextStyle.bold7.copyWith(
                fontSize: AppDimens.fontSize11,
                color: AppColors.themeColor.primaryColor,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.themeColor.primaryColor,
              size: 14.sp,
            ),
          ],
        ),
      ),
      itemBuilder:
          (context) =>
      [
        _buildPopupMenuItem('pending', Icons.hourglass_top_rounded),
        _buildPopupMenuItem('completed', Icons.check_circle_rounded),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value, IconData icon) {
    final isSelected = controller.selectedContactStatus.value == value;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20.sp,
            color:
            isSelected
                ? AppColors.themeColor.primaryColor
                : AppColors.themeColor.textSecondaryColor,
          ),
          SizedBox(width: 12.w),
          Text(
            value.tr,
            style: AppTextStyle.regular7.copyWith(
              fontSize: AppDimens.fontSize13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color:
              isSelected
                  ? AppColors.themeColor.primaryColor
                  : AppColors.themeColor.textPrimaryColor,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            Icon(
              Icons.check_rounded,
              color: AppColors.themeColor.primaryColor,
              size: 16.sp,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final bool isPending = status.toLowerCase() == 'pending';
    final Color color =
    isPending ? const Color(0xFFF59E0B) : const Color(0xFF10B981);
    final String label = isPending ? 'pending'.tr : 'completed'.tr;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1.w),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9.sp,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    IconData? icon,
    required String label,
    required VoidCallback? onTap,
    Color? color,
    bool isSvg = false,
    String? svgPath,
  }) {
    final bool isDisabled = onTap == null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        constraints: BoxConstraints(minWidth: 60.w),
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 2.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color:
                isDisabled
                    ? Colors.grey.withOpacity(0.1)
                    : (color ?? AppColors.themeColor.primaryColor)
                    .withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                  isDisabled
                      ? Colors.grey.withOpacity(0.2)
                      : (color ?? AppColors.themeColor.primaryColor)
                      .withOpacity(0.3),
                  width: 1.w,
                ),
              ),
              child: isSvg && svgPath != null
                  ? SvgPicture.asset(
                svgPath,
                width: 18.sp,
                height: 18.sp,
                // Note: We don't use color here to keep the WhatsApp logo's original colors
              )
                  : Icon(
                icon,
                color:
                isDisabled
                    ? Colors.grey
                    : (color ?? AppColors.themeColor.primaryColor),
                size: 18.sp,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.bold,
                color:
                isDisabled
                    ? Colors.grey
                    : AppColors.themeColor.textPrimaryColor,
                letterSpacing: 0.1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      // IST is +5:30
      final istTime = dateTime.add(const Duration(hours: 5, minutes: 30));
      return DateFormat('dd MMM yyyy, hh:mm a').format(istTime);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildModeSwitch() {
    return Obx(() {
      final isWeb = controller.currentMode.value == 'web';
      final isSwitching = controller.isSwitchingMode.value;

      return Opacity(
        opacity: isSwitching ? 0.6 : 1.0,
        child: IgnorePointer(
          ignoring: isSwitching,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
            width: 120.w,
            height: 34.h,
            decoration: BoxDecoration(
              color: AppColors.themeColor.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: AppColors.themeColor.primaryColor.withOpacity(0.1),
                width: 1.w,
              ),
            ),
            child: Stack(
              children: [
                // Animated Selector Background
                AnimatedAlign(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutBack,
                  alignment: isWeb ? Alignment.centerRight : Alignment
                      .centerLeft,
                  child: Container(
                    width: 62.w,
                    height: 34.h,
                    decoration: BoxDecoration(
                      color: AppColors.themeColor.primaryColor,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.themeColor.primaryColor.withOpacity(
                              0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
                // Mode Labels
                Row(
                  children: [
                    Expanded(
                      child: _buildModeItem(
                          'app', Icons.phone_android_rounded, !isWeb),
                    ),
                    Expanded(
                      child: _buildModeItem(
                          'web', Icons.language_rounded, isWeb),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildModeItem(String mode, IconData icon, bool isActive) {
    return GestureDetector(
      onTap: () => controller.toggleUserMode(mode),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: AppTextStyle.bold8.copyWith(
            color: isActive ? Colors.white : AppColors.themeColor.primaryColor
                .withOpacity(0.5),
            fontSize: 9.sp,
            letterSpacing: 0.8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14.sp,
                color: isActive ? Colors.white : AppColors.themeColor
                    .primaryColor.withOpacity(0.4),
              ),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  mode.tr.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}