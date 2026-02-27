import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/core/models/all_lead_entity.dart';
import 'package:telecaller_app/core/models/lead_contact_id_entity.dart';
import 'package:telecaller_app/ui/views/auto_dialer/autodialer_controller.dart';
import '../../widgets/custom-appbar.dart';

class AutoDialerPage extends GetView<AutoDialerController> {
  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    bool isTablet = shortestSide > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100
      appBar: CustomAppBar(
        leading: SizedBox(),
        title: Text(
          'Auto Dialer Pro',
          style: TextStyle(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: Obx(
        () =>
            controller.isLoading.value && controller.leadsDatasets.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: EdgeInsets.all(isTablet ? 32.0 : 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 800) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                _buildPerformanceStatsCard(isTablet),
                                const SizedBox(height: 16),
                                _buildCurrentCallCard(isTablet),
                                const SizedBox(height: 16),
                                _buildDialerControlsCard(isTablet),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 7,
                            child: Column(
                              children: [
                                _buildLeadSelectionCard(isTablet),
                                const SizedBox(height: 16),
                                _buildContactListCard(isTablet),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildPerformanceStatsCard(isTablet),
                          const SizedBox(height: 16),
                          _buildCurrentCallCard(isTablet),
                          const SizedBox(height: 16),
                          _buildLeadSelectionCard(isTablet),
                          const SizedBox(height: 16),
                          _buildDialerControlsCard(isTablet),
                          const SizedBox(height: 16),
                          _buildContactListCard(isTablet),
                        ],
                      );
                    }
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
      ),
    );
  }

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
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Colors.indigo,
                  size: 20,
                ),
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
                  'Attempts',
                  controller.totalAttempts,
                  isTablet,
                  Colors.indigo,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey[200]),
              Expanded(
                child: _buildStatItem(
                  'Connected',
                  controller.connected,
                  isTablet,
                  Colors.green,
                ),
              ),
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
                  'Successful',
                  controller.successful,
                  isTablet,
                  Colors.blue,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey[200]),
              Expanded(
                child: _buildStatItem(
                  'Failed',
                  controller.failed,
                  isTablet,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentCallCard(bool isTablet) {
    return Obx(() {
      final lead = controller.currentContact.value;
      final isDialing = controller.status.value == 'dialing';

      return Container(
        padding: EdgeInsets.all(isTablet ? 24 : 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDialing 
                ? [const Color(0xFF6366F1), const Color(0xFF4F46E5)] // Indigo gradient
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
                    color: isDialing ? Colors.white.withOpacity(0.2) : const Color(0xFFF1F5F9),
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
                        controller.status.value == 'dialing' 
                            ? 'Currently Calling' 
                            : controller.status.value == 'paused'
                                ? 'Dialing Paused'
                                : controller.countdown.value > 0 
                                    ? 'Next Call In'
                                    : 'Next in Queue',
                        style: TextStyle(
                          color: isDialing ? Colors.white.withOpacity(0.8) : Colors.blue[500],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        lead?.contact?.name ?? 'No active lead',
                        style: TextStyle(
                          color: isDialing ? Colors.white : const Color(0xFF1E293B),
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
                  color: isDialing ? Colors.white.withOpacity(0.1) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDialing ? Colors.white.withOpacity(0.2) : const Color(0xFFE2E8F0),
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
                        color: isDialing ? Colors.white : const Color(0xFF475569),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    if (isDialing)
                      Text(
                        controller.callTimer.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
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

  Widget _buildStatItem(String label, RxInt value, bool isTablet, Color color) {
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

  Widget _buildLeadSelectionCard(bool isTablet) {
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
            'Select Lead Dataset',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<AllLeadLeads>(
                isExpanded: true,
                hint: const Text('Choose a dataset...'),
                value: controller.selectedLeadDataset.value,
                items:
                    controller.leadsDatasets.map((AllLeadLeads dataset) {
                      return DropdownMenuItem<AllLeadLeads>(
                        value: dataset,
                        child: Text(
                          dataset.name ?? 'Unnamed',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                onChanged: (val) => controller.onLeadDatasetChanged(val),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactListCard(bool isTablet) {
    return Container(
      width: double.infinity,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Contact Queue',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                  fontFamily: 'Poppins',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${controller.contactQueue.length} leads',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (controller.contactQueue.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.contact_phone_outlined,
                      size: 48,
                      color: Colors.blueGrey[300],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No contacts loaded',
                      style: TextStyle(
                        color: Colors.blueGrey[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  controller.contactQueue.length > 5
                      ? 5
                      : controller.contactQueue.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final lead = controller.contactQueue[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.indigo.withOpacity(0.1),
                        child: Text(
                          (lead.contact?.name ?? '?')[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.indigo,
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
                              ),
                            ),
                            Text(
                              lead.contact?.phone ?? 'No phone',
                              style: TextStyle(
                                color: Colors.blueGrey[500],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.call,
                          color: Colors.green,
                          size: 20,
                        ),
                        onPressed: () => controller.makeManualCall(lead),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.blueGrey,
                      ),
                    ],
                  ),
                );
              },
            ),
          if (controller.contactQueue.length > 5)
            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text('View All Contacts'),
              ),
            ),
        ],
      ),
    );
  }

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
          Obx(
            () => Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color:
                    controller.status.value == 'dialing'
                        ? Colors.blue.withOpacity(0.05)
                        : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      controller.status.value == 'dialing'
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
                      color:
                          controller.status.value == 'dialing'
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
                      color:
                          controller.status.value == 'dialing'
                              ? Colors.blue
                              : Colors.blueGrey[600],
                    ),
                  ),
                  const Spacer(),
                  if (controller.status.value == 'dialing')
                    Text(
                      controller.callTimer.value,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Obx(
              () => ElevatedButton.icon(
                onPressed:
                    controller.status.value == 'dialing'
                        ? null
                        : () => controller.startDialing(),
                icon: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                label: const Text(
                  'Start Auto Dialer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  disabledBackgroundColor: Colors.blueGrey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.stopDialing(),
                  icon: const Icon(
                    Icons.stop_rounded,
                    size: 20,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'Stop',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
