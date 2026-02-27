import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:get/get.dart';
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
        title: const Text('Leads Contact', style: TextStyle(color: Colors.black)),
      ),
      body: Obx(
            () => controller.isLoading.value
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
            const CustomSearchBar(),
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
                  const SizedBox(width: 5),
                  CustomActionButton(
                    title: "Filter",
                    icon: Icons.filter,
                    onTap: () {},
                  ),
                  const SizedBox(width: 5),
                  CustomActionButton(
                    title: "Export",
                    icon: Icons.import_export,
                    onTap: () {},
                    isFullWidth: false,
                    isPrimary: true,
                  ),
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
      noItemsFoundBuilder: (context) =>
      const Center(child: Text('No leads found')),
      loadingBuilder: (context) =>
      const Center(child: CircularProgressIndicator()),
      itemBuilder: (context, item, index) =>
          _buildLeadCardMobile(item),
    );
  }

  Widget _buildLeadCardMobile(LeadContactIdLeadContacts lead) {
    return Container(
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
              SizedBox(
                width: 100,
                height: 33,
                child: CustomActionButton(
                  title: "Call Now",
                  icon: Icons.call,
                  isPrimary: true,
                  onTap: () {
                    // Uses the manual call flow which sets isAutoCallMode = false
                    controller.onManualCallTapped(lead);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Telecaller',
                        style:
                        TextStyle(fontSize: 10, color: Colors.blueGrey[600])),
                    Text(
                      lead.assignedTo?.name ?? 'N/A',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Logs',
                        style:
                        TextStyle(fontSize: 10, color: Colors.blueGrey[600])),
                    Text(
                      '${lead.logs?.length ?? 0}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Duration',
                        style:
                        TextStyle(fontSize: 10, color: Colors.grey[600])),
                    Text(
                      controller.formatDuration(
                          controller.getTotalDuration(lead.logs)),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500),
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
}