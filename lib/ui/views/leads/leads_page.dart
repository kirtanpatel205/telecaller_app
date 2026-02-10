import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/core/models/all_lead_entity.dart';
import 'package:telecaller_app/ui/views/leads/leads_controller.dart';

class LeadsPage extends GetView<LeadsController> {
  const LeadsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width < 1000;
    LeadsController controller = Get.put(LeadsController());

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom SliverAppBar with search and filters
            _buildSliverAppBar(context, isMobile),

            // Main content
            SliverFillRemaining(
              child: Obx(() {
                if (controller.isLoading.value && controller.allLeads.isEmpty) {
                  return _buildLoadingState();
                }
                return _buildLeadsListView(context, isMobile, isTablet);
              }),
            ),
          ],
        ),
      ),
    );
  }

  // SliverAppBar with search and action buttons
  Widget _buildSliverAppBar(BuildContext context, bool isMobile) {
    return SliverAppBar(
      expandedHeight: isMobile ? 140 : 120,
      floating: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Leads',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
        titlePadding: EdgeInsets.only(left: 16, bottom: isMobile ? 60 : 50),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(isMobile ? 65 : 55),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: _buildSearchAndFilterBar(context, isMobile),
        ),
      ),
    );
  }

  // Search bar with filters
  Widget _buildSearchAndFilterBar(BuildContext context, bool isMobile) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search Leads',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 16,
                      vertical: isMobile ? 10 : 12,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[600],
                      size: isMobile ? 20 : 24,
                    ),
                  ),
                  style: TextStyle(fontSize: isMobile ? 13 : 14),
                  onChanged: (value) {
                    // Implement search logic
                  },
                ),
              ),
            ),
            if (isMobile) SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: () {
                  // Implement search action
                },
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                  size: isMobile ? 20 : 24,
                ),
                constraints: BoxConstraints.tightFor(
                  width: isMobile ? 44 : 48,
                  height: isMobile ? 44 : 48,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 8 : 10),
        Row(
          children: [
            Expanded(
              child: SizedBox.shrink(),
            ),
            OutlinedButton.icon(
              onPressed: () {
                // Reset filters
              },
              icon: Icon(Icons.refresh, size: isMobile ? 16 : 18),
              label: Text(
                'reset',
                style: TextStyle(fontSize: isMobile ? 12 : 13),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey[400]!),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 12,
                  vertical: isMobile ? 6 : 8,
                ),
              ),
            ),
            SizedBox(width: isMobile ? 6 : 8),
            OutlinedButton.icon(
              onPressed: () {
                // Show filter dialog
              },
              icon: Icon(Icons.tune, size: isMobile ? 16 : 18),
              label: Text(
                'filter',
                style: TextStyle(fontSize: isMobile ? 12 : 13),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey[400]!),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 12,
                  vertical: isMobile ? 6 : 8,
                ),
              ),
            ),
            SizedBox(width: isMobile ? 6 : 8),
            ElevatedButton.icon(
              onPressed: () {
                // Auto dial next lead
              },
              icon: Icon(Icons.phone, size: isMobile ? 16 : 18),
              label: Text(
                'Auto Dial Next',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 12,
                  vertical: isMobile ? 6 : 8,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Pagewise list view
  Widget _buildLeadsListView(BuildContext context, bool isMobile, bool isTablet) {
    controller.initPagewise();

    return PagewiseListView<AllLeadLeads>(
      pageLoadController: controller.pagewiseAllLeadLoadController,
      showRetry: false, // ✅ ADD THIS

      noItemsFoundBuilder: (_) => _buildEmptyState(context),
      errorBuilder: (_, error) => _buildErrorState(context, error),
      loadingBuilder: (_) => _buildLoadingIndicator(context),
      itemBuilder: (context, item, index) {
        return _buildLeadCard(context, item, isMobile, isTablet);
      },
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 8 : 12,
      ),
      // separator: SizedBox(height: isMobile ? 8 : 10),
    );
  }

  // Lead card with all information
  Widget _buildLeadCard(
      BuildContext context,
      AllLeadLeads lead,
      bool isMobile,
      bool isTablet,
      ) {
    final cardPadding = isMobile ? 12.0 : 16.0;
    final fontSize = isMobile ? 13.0 : 14.0;
    final titleFontSize = isMobile ? 14.0 : 15.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: SN, Lead Name, Status, and Telecallers icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SN
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${lead.id?.substring(0, 1).toUpperCase() ?? '1'}',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                SizedBox(width: cardPadding),
                // Lead Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lead.name ?? 'Unknown Lead',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.blue[300]!),
                        ),
                        child: Text(
                          lead.status ?? 'Pending',
                          style: TextStyle(
                            fontSize: fontSize - 1,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                // Telecallers indicator
                _buildTelecallersIndicator(context, lead, isMobile),
              ],
            ),
            SizedBox(height: cardPadding),

            // Row 2: Form attached
            if (lead.formId != null)
              Padding(
                padding: EdgeInsets.only(bottom: cardPadding),
                child: Row(
                  children: [
                    Icon(Icons.description_outlined,
                      size: isMobile ? 16 : 18,
                      color: Colors.blue[600],
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lead.formId?.title ?? 'Form Attached',
                        style: TextStyle(
                          fontSize: fontSize,
                          color: Colors.blue[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(Icons.visibility_outlined,
                      size: isMobile ? 16 : 18,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),

            // Row 3: Schedule Information (Dates)
            if (lead.schedule != null)
              Padding(
                padding: EdgeInsets.only(bottom: cardPadding),
                child: _buildDateRow(
                  context,
                  'Starting Date',
                  lead.schedule?.startDate,
                  fontSize,
                  isMobile,
                ),
              ),

            if (lead.schedule != null)
              Padding(
                padding: EdgeInsets.only(bottom: cardPadding),
                child: _buildDateRow(
                  context,
                  'End Date',
                  lead.schedule?.endDate,
                  fontSize,
                  isMobile,
                ),
              ),

            if (lead.createdAt != null)
              Padding(
                padding: EdgeInsets.only(bottom: cardPadding),
                child: _buildDateRow(
                  context,
                  'Created At',
                  lead.createdAt,
                  fontSize,
                  isMobile,
                ),
              ),

            // Row 4: Call Action Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle call action
                  _handleCallLead(context, lead);
                },
                icon: Icon(Icons.phone, size: isMobile ? 16 : 18),
                label: Text(
                  'Call',
                  style: TextStyle(fontSize: isMobile ? 12 : 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: isMobile ? 6 : 8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Telecallers indicator with avatars
  Widget _buildTelecallersIndicator(
      BuildContext context,
      AllLeadLeads lead,
      bool isMobile,
      ) {
    final allots = lead.allot ?? [];
    final displayCount = isMobile ? 1 : 2;
    final visibleAllots = allots.take(displayCount);
    final remainingCount = allots.length - displayCount;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...visibleAllots.map((allot) {
            return _buildUserAvatar(allot.userId, isMobile);
          }),
          if (remainingCount > 0)
            Container(
              width: isMobile ? 24 : 28,
              height: isMobile ? 24 : 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
              child: Center(
                child: Text(
                  '+${remainingCount}',
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // User avatar
  Widget _buildUserAvatar(AllLeadLeadsAllotUserId? userId, bool isMobile) {
    final initial = userId?.name?.isNotEmpty == true
        ? userId!.name!.substring(0, 1).toUpperCase()
        : '?';

    return Container(
      width: isMobile ? 24 : 28,
      height: isMobile ? 24 : 28,
      margin: EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.green[400],
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 10 : 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Date row helper
  Widget _buildDateRow(
      BuildContext context,
      String label,
      String? date,
      double fontSize,
      bool isMobile,
      ) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            _formatDate(date),
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Date formatter
  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(date);
      return '${dateTime.day.toString().padLeft(2, '0')} ${_monthName(dateTime.month)} ${dateTime.year}, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return date;
    }
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  // Empty state
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No Leads Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // Error state
  Widget _buildErrorState(BuildContext context, dynamic error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              controller.initPagewise();
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Loading state
  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.blue[600]),
      ),
    );
  }

  // Loading indicator for pagination
  Widget _buildLoadingIndicator(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.blue[600]),
        ),
      ),
    );
  }

  // Handle call action
  void _handleCallLead(BuildContext context, AllLeadLeads lead) {
    // Implement actual call logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${lead.name}...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}