import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/core/models/lead_contact_id_entity.dart';
import 'leadscontact_controller.dart';

class LeadsContactPage extends GetView<LeadsContactController> {
  const LeadsContactPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1200;
    final isTablet = MediaQuery.of(context).size.width > 600 &&
        MediaQuery.of(context).size.width <= 1200;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Leads Contact',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Statistics Header
            _buildStatisticsHeader(context),

            // Search and Filter Bar
            _buildSearchAndFilterBar(context),

            // Leads Table/List
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: _buildLeadsTable(context),
            ),
          ],
        ),
      ),
    );
  }

  // Statistics Header Widget
  Widget _buildStatisticsHeader(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1200;

    return Container(
      color: Colors.grey[50],
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          // First Row of Stats
          isMobile
              ? Column(
            children: [
              _buildMobileStatRow(context, [
                ('Total', Obx(() => Text(
                  controller.totalLeadsId.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ))),
                ('Completed', const Text(
                  '4',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                )),
              ]),
              const SizedBox(height: 12),
              _buildMobileStatRow(context, [
                ('Pending', const Text(
                  '1',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                )),
                ('Scheduled', const Text(
                  '0',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9E9E9E),
                  ),
                )),
              ]),
            ],
          )
              : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatItem(
                  label: 'Total',
                  value: Obx(() => Text(
                    controller.totalLeadsId.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  )),
                ),
                SizedBox(width: isTablet ? 20 : 40),
                _buildStatItem(
                  label: 'Completed',
                  value: Obx(() => Text(
                    controller.completedCount.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  )),
                ),
                SizedBox(width: isTablet ? 20 : 40),
                _buildStatItem(
                  label: 'Pending',
                  value: Obx(() => Text(
                    controller.pendingCount.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  )),
                ),
                SizedBox(width: isTablet ? 20 : 40),
                _buildStatItem(
                  label: 'Scheduled',
                  value: Obx(() => Text(
                    controller.scheduledCount.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9E9E9E),
                    ),
                  )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Second Row of Stats
          isMobile
              ? Column(
            children: [
              _buildMobileStatRow(context, [
                ('Interested', Obx(() => Text(
                  controller.interestedCount.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8BC34A),
                  ),
                ))),
                ('Not Interested', Obx(() => Text(
                  controller.notInterestedCount.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF44336),
                  ),
                ))),
              ]),
              const SizedBox(height: 12),
              _buildMobileStatRow(context, [
                ('Follow Up', Obx(() => Text(
                  controller.followUpCount.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9C27B0),
                  ),
                ))),
                ('Invalid', Obx(() => Text(
                  controller.invalidCount.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF757575),
                  ),
                ))),
              ]),
            ],
          )
              : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatItem(
                  label: 'Interested',
                  value: Obx(() => Text(
                    controller.interestedCount.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8BC34A),
                    ),
                  )),
                ),
                SizedBox(width: isTablet ? 20 : 40),
                _buildStatItem(
                  label: 'Not Interested',
                  value: Obx(() => Text(
                    controller.notInterestedCount.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF44336),
                    ),
                  )),
                ),
                SizedBox(width: isTablet ? 20 : 40),
                _buildStatItem(
                  label: 'Follow Up',
                  value: Obx(() => Text(
                    controller.followUpCount.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9C27B0),
                    ),
                  )),
                ),
                SizedBox(width: isTablet ? 20 : 40),
                _buildStatItem(
                  label: 'Invalid',
                  value: Obx(() => Text(
                    controller.invalidCount.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF757575),
                    ),
                  )),
                ),
                SizedBox(width: isTablet ? 20 : 40),
                _buildStatItem(
                  label: 'No Response',
                  value: Obx(() => Text(
                    controller.noResponseCount.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFBDBDBD),
                    ),
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileStatRow(
      BuildContext context, List<(String, Widget)> stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: stats
          .map((stat) => Expanded(
        child: _buildStatItem(label: stat.$1, value: stat.$2),
      ))
          .toList(),
    );
  }

  Widget _buildStatItem({required String label, required Widget value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        value,
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // Search and Filter Bar
  Widget _buildSearchAndFilterBar(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      width: double.infinity,
      child: Column(
        children: [
          // Search Field
          TextField(
            onChanged: (value) => controller.updateSearch(value),
            decoration: InputDecoration(
              hintText: 'Search by name, phone...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Button Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildIconButton(
                  icon: Icons.refresh,
                  label: 'Reset',
                  onPressed: () => controller.resetAndReload(),
                  isMobile: isMobile,
                ),
                const SizedBox(width: 8),
                _buildIconButton(
                  icon: Icons.filter_list,
                  label: 'Filter',
                  onPressed: () => _showFilterDialog(),
                  isMobile: isMobile,
                ),
                const SizedBox(width: 8),
                _buildSortDropdown(isMobile),
                const SizedBox(width: 8),
                _buildIconButton(
                  icon: Icons.download,
                  label: 'Export',
                  onPressed: () => _exportData(),
                  isMobile: isMobile,
                  isPrimary: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isMobile,
    bool isPrimary = false,
  }) {
    if (isMobile) {
      return SizedBox(
        height: 40,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 16),
          label: Text(label, style: const TextStyle(fontSize: 12)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            backgroundColor:
            isPrimary ? const Color(0xFF2196F3) : Colors.white,
            foregroundColor:
            isPrimary ? Colors.white : Colors.black54,
            side: isPrimary
                ? null
                : const BorderSide(color: Colors.grey),
          ),
        ),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor:
          isPrimary ? const Color(0xFF2196F3) : Colors.white,
          foregroundColor: isPrimary ? Colors.white : Colors.black54,
          side: isPrimary ? null : const BorderSide(color: Colors.grey),
        ),
      );
    }
  }

  Widget _buildSortDropdown(bool isMobile) {
    return PopupMenuButton<String>(
      onSelected: (value) => controller.updateSort(value),
      itemBuilder: (BuildContext context) =>
          controller.sortOptions.map((String option) {
            return PopupMenuItem<String>(
              value: option,
              child: Text(option.toUpperCase()),
            );
          }).toList(),
      child: SizedBox(
        height: 40,
        child: ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.sort),
          label: Text(isMobile ? 'Sort' : 'Sort By...',
              style: TextStyle(fontSize: isMobile ? 12 : 14)),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 16,
              vertical: 8,
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black54,
            side: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  // Leads Table
  Widget _buildLeadsTable(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return  controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : PagewiseListView<LeadContactIdLeadContacts>(
        pageLoadController:
        controller.pagewiseLoadLeadIdController,
        showRetry: true,
        noItemsFoundBuilder: (context) => const Center(
          child: Text('No leads found'),
        ),
        // errorBuilder: (context, error) => Center(
        //   child: Text('Error: ${error.toString().substring(0, 50)}'),
        // ),
        loadingBuilder: (context) =>
        const Center(child: CircularProgressIndicator()),
        itemBuilder: (context, item, index) =>
        isMobile
            ? _buildLeadCardMobile(item)
            : _buildLeadRowDesktop(item),
      );
  }

  // Desktop Row View
  Widget _buildLeadRowDesktop(LeadContactIdLeadContacts lead) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Name with icon
              SizedBox(
                width: 180,
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lead.contact?.name ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Phone
              SizedBox(
                width: 130,
                child: Text(
                  lead.contact?.phone ?? 'N/A',
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              // Email
              SizedBox(
                width: 160,
                child: Text(
                  lead.contact?.email ?? 'N/A',
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              // Telecaller
              SizedBox(
                width: 100,
                child: Text(
                  lead.assignedTo?.name ?? 'N/A',
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              // Logs
              SizedBox(
                width: 60,
                child: Text(
                  '${lead.logs?.length ?? 0}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 12),
              // Duration
              SizedBox(
                width: 90,
                child: Text(
                  controller.formatDuration(
                      controller.getTotalDuration(lead.logs)),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 12),
              // Status
              _buildStatusBadge(lead.status ?? 'N/A'),
            ],
          ),
        ),
      ),
    );
  }

  // Mobile Card View
  Widget _buildLeadCardMobile(LeadContactIdLeadContacts lead) {
    return GestureDetector(
      onTap: () => _showLeadDetail(lead),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and Status
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
                const SizedBox(width: 8),
                _buildStatusBadge(lead.status ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 8),
            // Phone
            Row(
              children: [
                const Icon(Icons.phone, size: 14, color: Colors.grey),
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
            // Email
            Row(
              children: [
                const Icon(Icons.email, size: 14, color: Colors.grey),
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
            // Telecaller, Logs, Duration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Telecaller',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
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
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
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
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                      Text(
                        controller.formatDuration(
                            controller.getTotalDuration(lead.logs)),
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
      ),
    );
  }

  // Status Badge
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

  // Filter Dialog
  void _showFilterDialog() {
    Get.dialog(
      Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter by Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                    () => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.statusFilters.map((filter) {
                    final isSelected =
                        controller.selectedFilter.value == filter;
                    return FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        controller.updateFilter(filter);
                        Get.back();
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show Lead Detail
  void _showLeadDetail(LeadContactIdLeadContacts lead) {
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.all(12),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.9,
            maxWidth: Get.width * 0.9,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lead.contact?.name ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lead.contact?.phone ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contact Info
                      _buildDetailSection(
                        title: 'Contact Information',
                        items: [
                          ('Name', lead.contact?.name ?? 'N/A'),
                          ('Phone', lead.contact?.phone ?? 'N/A'),
                          ('Email', lead.contact?.email ?? 'N/A'),
                          ('City', lead.contact?.city ?? 'N/A'),
                          ('State', lead.contact?.state ?? 'N/A'),
                          ('Country', lead.contact?.country ?? 'N/A'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Assigned To
                      _buildDetailSection(
                        title: 'Assigned To',
                        items: [
                          ('Name', lead.assignedTo?.name ?? 'N/A'),
                          ('Phone', lead.assignedTo?.phone ?? 'N/A'),
                          ('Email', lead.assignedTo?.email ?? 'N/A'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Status
                      _buildDetailSection(
                        title: 'Status & Schedule',
                        items: [
                          ('Status', lead.status ?? 'N/A'),
                          ('Scheduled At', _formatDate(lead.scheduleAt)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Call Logs
                      if (lead.logs != null && lead.logs!.isNotEmpty)
                        _buildCallLogsSection(lead.logs!),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required List<(String, String)> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: List.generate(
              items.length,
                  (index) => Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          items[index].$1,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          items[index].$2,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (index < items.length - 1)
                    const Divider(height: 12),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCallLogsSection(List<LeadContactIdLeadContactsLogs> logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Call Logs',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              log.type ?? 'Call',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              controller
                                  .formatDuration(log.duration),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(log.date),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Export Data
  void _exportData() {
    Get.snackbar(
      'Export',
      'Exporting leads data...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Hex to Color
  Color _hexToColor(String hexColor) {
    final hexString = hexColor.replaceAll('#', '');
    final intValue = int.parse(hexString, radix: 16);
    return Color(intValue | 0xFF000000);
  }

  // Format Date
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return dateString;
    }
  }
}