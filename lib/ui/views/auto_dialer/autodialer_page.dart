import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/core/models/all_lead_entity.dart';
import 'package:telecaller_app/core/models/lead_contact_id_entity.dart';
import 'package:telecaller_app/ui/views/auto_dialer/autodialer_controller.dart';
import '../../widgets/custom-appbar.dart';

// Note: flutter_pagewise is still needed for the contacts PagewiseSliverList

class AutoDialerPage extends GetView<AutoDialerController> {
  const AutoDialerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return Scaffold(
      backgroundColor: AppColors.themeColor.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        leading: const SizedBox(),
        // backgroundColor: Colors.transparent,
        title: Text(
          'auto_dialer'.tr,
          style: TextStyle(
            color: AppColors.themeColor.textPrimaryColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient decoration
          // Positioned(
          //   top: -100,
          //   right: -50,
          //   child: Container(
          //     width: 300,
          //     height: 300,
          //     decoration: BoxDecoration(
          //       shape: BoxShape.circle,
          //       color: Colors.indigo.withOpacity(0.05),
          //     ),
          //   ),
          // ),

          RefreshIndicator(
            onRefresh: () async => controller.resetLeads(),
            displacement: 100,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 100)),

                // ── PREMIMUM DASHBOARD ──────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 16),
                    child: _buildPremiumDashboard(isTablet),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // ── Lead Dropdown Card ─────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 16),
                    child: _buildLeadDropdownCard(isTablet),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // ── Contact Section header (only when lead selected) ─
                SliverToBoxAdapter(
                  child: Obx(() {
                    final lead = controller.selectedLeadDataset.value;
                    if (lead == null) return const SizedBox.shrink();
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 16),
                      child: Column(
                        children: [
                           _buildContactSectionHeader(isTablet, lead),
                           const SizedBox(height: 12),
                        ],
                      ),
                    );
                  }),
                ),

                // ── Pagewise Contacts List ────────────────────
                _buildContactsPaginatedSliver(isTablet),

                // bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // LEAD DROPDOWN CARD (pagewise)
  // ─────────────────────────────────────────────
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
                        color: Colors.indigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.folder_copy_rounded, color: Colors.indigo, size: 18),
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
                      color: Colors.indigo.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${leads.length} ${"active".tr}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigo),
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
                        icon: const Icon(Icons.unfold_more_rounded, color: Colors.indigo, size: 20),
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
                                  style: const TextStyle(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.bold),
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
                  color: Colors.indigo.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.indigo, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${"active".tr}: ${selected.name}',
                        style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.clearLeadSelection(),
                      child: const Icon(Icons.close_rounded, color: Colors.indigo, size: 16),
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

  // ─────────────────────────────────────────────
  // CONTACT SECTION HEADER
  // ─────────────────────────────────────────────
  Widget _buildContactSectionHeader(bool isTablet, AllLeadLeads lead) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.people_alt_rounded, color: Colors.indigo, size: 20),
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
        Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${controller.totalContacts.value} ${"reachable".tr}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            )),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // PAGEWISE CONTACTS SLIVER
  // ─────────────────────────────────────────────
  Widget _buildContactsPaginatedSliver(bool isTablet) {
    final hPad = isTablet ? 32.0 : 16.0;

    return GetBuilder<AutoDialerController>(
      builder: (ctrl) {
        final contactsCtrl = ctrl.pagewiseContactsController;
        // When no lead is selected, return an empty box (not a sliver)
        if (contactsCtrl == null) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return PagewiseSliverList<LeadContactIdLeadContacts>(
          pageLoadController: contactsCtrl,
          // loadingBuilder — plain box widget, displayed as a list row while loading
          loadingBuilder: (context) => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          // noItemsFoundBuilder — plain box widget, library wraps it in SliverFillRemaining
          noItemsFoundBuilder: (context) => Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
        color: AppColors.themeColor.cardBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.contact_phone_outlined,
                      size: 48, color: AppColors.themeColor.textSecondaryColor),
                  const SizedBox(height: 12),
                  Text(
                    'No contacts found for this lead',
                    style: TextStyle(
                      color: AppColors.themeColor.textSecondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // retryBuilder — plain box widget, library wraps it in SliverFillRemaining
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
                style:
                    ElevatedButton.styleFrom(backgroundColor: AppColors.themeColor.primaryColor),
                child: const Text('Retry',
                    style: TextStyle(color: Colors.white)),
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
                    color: isCurrent
                        ? AppColors.themeColor.primaryColor.withOpacity(0.05)
                        : AppColors.themeColor.cardBgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCurrent
                          ? AppColors.themeColor.primaryColor.withOpacity(0.3)
                          : AppColors.themeColor.bordercolror.withOpacity(0.5),
                      width: isCurrent ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isCurrent
                            ? AppColors.themeColor.primaryColor.withOpacity(0.1)
                            : Colors.black.withOpacity(0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Modern Avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isCurrent
                                ? [const Color(0xFF6366F1), const Color(0xFF4F46E5)]
                                : [Colors.grey.shade200, Colors.grey.shade100],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            if (isCurrent)
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                          ],
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
                      // Information
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.themeColor.textPrimaryColor,
                                fontSize: 15,
                                fontFamily: 'Poppins',
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.phone_outlined, size: 12, color: AppColors.themeColor.textSecondaryColor),
                                const SizedBox(width: 4),
                                Text(
                                  phone,
                                  style: TextStyle(
                                    color: AppColors.themeColor.textSecondaryColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            if (status.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  status,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Action Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => controller.makeManualCall(lead),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.call_rounded,
                              color: Colors.green,
                              size: 22,
                            ),
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

  // ─────────────────────────────────────────────
  // PERFORMANCE STATS CARD
  // ─────────────────────────────────────────────
  Widget _buildPremiumDashboard(bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.themeColor.cardBgColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPerformanceStatsCard(isTablet),
          const Divider(height: 1, indent: 20, endIndent: 20),
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildCurrentCallCard(isTablet),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: _buildDialerControlsCard(isTablet),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceStatsCard(bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
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
                      color: AppColors.themeColor.textPrimaryColor,
                      letterSpacing: 1.5,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              Obx(() {
                final total = controller.totalAttempts.value;
                final succ = controller.successful.value;
                final rate = total > 0 ? (succ / total * 100).toStringAsFixed(1) : "0.0";
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.2)),
                  ),
                  child: Text(
                    '${"success_rate".tr}: $rate%'.tr,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildModernStatItem('total'.tr, controller.totalAttempts, Icons.call_outlined, const Color(0xFF6366F1)),
              _buildModernStatItem('success'.tr, controller.successful, Icons.star_outline_rounded, const Color(0xFFF59E0B)),
              _buildModernStatItem('failed'.tr, controller.failed, Icons.error_outline_rounded, const Color(0xFFEF4444)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatItem(String label, RxInt value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 10),
        Obx(() => Text(
              value.value.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.themeColor.textPrimaryColor,
                fontFamily: 'Poppins',
              ),
            )),
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
    );
  }

  // ─────────────────────────────────────────────
  // CURRENT CALL CARD
  // ─────────────────────────────────────────────
  Widget _buildCurrentCallCard(bool isTablet) {
    return Obx(() {
      final lead = controller.currentContact.value;
      final nextLead = controller.nextContact.value;
      final status = controller.status.value;
      final isDialing = status == 'dialing';
      final isSettled = status == 'settled';
      final isCountdown = status == 'counting_down';
      final cdValue = controller.countdown.value;

      Color mainColor = Colors.indigo;
      IconData icon = Icons.person;
      String statusText = 'ready_to_start'.tr;

      if (isDialing) {
        mainColor = const Color(0xFF6366F1);
        statusText = 'active_call'.tr;
        icon = Icons.graphic_eq_rounded;
      } else if (isSettled) {
        mainColor = const Color(0xFF10B981);
        statusText = 'settled'.tr;
        icon = Icons.check_circle_rounded;
      } else if (isCountdown) {
        mainColor = const Color(0xFFF59E0B);
        statusText = '${"next_in".tr} $cdValue'.tr;
        icon = Icons.timer_rounded;
      } else if (status == 'paused') {
        mainColor = const Color(0xFF64748B);
        statusText = 'paused'.tr;
        icon = Icons.pause_circle_rounded;
      }

      return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              mainColor.withOpacity(0.05),
              mainColor.withOpacity(0.15),
            ],
          ),
          border: Border.all(
            color: mainColor.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isDialing)
                       TweenAnimationBuilder(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(seconds: 1),
                        builder: (context, double value, child) {
                          return Container(
                            width: 50 + (value * 20),
                            height: 50 + (value * 20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: mainColor.withOpacity(0.2 * (1 - value)),
                                width: 2,
                              ),
                            ),
                          );
                        },
                      ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: mainColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: mainColor, size: 26),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lead?.contact?.name ?? 'select_a_lead'.tr,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.themeColor.textPrimaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (lead != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.phone_iphone_rounded, size: 16, color: mainColor),
                    const SizedBox(width: 10),
                    Text(
                      lead.contact?.phone ?? 'N/A',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.themeColor.textSecondaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    if (isDialing)
                      Text(
                        controller.callTimer.value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                          fontFamily: 'monospace',
                        ),
                      ),
                  ],
                ),
              ),
            ],
            if (nextLead != null && !isDialing) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                   Text(
                    'next'.tr,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    " : ${nextLead.contact?.name}" ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.themeColor.textPrimaryColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

  // ─────────────────────────────────────────────
  // DIALER CONTROLS CARD
  // ─────────────────────────────────────────────
  Widget _buildDialerControlsCard(bool isTablet) {
    return Obx(() {
      final status = controller.status.value;
      final isIdle = status == 'idle';
      final isPaused = status == 'paused';

      return Column(
        children: [
          Row(
            children: [
              // MAIN ACTION BUTTON (Start / Pause / Resume)
              Expanded(
                flex: 2,
                child: isIdle
                    ? (controller.selectedLeadDataset.value != null
                        ? _buildPremiumButton(
                            onTap: () => controller.startDialing(),
                            label: 'start_dialer'.tr,
                            icon: Icons.rocket_launch_rounded,
                            gradient: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
                          )
                        : const SizedBox.shrink()) // Hide if no lead selected
                    : _buildPremiumButton(
                        onTap: () {
                          if (isPaused) {
                            controller.resumeDialing();
                          } else {
                            controller.pauseDialing();
                          }
                        },
                        label: isPaused ? 'resume'.tr : 'paused'.tr,
                        icon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                        gradient: isPaused
                            ? const [Color(0xFF10B981), Color(0xFF059669)]
                            : const [Color(0xFFF59E0B), Color(0xFFD97706)],
                      ),
              ),
              if (!isIdle) ...[
                const SizedBox(width: 12),
                // STOP BUTTON
                _buildPremiumButton(
                  onTap: () => controller.stopDialing(),
                  label: 'stop'.tr,
                  icon: Icons.stop_rounded,
                  gradient: const [Color(0xFFEF4444), Color(0xFFDC2626)],
                  width: 100,
                ),
              ],
            ],
          ),
        ],
      );
    });
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
        height: 56,
        width: width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
