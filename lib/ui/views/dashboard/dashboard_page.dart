import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/constants/app_dimens.dart';
import 'package:telecaller_app/ui/widgets/dashboard_appbar.dart';

import '../home/home_controller.dart';

class DashboardPage extends GetView<HomeController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.dashboardController.refreshDashboard();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          DashboardAppBar(controller: controller),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppDimens.padding16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.dashboard_rounded,
                        color: AppColors.themeColor.primaryColor,
                        size: 22.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "dashboard_overview".tr,
                        style: AppTextStyle.bold8.copyWith(
                          fontSize: AppDimens.fontSize16,
                          color: AppColors.themeColor.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  // SizedBox(height:5.h),
                  _buildSummaryCards(context),
                  SizedBox(height: 24.h),
                  _buildLeadContactSection(context),
                  SizedBox(height: 24.h),
                  _buildCallsSection(context),
                  SizedBox(height: 24.h),
                  _buildBottomAnalyticsChart1(context),
                  SizedBox(height: 24.h),
                  _buildBottomAnalyticsChart2(context),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,

    required Color bgColor,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.themeColor.cardBgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: iconColor.withOpacity(0.15), width: 1.w),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.06),
            blurRadius: 15.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          children: [
            // Subtle Background Tint
            Positioned.fill(child: Container(color: bgColor.withOpacity(0.3))),
            Positioned(
              right: -10.w,
              bottom: -10.h,
              child: Icon(
                icon,
                size: 80.sp,
                color: iconColor.withOpacity(0.06),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 20.sp),
                  ),
                  const Spacer(),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: AppTextStyle.bold11.copyWith(
                        fontSize: 24.sp,
                        color: AppColors.themeColor.textPrimaryColor,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    title,
                    style: AppTextStyle.medium7.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.themeColor.textSecondaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;

        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            mainAxisExtent: 130.h,
          ),
          children: [
            Obx(
              () => _buildSummaryCard(
                title: "active_telecallers".tr,
                value:
                    "${controller.dashboardController.activeTelecallers.value}",
                subtitle: "handling_customer_calls".tr,
                bgColor: AppColors.themeColor.totalkeyColor,
                icon: Icons.support_agent_rounded,
                iconColor: AppColors.themeColor.totalkeyiconColor,
              ),
            ),
            Obx(
              () => _buildSummaryCard(
                title: "leads".tr,
                value: "${controller.dashboardController.leadsCount.value}",
                subtitle: "awaiting_contact".tr,
                bgColor: AppColors.themeColor.avilablekeyColor,
                icon: Icons.person_search_outlined,
                iconColor: AppColors.themeColor.availablekeyiconColor,
              ),
            ),
            Obx(
              () => _buildSummaryCard(
                title: "orders".tr,
                value: "${controller.dashboardController.ordersCount.value}",
                subtitle: "processed_purchases".tr,
                bgColor: AppColors.themeColor.activekeyColor,
                icon: Icons.shopping_bag_outlined,
                iconColor: AppColors.themeColor.activekeyiconColor,
              ),
            ),
            Obx(
              () => _buildSummaryCard(
                title: "forms_submitted".tr,
                value: "${controller.dashboardController.formsSubmitted.value}",
                subtitle: "customer_inquiries_received".tr,
                bgColor: AppColors.themeColor.expairekeyColor,
                icon: Icons.assignment_turned_in_outlined,
                iconColor: AppColors.themeColor.expairekeyiconColor,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricBox({
    required String title,
    required String todayVal,
    required String totalVal,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.themeColor.cardBgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.12), width: 1.w),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.04),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: constraints.maxWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            title,
                            style: AppTextStyle.bold8.copyWith(
                              fontSize: 9.sp,
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Icon(icon, size: 16.sp, color: color.withOpacity(0.5)),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              todayVal,
                              style: AppTextStyle.bold11.copyWith(
                                fontSize: 14.sp,
                                color: AppColors.themeColor.textPrimaryColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              "today".tr,
                              style: AppTextStyle.regular6.copyWith(
                                fontSize: 9.sp,
                                color: AppColors.themeColor.textSecondaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.themeColor.bordercolror.withOpacity(0),
                              AppColors.themeColor.bordercolror.withOpacity(
                                0.5,
                              ),
                              AppColors.themeColor.bordercolror.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              totalVal,
                              style: AppTextStyle.bold11.copyWith(
                                fontSize: 14.sp,
                                color: AppColors.themeColor.textPrimaryColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              "total".tr,
                              style: AppTextStyle.regular6.copyWith(
                                fontSize: 9.sp,
                                color: AppColors.themeColor.textSecondaryColor,
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
        },
      ),
    );
  }

  Widget _buildLeadContactSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.themeColor.cardBgColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.themeColor.bordercolror.withOpacity(0.5),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.themeColor.avilablekeyColor, // Light Blue header
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimens.radius12),
                topRight: Radius.circular(AppDimens.radius12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.contact_phone_rounded,
                  color: AppColors.themeColor.primaryColor,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  "lead_contact".tr,
                  style: AppTextStyle.bold8.copyWith(
                    fontSize: AppDimens.fontSize16,
                    color: AppColors.themeColor.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0.w),
            child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 500 ? 4 : 2;
                return GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    mainAxisExtent: 120.h,
                  ),
                  children: [
                    Obx(
                      () => _buildMetricBox(
                        title: "all".tr,
                        todayVal:
                            "${controller.dashboardController.leadContactAllToday.value}",
                        totalVal:
                            "${controller.dashboardController.leadContactAllTotal.value}",
                        color: AppColors.themeColor.primaryColor,
                        icon: Icons.contacts_rounded,
                      ),
                    ),
                    Obx(
                      () => _buildMetricBox(
                        title: "completed".tr,
                        todayVal:
                            "${controller.dashboardController.leadContactCompletedToday.value}",
                        totalVal:
                            "${controller.dashboardController.leadContactCompletedTotal.value}",
                        color: AppColors.themeColor.completedColor,
                        icon: Icons.task_alt_rounded,
                      ),
                    ),
                    Obx(
                      () => _buildMetricBox(
                        title: "scheduled".tr,
                        todayVal:
                            "${controller.dashboardController.leadContactScheduledToday.value}",
                        totalVal:
                            "${controller.dashboardController.leadContactScheduledTotal.value}",
                        color: AppColors.themeColor.availablekeyiconColor,
                        icon: Icons.event_available_rounded,
                      ),
                    ),
                    Obx(
                      () => _buildMetricBox(
                        title: "pending".tr,
                        todayVal:
                            "${controller.dashboardController.leadContactPendingToday.value}",
                        totalVal:
                            "${controller.dashboardController.leadContactPendingTotal.value}",
                        color: AppColors.themeColor.expairekeyiconColor,
                        icon: Icons.hourglass_top_rounded,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.themeColor.cardBgColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.themeColor.bordercolror.withOpacity(0.5),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.themeColor.callPendingColor, // Light Teal header
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimens.radius12),
                topRight: Radius.circular(AppDimens.radius12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.phone_in_talk_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  "calls".tr,
                  style: AppTextStyle.bold8.copyWith(
                    fontSize: AppDimens.fontSize16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0.w),
            child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 500 ? 4 : 2;
                return GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    mainAxisExtent: 120.h,
                  ),
                  children: [
                    Obx(
                      () => _buildMetricBox(
                        title: "incoming".tr,
                        todayVal:
                            "${controller.dashboardController.callsIncomingToday.value}",
                        totalVal:
                            "${controller.dashboardController.callsIncomingTotal.value}",
                        color: AppColors.themeColor.completedColor,
                        icon: Icons.call_received_rounded,
                      ),
                    ),
                    Obx(
                      () => _buildMetricBox(
                        title: "missed".tr,
                        todayVal:
                            "${controller.dashboardController.callsMissedToday.value}",
                        totalVal:
                            "${controller.dashboardController.callsMissedTotal.value}",
                        color: AppColors.themeColor.failColor,
                        icon: Icons.call_missed_rounded,
                      ),
                    ),
                    Obx(
                      () => _buildMetricBox(
                        title: "not_answered".tr,
                        todayVal:
                            "${controller.dashboardController.callsNotAnsweredToday.value}",
                        totalVal:
                            "${controller.dashboardController.callsNotAnsweredTotal.value}",
                        color: AppColors.themeColor.activekeyiconColor,
                        icon: Icons.call_missed_outgoing_rounded,
                      ),
                    ),
                    Obx(
                      () => _buildMetricBox(
                        title: "outgoing".tr,
                        todayVal:
                            "${controller.dashboardController.callsOutgoingToday.value}",
                        totalVal:
                            "${controller.dashboardController.callsOutgoingTotal.value}",
                        color: AppColors.themeColor.primaryColor,
                        icon: Icons.call_made_rounded,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAnalyticsChart1(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 800;
        return Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: isMobile ? 0 : 2,
              child: _buildBarChartWidget(context, isMobile),
            ),
            if (!isMobile) SizedBox(width: 16.w),
            if (isMobile) SizedBox(height: 16.h),
            Expanded(
              flex: isMobile ? 0 : 1,
              child: _buildPieChartWidget(context, isMobile),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomAnalyticsChart2(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 800;
        return Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: isMobile ? 0 : 2,
              child: _buildLeadBarChartWidget(context, isMobile),
            ),
            if (!isMobile) SizedBox(width: 16.w),
            if (isMobile) SizedBox(height: 16.h),
            Expanded(
              flex: isMobile ? 0 : 1,
              child: _buildLeadPieChartWidget(context, isMobile),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBarChartWidget(BuildContext context, bool isMobile) {
    return Container(
      height: 350.h,
      width: isMobile ? double.infinity : null,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.themeColor.cardBgColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.themeColor.bordercolror.withOpacity(0.5),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ================= HEADER =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "calls_over_time".tr,
                  style: AppTextStyle.bold8.copyWith(
                    fontSize: AppDimens.fontSize16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildTimeFilter(context),
            ],
          ),

          SizedBox(height: 12.h),

          /// ================= CHART AREA =================
          Expanded(
            child: Obx(() {
              if (controller.dashboardController.isChartLoading.value) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: Get.height * 0.08),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              final data = controller.dashboardController.barChartData;

              if (data.isEmpty) {
                return SizedBox(
                  height: 200,
                  child: Center(child: Text("no_chart_data_available".tr)),
                );
              }

              /// ===== Calculate maxY =====
              double maxY = 0;
              for (var spot in data) {
                if (spot.incoming.count > maxY) {
                  maxY = spot.incoming.count.toDouble();
                }
                if (spot.outgoing.count > maxY) {
                  maxY = spot.outgoing.count.toDouble();
                }
              }

              maxY += 10;
              double interval = (maxY / 5).ceilToDouble();

              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: data.length * 90, // little spacing
                    height: 280,
                    child: BarChart(
                      BarChartData(
                        maxY: maxY,
                        alignment: BarChartAlignment.spaceAround,

                        /// ===== GRID =====
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: interval,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: AppColors.themeColor.bordercolror,
                              strokeWidth: 1,
                              dashArray: [4, 4],
                            );
                          },
                        ),

                        borderData: FlBorderData(show: false),

                        /// ===== TITLES =====
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),

                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index < 0 || index >= data.length) {
                                  return const SizedBox();
                                }

                                String label = data[index].label;
                                String formattedLabel = label;

                                // Simple date formatting if it's a date string
                                try {
                                  if (label.contains('-') ||
                                      label.contains('/')) {
                                    DateTime dt = DateTime.parse(label);
                                    formattedLabel = DateFormat(
                                      'dd MMM',
                                    ).format(dt);
                                  }
                                } catch (_) {
                                  // Fallback to original label if parsing fails
                                }

                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  space: 8,
                                  child: Text(
                                    formattedLabel,
                                    style: AppTextStyle.bold6.copyWith(
                                      fontSize: AppDimens.fontSize10,
                                      color:
                                          AppColors
                                              .themeColor
                                              .textSecondaryColor,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40.w,
                              interval: interval,
                              getTitlesWidget: (value, meta) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(
                                    value.toInt().toString(),
                                    style: AppTextStyle.regular6.copyWith(
                                      fontSize: AppDimens.fontSize10,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        /// ===== BARS =====
                        barGroups:
                            data.asMap().entries.map((entry) {
                              int index = entry.key;
                              var spot = entry.value;

                              return BarChartGroupData(
                                x: index,
                                barsSpace: 10, // spacing between 2 bars
                                barRods: [
                                  BarChartRodData(
                                    toY: spot.incoming.count.toDouble(),
                                    color: AppColors.themeColor.completedColor,
                                    width: 14,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  BarChartRodData(
                                    toY: spot.outgoing.count.toDouble(),
                                    color: AppColors.themeColor.primaryColor,
                                    width: 14,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              );
                            }).toList(),

                        /// ===== TOUCH TOOLTIP =====
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: AppColors.themeColor.cardColor,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final dataItem = data[group.x.toInt()];

                              String title;

                              if (rodIndex == 0) {
                                title =
                                    "Incoming: ${dataItem.incoming.count}\nDuration: ${dataItem.incoming.totalDuration}";
                              } else {
                                title =
                                    "Outgoing: ${dataItem.outgoing.count}\nDuration: ${dataItem.outgoing.totalDuration}";
                              }

                              return BarTooltipItem(
                                title,
                                AppTextStyle.medium7.copyWith(
                                  color: AppColors.themeColor.textPrimaryColor,
                                  fontSize: AppDimens.fontSize12,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 10),

          /// ================= LEGEND =================
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              children: [
                _buildLegendItem(
                  AppColors.themeColor.completedColor,
                  "incoming".tr,
                ),
                _buildLegendItem(
                  AppColors.themeColor.primaryColor,
                  "outgoing".tr,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilter(BuildContext context) {
    return Row(
      children: [
        /// ===== Specific Date Range Button =====
        Obx(() {
          if (controller.dashboardController.selectedTimeFilter.value ==
              'Specific') {
            String dateText = "select_date_range".tr;

            if (controller.dashboardController.selectedDateRange.value !=
                null) {
              final start = DateFormat('yyyy-MM-dd').format(
                controller.dashboardController.selectedDateRange.value!.start,
              );
              final end = DateFormat('yyyy-MM-dd').format(
                controller.dashboardController.selectedDateRange.value!.end,
              );
              dateText = "$start → $end";
            }

            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: InkWell(
                onTap: () async {
                  DateTimeRange? range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    initialDateRange:
                        controller.dashboardController.selectedDateRange.value,
                  );

                  if (range != null) {
                    controller.dashboardController.updateDateRange(range);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.themeColor.primaryColor.withOpacity(0.05),
                    border: Border.all(
                      color: AppColors.themeColor.primaryColor.withOpacity(0.5),
                      width: 1.w,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Text(
                        dateText,
                        style: AppTextStyle.medium7.copyWith(
                          fontSize: AppDimens.fontSize12,
                          color: AppColors.themeColor.primaryColor,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14.sp,
                        color: AppColors.themeColor.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const SizedBox();
        }),

        /// ===== Dropdown =====
        Container(
          height: 36.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColors.themeColor.cardBgColor,
            border: Border.all(
              color: AppColors.themeColor.bordercolror.withOpacity(0.5),
              width: 1.w,
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Obx(
            () => DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.dashboardController.selectedTimeFilter.value,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18.sp,
                  color: AppColors.themeColor.primaryColor,
                ),
                style: AppTextStyle.medium7.copyWith(
                  fontSize: AppDimens.fontSize12,
                  color: AppColors.themeColor.textPrimaryColor,
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.dashboardController.updateTimeFilter(newValue);

                    if (newValue == 'Specific' &&
                        controller
                                .dashboardController
                                .selectedDateRange
                                .value ==
                            null) {
                      showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      ).then((range) {
                        if (range != null) {
                          controller.dashboardController.updateDateRange(range);
                        } else {
                          controller.dashboardController.updateTimeFilter(
                            'Today',
                          );
                        }
                      });
                    }
                  }
                },
                items:
                    ['Today', 'Week', 'Month', 'Year', 'Specific']
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value.toLowerCase().tr),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPieChartWidget(BuildContext context, bool isMobile) {
    return Container(
      height: 350.h,
      width: isMobile ? double.infinity : null,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.themeColor.cardBgColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.themeColor.bordercolror.withOpacity(0.5),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "call_status_distribution".tr,
            style: AppTextStyle.bold8.copyWith(fontSize: AppDimens.fontSize16),
          ),
          const Expanded(child: SizedBox()),
          Center(
            child: SizedBox(
              height: 180,
              child: Obx(() {
                if (controller.dashboardController.isChartLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                int incoming =
                    controller.dashboardController.incomingPieCount.value;
                int missed =
                    controller.dashboardController.missedPieCount.value;
                int notAnswered =
                    controller.dashboardController.notAnsweredPieCount.value;
                int outgoing =
                    controller.dashboardController.outgoingPieCount.value;

                if (incoming == 0 &&
                    missed == 0 &&
                    notAnswered == 0 &&
                    outgoing == 0) {
                  return Center(child: Text("no_chart_data_available".tr));
                }

                // ── Build valid data list ──────────────────────────────────
                List<Map<String, dynamic>> validData = [];
                if (incoming > 0) {
                  validData.add({
                    "value": incoming,
                    "color": AppColors.themeColor.completedColor,
                  });
                }
                if (missed > 0) {
                  validData.add({
                    "value": missed,
                    "color": AppColors.themeColor.activekeyiconColor,
                  });
                }
                if (notAnswered > 0) {
                  validData.add({
                    "value": notAnswered,
                    "color": AppColors.themeColor.failColor,
                  });
                }
                if (outgoing > 0) {
                  validData.add({
                    "value": outgoing,
                    "color": AppColors.themeColor.primaryColor,
                  });
                }

                // ── FIX: enforce minimum 2.5% so tiny slices stay visible ─
                // Without this, "not_answered_12".tr out of 3235 total = 0.37%
                // which renders as an invisible sliver on the pie chart.
                const double minPercent = 2.5;
                final double rawTotal = validData.fold(
                  0.0,
                  (sum, e) => sum + (e["value"] as int).toDouble(),
                );

                List<double> adjustedValues =
                    validData.map((e) {
                      double pct = (e["value"] as int) / rawTotal * 100;
                      return pct.clamp(minPercent, 100.0);
                    }).toList();

                // Re-normalise so adjusted values still sum to rawTotal
                final double adjSum = adjustedValues.fold(0.0, (s, v) => s + v);
                adjustedValues =
                    adjustedValues.map((v) => v / adjSum * rawTotal).toList();
                // ─────────────────────────────────────────────────────────

                List<PieChartSectionData> pieChartSections = [];

                for (int i = 0; i < validData.length; i++) {
                  bool isTouched =
                      controller.dashboardController.touchedPieIndex.value == i;
                  pieChartSections.add(
                    PieChartSectionData(
                      color: validData[i]["color"],
                      value: adjustedValues[i],
                      // ← adjusted value (visual only)
                      title:
                          isTouched
                              ? (validData[i]["value"] as int)
                                  .toString() // ← show real value on touch
                              : '',
                      radius: isTouched ? 100 : 90,
                      titleStyle: AppTextStyle.bold11.copyWith(
                        fontSize: AppDimens.fontSize16,
                        color: AppColors.themeColor.cardColor,
                      ),
                    ),
                  );
                }

                return PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          controller.dashboardController.touchedPieIndex.value =
                              -1;
                          return;
                        }
                        controller.dashboardController.touchedPieIndex.value =
                            pieTouchResponse
                                .touchedSection!
                                .touchedSectionIndex;
                      },
                    ),
                    sectionsSpace: 1,
                    centerSpaceRadius: 0,
                    startDegreeOffset: -90,
                    sections: pieChartSections,
                  ),
                );
              }),
            ),
          ),
          const Expanded(child: SizedBox()),
          // Legend
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12.w,
            runSpacing: 8.h,
            children: [
              _buildLegendItem(
                AppColors.themeColor.completedColor,
                "incoming".tr,
              ),
              _buildLegendItem(
                AppColors.themeColor.activekeyiconColor,
                "missed".tr,
              ),
              _buildLegendItem(
                AppColors.themeColor.failColor,
                "not_answered".tr,
              ),
              _buildLegendItem(
                AppColors.themeColor.primaryColor,
                "outgoing".tr,
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///lead chart

  Widget _buildLeadBarChartWidget(BuildContext context, bool isMobile) {
    return Container(
      height: 350,
      width: isMobile ? double.infinity : null,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.themeColor.cardBgColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.themeColor.bordercolror.withOpacity(0.5),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              Expanded(
                child: Text(
                  "leads_over_time".tr,
                  style: AppTextStyle.bold8.copyWith(
                    fontSize: AppDimens.fontSize16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildLeadTimeFilter(context),
            ],
          ),
          SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              if (controller.dashboardController.isLeadChartLoading.value) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: Get.height * 0.08),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              final data = controller.dashboardController.leadBarChartData;

              if (data.isEmpty) {
                return SizedBox(
                  height: 200,
                  child: Center(child: Text("no_chart_data_available".tr)),
                );
              }

              double maxY = 0;
              for (var spot in data) {
                if (spot.count > maxY) {
                  maxY = spot.count.toDouble();
                }
              }

              maxY += 10;
              double interval = (maxY / 5).ceilToDouble();
              if (interval == 0) interval = 1;

              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: data.length * 90,
                    height: 280,
                    child: BarChart(
                      BarChartData(
                        maxY: maxY,
                        alignment: BarChartAlignment.spaceAround,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: interval,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: AppColors.themeColor.bordercolror,
                              strokeWidth: 1,
                              dashArray: [4, 4],
                            );
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index < 0 || index >= data.length) {
                                  return const SizedBox();
                                }

                                String label = data[index].label;
                                String formattedLabel = label;

                                // Simple date formatting if it's a date string
                                try {
                                  if (label.contains('-') ||
                                      label.contains('/')) {
                                    DateTime dt = DateTime.parse(label);
                                    formattedLabel = DateFormat(
                                      'dd MMM',
                                    ).format(dt);
                                  }
                                } catch (_) {
                                  // Fallback to original label if parsing fails
                                }

                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  space: 8,
                                  child: Text(
                                    formattedLabel,
                                    style: AppTextStyle.bold6.copyWith(
                                      fontSize: AppDimens.fontSize10,
                                      color:
                                          AppColors
                                              .themeColor
                                              .textSecondaryColor,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: interval,
                              getTitlesWidget: (value, meta) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(
                                    value.toInt().toString(),
                                    style: AppTextStyle.regular6.copyWith(
                                      fontSize: AppDimens.fontSize10,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups:
                            data.asMap().entries.map((entry) {
                              int index = entry.key;
                              var spot = entry.value;

                              return BarChartGroupData(
                                x: index,
                                barsSpace: 10,
                                barRods: [
                                  BarChartRodData(
                                    toY: spot.count.toDouble(),
                                    color: AppColors.themeColor.primaryColor,
                                    width: 14,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              );
                            }).toList(),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: AppColors.themeColor.cardColor,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final dataItem = data[group.x.toInt()];
                              return BarTooltipItem(
                                "Leads: ${dataItem.count}",
                                AppTextStyle.medium7.copyWith(
                                  color: AppColors.themeColor.textPrimaryColor,
                                  fontSize: AppDimens.fontSize12,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              children: [
                _buildLegendItem(
                  AppColors.themeColor.primaryColor,
                  "total_leads".tr,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadTimeFilter(BuildContext context) {
    return Row(
      children: [
        Obx(() {
          if (controller.dashboardController.selectedLeadTimeFilter.value ==
              'Specific') {
            String dateText = "select_date_range".tr;
            if (controller.dashboardController.selectedLeadDateRange.value !=
                null) {
              final start = DateFormat('yyyy-MM-dd').format(
                controller
                    .dashboardController
                    .selectedLeadDateRange
                    .value!
                    .start,
              );
              final end = DateFormat('yyyy-MM-dd').format(
                controller.dashboardController.selectedLeadDateRange.value!.end,
              );
              dateText = "$start → $end";
            }
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: InkWell(
                onTap: () async {
                  DateTimeRange? range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    initialDateRange:
                        controller
                            .dashboardController
                            .selectedLeadDateRange
                            .value,
                  );
                  if (range != null) {
                    controller.dashboardController.updateLeadDateRange(range);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.themeColor.primaryColor.withOpacity(0.05),
                    border: Border.all(
                      color: AppColors.themeColor.primaryColor.withOpacity(0.5),
                      width: 1.w,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Text(
                        dateText,
                        style: AppTextStyle.medium7.copyWith(
                          fontSize: AppDimens.fontSize12,
                          color: AppColors.themeColor.primaryColor,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14.sp,
                        color: AppColors.themeColor.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const SizedBox();
        }),
        Container(
          height: 36.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColors.themeColor.cardBgColor,
            border: Border.all(
              color: AppColors.themeColor.bordercolror.withOpacity(0.5),
              width: 1.w,
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Obx(
            () => DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value:
                    controller.dashboardController.selectedLeadTimeFilter.value,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18.sp,
                  color: AppColors.themeColor.primaryColor,
                ),
                style: AppTextStyle.medium7.copyWith(
                  fontSize: AppDimens.fontSize12,
                  color: AppColors.themeColor.textPrimaryColor,
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.dashboardController.updateLeadTimeFilter(
                      newValue,
                    );
                    if (newValue == 'Specific' &&
                        controller
                                .dashboardController
                                .selectedLeadDateRange
                                .value ==
                            null) {
                      showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      ).then((range) {
                        if (range != null) {
                          controller.dashboardController.updateLeadDateRange(
                            range,
                          );
                        } else {
                          controller.dashboardController.updateLeadTimeFilter(
                            'Today',
                          );
                        }
                      });
                    }
                  }
                },
                items:
                    ['Today', 'Week', 'Month', 'Year', 'Specific']
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value.toLowerCase().tr),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeadPieChartWidget(BuildContext context, bool isMobile) {
    return Container(
      height: 350,
      width: isMobile ? double.infinity : null,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.themeColor.cardBgColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.themeColor.bordercolror.withOpacity(0.5),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "lead_status_distribution".tr,
            style: AppTextStyle.bold8.copyWith(fontSize: AppDimens.fontSize16),
          ),
          const Expanded(child: SizedBox()),
          Center(
            child: SizedBox(
              height: 180,
              child: Obx(() {
                if (controller.dashboardController.isLeadChartLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                int completed =
                    controller.dashboardController.leadCompletedPieCount.value;
                int scheduled =
                    controller.dashboardController.leadScheduledPieCount.value;
                int pending =
                    controller.dashboardController.leadPendingPieCount.value;

                if (completed == 0 && scheduled == 0 && pending == 0) {
                  return Center(child: Text("no_chart_data_available".tr));
                }

                List<Map<String, dynamic>> validData = [];

                if (completed > 0) {
                  validData.add({
                    "value": completed,
                    "color": AppColors.themeColor.completedColor,
                  });
                }
                if (scheduled > 0) {
                  validData.add({
                    "value": scheduled,
                    "color": AppColors.themeColor.activekeyiconColor,
                  });
                }
                if (pending > 0) {
                  validData.add({
                    "value": pending,
                    "color": AppColors.themeColor.failColor,
                  });
                }

                // ── FIX: enforce minimum 2.5% so tiny slices stay visible ─
                const double minPercent = 2.5;
                final double rawTotal = validData.fold(
                  0.0,
                  (sum, e) => sum + (e["value"] as int).toDouble(),
                );

                List<double> adjustedValues =
                    validData.map((e) {
                      double pct = (e["value"] as int) / rawTotal * 100;
                      return pct.clamp(minPercent, 100.0);
                    }).toList();

                final double adjSum = adjustedValues.fold(0.0, (s, v) => s + v);
                adjustedValues =
                    adjustedValues.map((v) => v / adjSum * rawTotal).toList();
                // ─────────────────────────────────────────────────────────

                List<PieChartSectionData> pieChartSections = [];

                for (int i = 0; i < validData.length; i++) {
                  bool isTouched =
                      controller
                          .dashboardController
                          .touchedLeadPieIndex
                          .value ==
                      i;
                  pieChartSections.add(
                    PieChartSectionData(
                      color: validData[i]["color"],
                      value: adjustedValues[i],
                      title: isTouched ? validData[i]["value"].toString() : '',
                      radius: isTouched ? 100 : 90,
                      titleStyle: AppTextStyle.bold11.copyWith(
                        fontSize: AppDimens.fontSize16,
                        color: Colors.white,
                      ),
                    ),
                  );
                }

                return PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          controller
                              .dashboardController
                              .touchedLeadPieIndex
                              .value = -1;
                          return;
                        }
                        controller
                            .dashboardController
                            .touchedLeadPieIndex
                            .value = pieTouchResponse
                                .touchedSection!
                                .touchedSectionIndex;
                      },
                    ),
                    sectionsSpace: 1,
                    centerSpaceRadius: 0,
                    startDegreeOffset: -90,
                    sections: pieChartSections,
                  ),
                );
              }),
            ),
          ),
          const Expanded(child: SizedBox()),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12.w,
            runSpacing: 8.h,
            children: [
              _buildLegendItem(
                AppColors.themeColor.completedColor,
                "completed".tr,
              ),
              _buildLegendItem(
                AppColors.themeColor.activekeyiconColor,
                "scheduled".tr,
              ),
              _buildLegendItem(
                AppColors.themeColor.failColor,
                "pending".tr,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: AppTextStyle.medium7.copyWith(
            color: color,
            fontSize: AppDimens.fontSize12,
          ),
        ),
      ],
    );
  }
}
