import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/core/models/all_lead_entity.dart';
import 'package:telecaller_app/core/models/lead_contact_id_entity.dart';
import 'package:telecaller_app/ui/views/auto_dialer/autodialer_controller.dart';

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
                      padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 16),
                      child: Column(
                        children: [
                          _buildLeadDropdownCard(isTablet),
                          const SizedBox(height: 16),
                          Obx(() => controller.selectedLeadDataset.value != null
                              ? _buildPremiumDashboardSection(isTablet)
                              : const SizedBox.shrink()),
                          const SizedBox(height: 16),
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
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),
                        
                        if (lead == null)
                          _buildInitialEmptyState(isTablet)
                        else ...[
                          // Contact Section header
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 16),
                              child: Column(
                                children: [
                                  _buildContactSectionHeader(isTablet, lead),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                          ),

                          // Pagewise Contacts List
                          _buildContactsPaginatedSliver(isTablet),
                        ],

                        // Bottom padding to avoid overlap with sticky bar
                        const SliverToBoxAdapter(child: SizedBox(height: 120)),
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
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.themeColor.textPrimaryColor, size: 20),
            onPressed: () => Get.back(),
          ),
          Expanded(
            child: Text(
              'auto_dialer'.tr.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.themeColor.textPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 2,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Obx(() => Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${controller.successRate.toStringAsFixed(1)}%',
              style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPremiumDashboardSection(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.themeColor.primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'campaign_performance'.tr,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.themeColor.primaryColor,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Obx(() => Text(
              value.value.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'Poppins',
              ),
            )),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.themeColor.cardBgColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 15,
              offset: const Offset(0, 8),
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.themeColor.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.folder_copy_rounded, color: AppColors.themeColor.primaryColor, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'lead_dataset'.tr,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.themeColor.textPrimaryColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                if (leads.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.themeColor.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${leads.length} ${"active".tr}',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.themeColor.primaryColor),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.themeColor.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.themeColor.bordercolror),
              ),
              child: leads.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selected?.id,
                        hint: Text(
                          'select_a_campaign…'.tr,
                          style: TextStyle(color: AppColors.themeColor.textSecondaryColor, fontSize: 13),
                        ),
                        icon: Icon(Icons.unfold_more_rounded, color: AppColors.themeColor.primaryColor, size: 20),
                        items: [
                          ...leads.map((lead) => DropdownMenuItem<String>(
                                value: lead.id,
                                child: Text(
                                  lead.name ?? 'Unnamed',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
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
                                  style: TextStyle(fontSize: 12, color: AppColors.themeColor.primaryColor, fontWeight: FontWeight.bold),
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
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.themeColor.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.themeColor.primaryColor, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${"active".tr}: ${selected.name}',
                        style: TextStyle(color: AppColors.themeColor.primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.clearLeadSelection(),
                      child: Icon(Icons.close_rounded, color: AppColors.themeColor.primaryColor, size: 16),
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.themeColor.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.people_alt_rounded, color: AppColors.themeColor.primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'contacts_queue'.tr,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.themeColor.textSecondaryColor,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                lead.name ?? 'Dataset',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.themeColor.textPrimaryColor,
                  fontFamily: 'Poppins',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Obx(() => Row(
          children: [
            _buildStatusFilterDropdown(),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.themeColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${controller.totalContacts.value} ${"reachable".tr}',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.themeColor.primaryColor),
              ),
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildContactsPaginatedSliver(bool isTablet) {
    final hPad = isTablet ? 32.0 : 16.0;

    return GetBuilder<AutoDialerController>(
      builder: (ctrl) {
        final contactsCtrl = ctrl.pagewiseContactsController;
        if (contactsCtrl == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

        return PagewiseSliverList<LeadContactIdLeadContacts>(
          pageLoadController: contactsCtrl,
          loadingBuilder: (context) => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          noItemsFoundBuilder: (context) => Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.themeColor.cardBgColor, borderRadius: BorderRadius.circular(16)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.contact_phone_outlined, size: 48, color: AppColors.themeColor.textSecondaryColor),
                  const SizedBox(height: 12),
                  Text(
                    'No contacts found for this lead',
                    style: TextStyle(color: AppColors.themeColor.textSecondaryColor, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          retryBuilder: (context, retryFn) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              const Text('Failed to load contacts'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: retryFn,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.themeColor.primaryColor),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 24),
            ],
          ),
          itemBuilder: (context, LeadContactIdLeadContacts lead, int index) {
            return Obx(() {
              final isCurrent = controller.currentContact.value?.id == lead.id;
              final String name = lead.contact?.name ?? 'Unknown';
              final String phone = lead.contact?.phone ?? 'No phone';
              final String status = lead.status ?? '';

              return Padding(
                padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCurrent ? AppColors.themeColor.primaryColor.withOpacity(0.05) : AppColors.themeColor.cardBgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCurrent ? AppColors.themeColor.primaryColor.withOpacity(0.3) : AppColors.themeColor.bordercolror.withOpacity(0.5),
                      width: isCurrent ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isCurrent ? AppColors.themeColor.primaryColor.withOpacity(0.1) : Colors.black.withOpacity(0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isCurrent ? [const Color(0xFF6366F1), const Color(0xFF4F46E5)] : [Colors.grey.shade200, Colors.grey.shade100],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            name[0].toUpperCase(),
                            style: TextStyle(
                              color: isCurrent ? Colors.white : AppColors.themeColor.textPrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.themeColor.textPrimaryColor, fontSize: 15, fontFamily: 'Poppins')),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.phone_outlined, size: 12, color: AppColors.themeColor.textSecondaryColor),
                                const SizedBox(width: 4),
                                Text(phone, style: TextStyle(color: AppColors.themeColor.textSecondaryColor, fontSize: 13, fontWeight: FontWeight.w500)),
                              ],
                            ),
                            if (status.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                child: Text(status, style: const TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => controller.makeManualCall(lead),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                            child: const Icon(Icons.call_rounded, color: Colors.green, size: 22),
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

      return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        margin: EdgeInsets.all(isIdle ? 0 : 16),
        decoration: BoxDecoration(
          color: isIdle ? Colors.transparent : AppColors.themeColor.cardColor.withOpacity(0.95),
          borderRadius: BorderRadius.circular(isIdle ? 0 : 32),
          boxShadow: [
            if (!isIdle)
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
          ],
          border: isIdle ? null : Border.all(color: AppColors.themeColor.bordercolror.withOpacity(0.2)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isIdle ? 0 : 32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Padding(
              padding: EdgeInsets.all(isIdle ? 0 : 8),
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
      
      if (!hasLead || !isPendingView) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                _buildActiveAvatar(isDialing),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        current?.contact?.name ?? 'prepare_call'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.themeColor.textPrimaryColor,
                          fontFamily: 'Poppins',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isDialing ? Colors.green : (isCountdown ? Colors.orange : Colors.grey)).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isDialing ? 'on_call'.tr.toUpperCase() : (isCountdown ? 'next_dial'.tr.toUpperCase() : 'paused'.tr.toUpperCase()),
                          style: TextStyle(
                            fontSize: 9,
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.themeColor.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.themeColor.bordercolror.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              isCountdown ? controller.countdown.value.toString() : controller.callTimer.value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: AppColors.themeColor.textPrimaryColor,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Actions
          Row(
            children: [
              _buildMiniControlButton(
                onTap: () => isPaused ? controller.resumeDialing() : controller.pauseDialing(),
                icon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                color: isPaused ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 12),
              _buildMiniControlButton(
                onTap: () => controller.stopDialing(),
                icon: Icons.stop_rounded,
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveAvatar(bool isDialing) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (isDialing) _PulsingRing(color: AppColors.themeColor.primaryColor),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: AppColors.themeColor.primaryColor.withOpacity(0.12), shape: BoxShape.circle),
          child: Icon(Icons.phone_in_talk_rounded, color: AppColors.themeColor.primaryColor, size: 22),
        ),
      ],
    );
  }

  Widget _buildMiniControlButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.32)),
          ),
          child: Icon(icon, color: color, size: 24),
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
        height: 60,
        width: width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.35),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 1.2,
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
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Premium Glow Icon
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
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
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.themeColor.cardBgColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.themeColor.primaryColor.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.dashboard_customize_rounded,
                      size: 48,
                      color: AppColors.themeColor.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Text Content
              Text(
                'ready_to_start'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.themeColor.textPrimaryColor,
                  fontFamily: 'Poppins',
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'select_a_lead_dataset_above_to_begin_your_outreach_campaign'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.themeColor.textSecondaryColor,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 48),
              // Subtle Indicator Arrow
              Icon(
                Icons.keyboard_double_arrow_up_rounded,
                color: AppColors.themeColor.primaryColor.withOpacity(0.3),
                size: 24,
              ),
            ],
          ),
        ),
      ));
  }

  Widget _buildStatusFilterDropdown() {
    return PopupMenuButton<String>(
      onSelected: (val) => controller.onContactStatusChanged(val),
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.themeColor.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.themeColor.bordercolror.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list_rounded, color: AppColors.themeColor.primaryColor, size: 16),
            const SizedBox(width: 6),
            Text(
              controller.selectedContactStatus.value.tr,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.themeColor.primaryColor,
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.themeColor.primaryColor, size: 14),
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
            size: 20,
            color: isSelected ? AppColors.themeColor.primaryColor : AppColors.themeColor.textSecondaryColor,
          ),
          const SizedBox(width: 12),
          Text(
            value.tr,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.themeColor.primaryColor : AppColors.themeColor.textPrimaryColor,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            Icon(Icons.check_rounded, color: AppColors.themeColor.primaryColor, size: 16),
          ],
        ],
      ),
    );
  }
}

class _PulsingRing extends StatefulWidget {
  final Color color;
  const _PulsingRing({Key? key, required this.color}) : super(key: key);
  @override
  _PulsingRingState createState() => _PulsingRingState();
}

class _PulsingRingState extends State<_PulsingRing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 40 + (_controller.value * 20),
          height: 40 + (_controller.value * 20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: widget.color.withOpacity(1 - _controller.value), width: 2),
          ),
        );
      },
    );
  }
}
