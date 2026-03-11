import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:get/get.dart';
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
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: CustomAppBar(
        leading: const SizedBox(),
        title: const Text(
          'Auto Dialer Pro',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => controller.resetLeads(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Stats Card ───────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    isTablet ? 32 : 16, isTablet ? 32 : 16, isTablet ? 32 : 16, 0),
                child: Column(
                  children: [
                    _buildPerformanceStatsCard(isTablet),
                    const SizedBox(height: 16),
                    _buildCurrentCallCard(isTablet),
                    const SizedBox(height: 16),
                    _buildDialerControlsCard(isTablet),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── Lead Dropdown Card + Contact section ─────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    isTablet ? 32 : 16, 0, isTablet ? 32 : 16, 0),
                child: Column(
                  children: [
                    _buildLeadDropdownCard(isTablet),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── Contact Section header (only when lead selected) ─
            SliverToBoxAdapter(
              child: Obx(() {
                final lead = controller.selectedLeadDataset.value;
                if (lead == null) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                      isTablet ? 32 : 16, 0, isTablet ? 32 : 16, 8),
                  child: _buildContactSectionHeader(isTablet, lead),
                );
              }),
            ),

            // ── Pagewise Contacts List ────────────────────
            _buildContactsPaginatedSliver(isTablet),

            // bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
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
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.folder_open,
                      color: Colors.indigo, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Select Lead Dataset',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                    fontFamily: 'Poppins',
                  ),
                ),
                const Spacer(),
                Text(
                  '${leads.length} / ${controller.totalLeads.value}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.indigo,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: leads.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selected?.id,
                        hint: const Text(
                          'Choose a dataset…',
                          style: TextStyle(color: Color(0xFF94A3B8)),
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: Colors.indigo),
                        items: [
                          // Normal lead items
                          ...leads.map(
                            (lead) => DropdownMenuItem<String>(
                              value: lead.id,
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.indigo.withOpacity(0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.folder_rounded,
                                        color: Colors.indigo, size: 16),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          lead.name ?? 'Unnamed',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: Color(0xFF1E293B),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if ((lead.status ?? '').isNotEmpty)
                                          Text(
                                            lead.status!,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Load More entry
                          if (hasMore)
                            DropdownMenuItem<String>(
                              value: '__load_more__',
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isLoadingMore)
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  else
                                    const Icon(Icons.expand_more,
                                        color: Colors.indigo, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    isLoadingMore
                                        ? 'Loading…'
                                        : 'Load More',
                                    style: const TextStyle(
                                      color: Colors.indigo,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                        onChanged: (val) {
                          if (val == null) return;
                          if (val == '__load_more__') {
                            // Trigger next page fetch
                            controller.loadMoreLeadsForDropdown();
                            return;
                          }
                          // Select lead
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

            // Selected lead info chip
            if (selected != null) ...[  
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.indigo.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.indigo, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selected.name ?? 'Selected',
                        style: const TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.clearLeadSelection(),
                      child: const Icon(Icons.close,
                          color: Colors.indigo, size: 16),
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.contact_phone, color: Colors.green, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Contacts — ${lead.name ?? ''}',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
              fontFamily: 'Poppins',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Obx(() => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${controller.contactQueue.length} / ${controller.totalContacts.value}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.contact_phone_outlined,
                      size: 48, color: Colors.blueGrey[300]),
                  const SizedBox(height: 12),
                  Text(
                    'No contacts found for this lead',
                    style: TextStyle(
                      color: Colors.blueGrey[400],
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
                    ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Retry',
                    style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 24),
            ],
          ),
          itemBuilder:
              (context, LeadContactIdLeadContacts lead, int index) {
            return Obx(() {
              final isCurrent =
                  controller.currentContact.value?.id == lead.id;
              return Padding(
                padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? Colors.green.withOpacity(0.08)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isCurrent
                          ? Colors.green.withOpacity(0.4)
                          : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: isCurrent
                            ? Colors.green.withOpacity(0.15)
                            : Colors.indigo.withOpacity(0.1),
                        child: Text(
                          (lead.contact?.name ?? '?')[0].toUpperCase(),
                          style: TextStyle(
                            color:
                                isCurrent ? Colors.green : Colors.indigo,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lead.contact?.name ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              lead.contact?.phone ?? 'No phone',
                              style: TextStyle(
                                color: Colors.blueGrey[500],
                                fontSize: 13,
                              ),
                            ),
                            if ((lead.status ?? '').isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  lead.status!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => controller.makeManualCall(lead),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.call,
                            color: Colors.green,
                            size: 20,
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
  Widget _buildPerformanceStatsCard(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.analytics_outlined,
                    color: Colors.indigo, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Performance',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 24 : 20),
          Row(
            children: [
              Expanded(
                  child: _buildStatItem(
                      'Attempts', controller.totalAttempts, isTablet, Colors.indigo)),
              Container(width: 1, height: 40, color: Colors.grey[200]),
              Expanded(
                  child: _buildStatItem(
                      'Connected', controller.connected, isTablet, Colors.green)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          Row(
            children: [
              Expanded(
                  child: _buildStatItem(
                      'Successful', controller.successful, isTablet, Colors.blue)),
              Container(width: 1, height: 40, color: Colors.grey[200]),
              Expanded(
                  child: _buildStatItem(
                      'Failed', controller.failed, isTablet, Colors.red)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, RxInt value, bool isTablet, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 13 : 12,
            color: Colors.blueGrey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Obx(
          () => Text(
            value.value.toString(),
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'Poppins',
            ),
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
      final isDialing = controller.status.value == 'dialing';

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(isTablet ? 24 : 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDialing
                ? [const Color(0xFF6366F1), const Color(0xFF4F46E5)]
                : [Colors.white, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDialing
                  ? Colors.indigo.withOpacity(0.3)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isDialing
                        ? Colors.white.withOpacity(0.2)
                        : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: isDialing ? Colors.white : Colors.indigo,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDialing
                            ? 'Currently Calling'
                            : controller.status.value == 'paused'
                                ? 'Dialing Paused'
                                : controller.countdown.value > 0
                                    ? 'Next Call In'
                                    : 'Next in Queue',
                        style: TextStyle(
                          color: isDialing
                              ? Colors.white70
                              : Colors.blue[500],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        lead?.contact?.name ?? 'No active lead',
                        style: TextStyle(
                          color: isDialing
                              ? Colors.white
                              : const Color(0xFF1E293B),
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                if (isDialing)
                  const Icon(Icons.graphic_eq, color: Colors.white, size: 24),
                if (!isDialing && controller.countdown.value > 0)
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.indigo, width: 2),
                    ),
                    child: Text(
                      '${controller.countdown.value}',
                      style: const TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
              ],
            ),
            if (lead != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDialing
                      ? Colors.white.withOpacity(0.1)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDialing
                        ? Colors.white.withOpacity(0.2)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone_in_talk,
                      color: isDialing ? Colors.white : Colors.green,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      lead.contact?.phone ?? 'N/A',
                      style: TextStyle(
                        color: isDialing
                            ? Colors.white
                            : const Color(0xFF475569),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    if (isDialing)
                      Obx(() => Text(
                            controller.callTimer.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          )),
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
  // DIALER CONTROLS CARD
  // ─────────────────────────────────────────────
  Widget _buildDialerControlsCard(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dialer Status',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 20),
          // Status indicator
          Obx(() => Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: controller.status.value == 'dialing'
                      ? Colors.blue.withOpacity(0.05)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: controller.status.value == 'dialing'
                        ? Colors.blue.withOpacity(0.2)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: controller.status.value == 'dialing'
                            ? Colors.green
                            : Colors.blueGrey[400],
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (controller.status.value == 'dialing')
                            BoxShadow(
                              color: Colors.green.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      controller.status.value.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: controller.status.value == 'dialing'
                            ? Colors.blue
                            : Colors.blueGrey[600],
                      ),
                    ),
                    const Spacer(),
                    if (controller.status.value == 'dialing')
                      Obx(() => Text(
                            controller.callTimer.value,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          )),
                  ],
                ),
              )),
          const SizedBox(height: 24),
          // Start button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Obx(() => ElevatedButton.icon(
                  onPressed: controller.status.value == 'dialing'
                      ? null
                      : () => controller.startDialing(),
                  icon: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 28),
                  label: const Text(
                    'Start Auto Dialer',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    disabledBackgroundColor: Colors.blueGrey[300],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                )),
          ),
          const SizedBox(height: 12),
          // Pause / Stop row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.pauseDialing(),
                  icon: const Icon(Icons.pause_rounded, size: 20),
                  label: const Text('Pause'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.stopDialing(),
                  icon: const Icon(Icons.stop_rounded,
                      size: 20, color: Colors.red),
                  label: const Text('Stop',
                      style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
