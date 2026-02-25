import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/ui/views/auto_dialer/autodialer_controller.dart';

import '../../widgets/custom-appbar.dart';

class AutoDialerPage extends GetView<AutoDialerController> {
  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    bool isTablet = shortestSide > 600;

    return Scaffold(
      appBar: CustomAppBar(
        leading: SizedBox(),
        title: Text('Auto Dialer'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 32.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 16,
                vertical: isTablet ? 24 : 16
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4DB6AC), Color(0xFF26C6DA)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Rocket Icon
                      Container(
                        padding: EdgeInsets.all(isTablet ? 12.0 : 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.rocket_launch_outlined,
                          color: Colors.white,
                          size: isTablet ? 32 : 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Banner Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Auto Dialer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 32 : 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Stremline Your Calling Process With Power Dialing',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: isTablet ? 16 : 12,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isTablet ? 0 : 16),
                  
                  // Status Indicator
                  Align(
                    alignment: isTablet ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.only(left: isTablet ? 0 : 48), // Align with text when on mobile
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Obx(() => Text(
                            'Status: ${controller.status.value}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 14 : 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isTablet ? 24 : 16),
            
            // Cards Row
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column - Performance Statistics / Dialer Controls
                      Expanded(
                        flex: 5,
                        child: Obx(() => _buildPerformanceStatsCard(isTablet)),
                      ),
                      const SizedBox(width: 24),
                      // Right Column - Current Call & Lead Queue
                      Expanded(
                        flex: 6,
                        child: Column(
                          children: [
                            _buildCurrentCallCard(isTablet),
                            const SizedBox(height: 24),
                            _buildLeadQueueCard(isTablet),
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
                      _buildLeadQueueCard(isTablet),
                      const SizedBox(height: 16),
                     _buildDialerControlsCard(isTablet)
                    ],
                  );
                }
              }
            ),
            const SizedBox(height: 16), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceStatsCard(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Statistics',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),
          // Placeholder for the graph or list area
          Container(
            height: isTablet ? 200 : 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Graph Area',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),
          // Stats Row
          Row(
            children: [
              Expanded(child: _buildStatItem('Total Attempts', controller.totalAttempts, isTablet)),
              Expanded(child: _buildStatItem('Connected', controller.connected, isTablet, color: Colors.green)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatItem('Successful', controller.successful, isTablet, color: Colors.blue)),
              Expanded(child: _buildStatItem('Failed', controller.failed, isTablet, color: Colors.red)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, RxInt value, bool isTablet, {Color? color}) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isTablet ? 12 : 11,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Text(
          value.value.toString(),
          style: TextStyle(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: color ?? const Color(0xFF1E293B),
            fontFamily: 'Poppins',
          ),
        )),
      ],
    );
  }

  Widget _buildCurrentCallCard(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.bolt, color: Colors.black87, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Current Call',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.access_time, size: isTablet ? 18 : 16, color: Colors.black54),
                  const SizedBox(width: 4),
                  Obx(() => Text(
                    controller.callTimer.value,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  )),
                ],
              ),
            ],
          ),
          SizedBox(height: isTablet ? 24 : 16),
          // Warning box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9C3), // Light yellow
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE047)), // Yellow border
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: const Color(0xFFEAB308), size: isTablet ? 24 : 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'no_leads_available',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF854D0E),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Add Leads To Start',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: const Color(0xFFA16207),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadQueueCard(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.history, color: Colors.black87, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Lead Queue',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Obx(() => Text(
                        '${controller.leadsCount.value} Leads',
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      )),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              
              // Dropdown
              Container(
                width: isTablet ? 200 : 120, // Smaller on phone
                height: 36, // Smaller height on phone
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    hint: Text('select_lead', style: TextStyle(color: Colors.grey, fontSize: isTablet ? 14 : 12)),
                    icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: isTablet ? 24 : 20),
                    isExpanded: true,
                    style: TextStyle(fontSize: isTablet ? 14 : 12, color: Colors.black87),
                    items: controller.availableLeads.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        controller.selectedLead.value = newValue;
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildDialerControlsCard(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dialer Controls',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: isTablet ? 32 : 24),

          // User Profile Area
          Row(
            children: [
              Container(
                width: isTablet ? 64 : 48,
                height: isTablet ? 64 : 48,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, color: Colors.white, size: isTablet ? 40 : 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                      controller.selectedLead.value.isNotEmpty ? controller.selectedLead.value : 'Select a Lead',
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                        fontFamily: 'Poppins',
                      ),
                    )),
                    const SizedBox(height: 4),
                    Text(
                      '+91 7623097876',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: Colors.grey[600],
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Country: IN',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: Colors.grey[500],
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 32 : 24),

          // Ready To Dial info box
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD), // Light blue background
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.info_outline, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ready To Dial',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Click Start Auto Dialer',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),

          // Start Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => controller.startDialing(),
              icon: const Icon(Icons.play_circle_outline, color: Colors.white),
              label: const Text(
                'Start Auto Dialer',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50), // Green match
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Pause and Stop Buttons row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.pauseDialing(),
                  icon: const Icon(Icons.pause_circle_outline, color: Colors.black87, size: 20),
                  label: const Text(
                    'Pause',
                    style: TextStyle(color: Colors.black87, fontSize: 14, fontFamily: 'Poppins'),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8FAFC),
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.stopDialing(),
                  icon: const Icon(Icons.block, color: Colors.black54, size: 20),
                  label: const Text(
                    'Stop',
                    style: TextStyle(color: Colors.black54, fontSize: 14, fontFamily: 'Poppins'),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8FAFC),
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isTablet ? 48 : 32),

          // Dialer Settings
          Text(
            'Dialer Settings',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),

          // Auto Next Lead
          Row(
            children: [
              Text(
                'Auto Next Lead',
                style: TextStyle(
                  fontSize: isTablet ? 15 : 14,
                  color: const Color(0xFF1E293B),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(width: 16),
              // Simulated Switch
              Obx(() => GestureDetector(
                onTap: () => controller.autoNextLead.toggle(),
                child: Container(
                  width: 54,
                  height: 28,
                  decoration: BoxDecoration(
                    color: controller.autoNextLead.value ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: controller.autoNextLead.value ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
                    children: [
                      if (controller.autoNextLead.value)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text('ON', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      Container(
                        margin: const EdgeInsets.all(2),
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!controller.autoNextLead.value)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Text('OFF', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
              )),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 12),

          // Call Speed
          Row(
            children: [
              Text(
                'Call Speed: ',
                style: TextStyle(
                  fontSize: isTablet ? 15 : 14,
                  color: const Color(0xFF1E293B),
                  fontFamily: 'Poppins',
                ),
              ),
              Obx(() => Text(
                '${controller.callSpeed.value.toInt()} Seconds',
                style: TextStyle(
                  fontSize: isTablet ? 15 : 14,
                  color: Colors.blue,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }
}