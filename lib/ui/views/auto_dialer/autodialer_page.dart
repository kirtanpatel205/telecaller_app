import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/core/controllers/overlay_controller.dart';
import 'package:telecaller_app/core/models/all_lead_entity.dart';
import 'package:telecaller_app/core/models/lead_contact_id_entity.dart';
import 'package:telecaller_app/ui/views/auto_dialer/autodialer_controller.dart';
import 'package:telecaller_app/ui/widgets/custom-appbar.dart';
import 'package:telecaller_app/constants/app_dimens.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/ui/views/home/overlay/overlay_pages.dart';

// Note: flutter_pagewise is still needed for the contacts PagewiseSliverList

class AutoDialerPage extends GetView<AutoDialerController> {
  const AutoDialerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return Scaffold(
      backgroundColor: AppColors.themeColor.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              // ── FIXED TOP SECTION ──────────────────────
              Container(
                decoration: BoxDecoration(
                  color: AppColors.themeColor.scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSimpleAppBar(context),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: isTablet ? 32.w : 16.w),
                      child: Column(
                        children: [
                          _buildLeadDropdownCard(isTablet),
                          SizedBox(height: 16.h),
                          Obx(() => controller.selectedLeadDataset.value != null
                              ? _buildPremiumDashboardSection(isTablet)
                              : const SizedBox.shrink()),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── SCROLLABLE MIDDLE SECTION ──────────────
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => controller.resetLeads(),
                  displacement: 20,
                  color: AppColors.themeColor.primaryColor,
                  child: Obx(() {
                    final lead = controller.selectedLeadDataset.value;
                    
                    return CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(child: SizedBox(height: 16.h)),
                        
                        if (lead == null)
                          _buildInitialEmptyState(isTablet)
                        else ...[
                          // Contact Section header
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: isTablet ? 32.w : 16.w),
                              child: Column(
                                children: [
                                  _buildContactSectionHeader(isTablet, lead),
                                  SizedBox(height: 12.h),
                                ],
                              ),
                            ),
                          ),

                          // Pagewise Contacts List
                          _buildContactsPaginatedSliver(isTablet),
                        ],

                        // Bottom padding to avoid overlap with sticky bar
                        SliverToBoxAdapter(child: SizedBox(height: 120.h)),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
          
          // ── STICKY CONTROL CENTER ──────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildStickyControlCenter(isTablet),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleAppBar(BuildContext context) {
    return CustomAppBar(
      leading: SizedBox(),
      titleText: 'auto_dialer'.tr,
      actions: [
        Obx(() => Container(
          margin: EdgeInsets.only(right: 16.w),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            '${controller.successRate.toStringAsFixed(1)}%',
            style: TextStyle(
              color: Colors.green,
              fontSize: AppDimens.fontSize10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ).marginSymmetric(vertical: 12.h)),
      ],
    );
  }

  Widget _buildPremiumDashboardSection(bool isTablet) {
    return Column(
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
        _buildStatCard('total'.tr, controller.totalAttempts, AppColors.themeColor.primaryColor),
        _buildStatCard('success'.tr, controller.successful, const Color(0xFF10B981)),
        _buildStatCard('failed'.tr, controller.failed, const Color(0xFFEF4444)),
      ],
    );
  }

  Widget _buildStatCard(String label, RxInt value, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Obx(() => Text(
              value.value.toString(),
              style: TextStyle(
                fontSize: AppDimens.fontSize20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            )),
            SizedBox(height: 4.h),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: AppDimens.fontSize9,
                fontWeight: FontWeight.bold,
                color: AppColors.themeColor.textSecondaryColor,
                letterSpacing: 1,
              ),
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
                        color: AppColors.themeColor.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(Icons.folder_copy_rounded, color: AppColors.themeColor.primaryColor, size: 18.sp),
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
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.themeColor.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '${leads.length} ${"active".tr}',
                      style: TextStyle(fontSize: AppDimens.fontSize10, fontWeight: FontWeight.bold, color: AppColors.themeColor.primaryColor),
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
              child: leads.isEmpty
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      child: SizedBox(height: 20.h, width: 20.w, child: const CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selected?.id,
                        hint: Text(
                          'select_a_campaign…'.tr,
                          style: TextStyle(color: AppColors.themeColor.textSecondaryColor, fontSize: AppDimens.fontSize13),
                        ),
                        icon: Icon(Icons.unfold_more_rounded, color: AppColors.themeColor.primaryColor, size: 20.sp),
                        items: [
                          ...leads.map((lead) => DropdownMenuItem<String>(
                                value: lead.id,
                                child: Text(
                                  lead.name ?? 'Unnamed',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: AppDimens.fontSize14,
                                    color: AppColors.themeColor.textPrimaryColor,
                                  ),
                                ),
                              )),
                          if (hasMore)
                            DropdownMenuItem<String>(
                              value: '__load_more__',
                              child: Center(
                                child: Text(
                                  isLoadingMore ? 'Loading…' : 'Load More',
                                  style: TextStyle(fontSize: AppDimens.fontSize12, color: AppColors.themeColor.primaryColor, fontWeight: FontWeight.bold),
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
                          final match = leads.firstWhere((l) => l.id == val, orElse: () => leads.first);
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
                    Icon(Icons.check_circle_rounded, color: AppColors.themeColor.primaryColor, size: 16.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        '${"active".tr}: ${selected.name}',
                        style: TextStyle(color: AppColors.themeColor.primaryColor, fontWeight: FontWeight.bold, fontSize: AppDimens.fontSize12),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.clearLeadSelection(),
                      child: Icon(Icons.close_rounded, color: AppColors.themeColor.primaryColor, size: 16.sp),
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
          child: Icon(Icons.people_alt_rounded, color: AppColors.themeColor.primaryColor, size: 20.sp),
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
        Obx(() => Row(
          children: [
            _buildStatusFilterDropdown(),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.themeColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '${controller.totalContacts.value} ${"reachable".tr}',
                style: TextStyle(fontSize: AppDimens.fontSize11, fontWeight: FontWeight.bold, color: AppColors.themeColor.primaryColor),
              ),
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildContactsPaginatedSliver(bool isTablet) {
    final hPad = isTablet ? 32.0.w : 16.0.w;

    return GetBuilder<AutoDialerController>(
      builder: (ctrl) {
        final contactsCtrl = ctrl.pagewiseContactsController;
        if (contactsCtrl == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

        return PagewiseSliverList<LeadContactIdLeadContacts>(
          pageLoadController: contactsCtrl,
          loadingBuilder: (context) => Padding(
            padding: EdgeInsets.all(24.w),
            child: const Center(child: CircularProgressIndicator()),
          ),
          noItemsFoundBuilder: (context) => Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24.h),
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(color: AppColors.themeColor.cardBgColor, borderRadius: BorderRadius.circular(16.r)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.contact_phone_outlined, size: 48.sp, color: AppColors.themeColor.textSecondaryColor),
                  SizedBox(height: 12.h),
                  Text(
                    'No contacts found for this lead',
                    style: AppTextStyle.medium7.copyWith(color: AppColors.themeColor.textSecondaryColor),
                  ),
                ],
              ),
            ),
          ),
          retryBuilder: (context, retryFn) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 24.h),
              Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
              SizedBox(height: 12.h),
              Text('Failed to load contacts', style: AppTextStyle.medium7.copyWith(color: AppColors.themeColor.textPrimaryColor)),
              SizedBox(height: 12.h),
              ElevatedButton(
                onPressed: retryFn,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.themeColor.primaryColor),
                child: Text('Retry', style: AppTextStyle.bold7.copyWith(color: Colors.white)),
              ),
              SizedBox(height: 24.h),
            ],
          ),
          itemBuilder: (context, LeadContactIdLeadContacts lead, int index) {
            return Obx(() {
              final isCurrent = controller.currentContact.value?.id == lead.id;
              final String name = lead.contact?.name ?? 'Unknown';
              final String phone = lead.contact?.phone ?? 'No phone';
              final String status = lead.status ?? '';

              return Padding(
                padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 12.h),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isCurrent ? AppColors.themeColor.primaryColor.withOpacity(0.05) : AppColors.themeColor.cardBgColor,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isCurrent ? AppColors.themeColor.primaryColor.withOpacity(0.3) : AppColors.themeColor.bordercolror.withOpacity(0.5),
                      width: isCurrent ? 1.5.w : 1.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isCurrent ? AppColors.themeColor.primaryColor.withOpacity(0.1) : Colors.black.withOpacity(0.03),
                        blurRadius: 15.r,
                        offset: Offset(0, 8.h),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isCurrent ? [AppColors.themeColor.primaryColor, AppColors.themeColor.primaryColor.withOpacity(0.8)] : [Colors.grey.shade200, Colors.grey.shade100],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            name[0].toUpperCase(),
                            style: AppTextStyle.bold7.copyWith(
                              color: isCurrent ? Colors.white : AppColors.themeColor.textPrimaryColor,
                              fontSize: AppDimens.fontSize18,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: AppTextStyle.bold7.copyWith(color: AppColors.themeColor.textPrimaryColor, fontSize: AppDimens.fontSize15)),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(Icons.phone_outlined, size: 12.sp, color: AppColors.themeColor.textSecondaryColor),
                                SizedBox(width: 4.w),
                                Text(phone, style: AppTextStyle.medium7.copyWith(color: AppColors.themeColor.textSecondaryColor, fontSize: AppDimens.fontSize13)),
                              ],
                            ),
                            if (status.isNotEmpty) ...[
                              SizedBox(height: 8.h),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(6.r)),
                                child: Text(status, style: AppTextStyle.bold7.copyWith(fontSize: AppDimens.fontSize10, color: Colors.orange)),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => controller.makeManualCall(lead),
                          borderRadius: BorderRadius.circular(14.r),
                          child: Container(
                            width: 44.w,
                            height: 44.h,
                            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(14.r)),
                            child: Icon(Icons.call_rounded, color: Colors.green, size: 22.sp),
                          ),
                        ),
                      ),
                    ],
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

      return Container(
        margin: EdgeInsets.all(isIdle ? 0 : 16.w),
        decoration: BoxDecoration(
          color: isIdle ? Colors.transparent : AppColors.themeColor.cardColor.withOpacity(0.95),
          borderRadius: BorderRadius.circular(isIdle ? 0 : 32.r),
          boxShadow: [
            if (!isIdle)
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30.r,
                offset: Offset(0, 15.h),
              ),
          ],
          border: isIdle ? null : Border.all(color: AppColors.themeColor.bordercolror.withOpacity(0.2)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isIdle ? 0 : 32.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Padding(
              padding: EdgeInsets.all(isIdle ? 0 : 8.w),
              child: isIdle ? _buildIdleStartButton(isTablet) : _buildActiveControlBar(isTablet),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildIdleStartButton(bool isTablet) {
    return Obx(() {
      final hasLead = controller.selectedLeadDataset.value != null;
      final isPendingView = controller.selectedContactStatus.value == 'pending';
      
      if (!hasLead) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        child: _buildPremiumButton(
          onTap: () => controller.startDialing(),
          label: 'start_dialer'.tr,
          icon: Icons.rocket_launch_rounded,
          gradient: [AppColors.themeColor.primaryColor, AppColors.themeColor.primaryColor.withOpacity(0.8)],
        ),
      );
    });
  }

  Widget _buildActiveControlBar(bool isTablet) {
    final status = controller.status.value;
    final isPaused = status == 'paused';
    final isDialing = status == 'dialing';
    final isCountdown = status == 'counting_down';
    final current = controller.currentContact.value;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (Get.isRegistered<OverlayController>()) {
                      final overlayCtrl = Get.find<OverlayController>();
                      if (overlayCtrl.countdown.value > 0) {
                        overlayCtrl.countdown.value = 0; // Instantly make the call
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
                        current?.contact?.name ?? 'prepare_call'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppDimens.fontSize14,
                          color: AppColors.themeColor.textPrimaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: (isDialing ? Colors.green : (isCountdown ? Colors.orange : Colors.grey)).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          isDialing ? 'on_call'.tr.toUpperCase() : (isCountdown ? 'next_dial'.tr.toUpperCase() : 'paused'.tr.toUpperCase()),
                          style: TextStyle(
                            fontSize: AppDimens.fontSize9,
                            color: isDialing ? Colors.green : (isCountdown ? Colors.orange : AppColors.themeColor.textSecondaryColor),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Timer with a more modern "Digital" feel
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.themeColor.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.themeColor.bordercolror.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Text(
              isCountdown ? controller.countdown.value.toString() : controller.callTimer.value,
              style: TextStyle(
                fontSize: AppDimens.fontSize16,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: AppColors.themeColor.textPrimaryColor,
                letterSpacing: 1,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          // Actions
          Row(
            children: [
              _buildMiniControlButton(
                onTap: () => isPaused ? controller.resumeDialing() : controller.pauseDialing(),
                icon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                color: isPaused ? Colors.green : Colors.orange,
                isPrimary: isPaused,
              ),
              SizedBox(width: 8.w),
              _buildMiniControlButton(
                onTap: () => controller.stopDialing(),
                icon: Icons.stop_rounded,
                color: Colors.red,
                isPrimary: false,
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
        color: isDialing ? Colors.green.withOpacity(0.15) : AppColors.themeColor.primaryColor.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDialing ? Colors.green.withOpacity(0.5) : AppColors.themeColor.primaryColor.withOpacity(0.3),
          width: 1.5.w,
        ),
        boxShadow: isDialing ? [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            blurRadius: 10.r,
            spreadRadius: 2.r,
          )
        ] : null,
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
          border: isPrimary ? null : Border.all(color: color.withOpacity(0.4), width: 1.5.w),
        ),
        child: Icon(
          icon,
          color: isPrimary ? Colors.white : color,
          size: 22.sp,
        ),
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
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
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
                          color: AppColors.themeColor.primaryColor.withOpacity(0.1),
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
                'select_a_lead_dataset_above_to_begin_your_outreach_campaign'.tr,
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
      ));
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
          border: Border.all(color: AppColors.themeColor.bordercolror.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list_rounded, color: AppColors.themeColor.primaryColor, size: 16.sp),
            SizedBox(width: 6.w),
            Text(
              controller.selectedContactStatus.value.tr,
              style: AppTextStyle.bold7.copyWith(
                fontSize: AppDimens.fontSize11,
                color: AppColors.themeColor.primaryColor,
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.themeColor.primaryColor, size: 14.sp),
          ],
        ),
      ),
      itemBuilder: (context) => [
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
            color: isSelected ? AppColors.themeColor.primaryColor : AppColors.themeColor.textSecondaryColor,
          ),
          SizedBox(width: 12.w),
          Text(
            value.tr,
            style: AppTextStyle.regular7.copyWith(
              fontSize: AppDimens.fontSize13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.themeColor.primaryColor : AppColors.themeColor.textPrimaryColor,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            Icon(Icons.check_rounded, color: AppColors.themeColor.primaryColor, size: 16.sp),
          ],
        ],
      ),
    );
  }
}

