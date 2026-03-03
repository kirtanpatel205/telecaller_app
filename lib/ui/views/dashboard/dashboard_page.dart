import 'package:bounce/bounce.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_routes.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/ui/views/home/overlay/overlay_pages.dart';

import '../home/home_controller.dart';

class DashboardPage extends GetView<HomeController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,

        // 👉 PROFILE IMAGE
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Bounce(
            onTap: () {
              Get.toNamed(Routes.EDITPROFILE);
            },
            child: Obx(() => Container(
              height: 40,
              width: 40,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: controller.authController.profile.value?.profile
                  ?.isNotEmpty ==
                  true
                  ? Image.network(
                "https://api-test.digibulkmarketing.com${controller.authController.profile.value!.profile!}",
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.error),
              )
                  : Center(
                child: Text(
                  controller.authController.profile.value?.name
                      ?.isNotEmpty ==
                      true
                      ? controller
                      .authController.profile.value!.name![0]
                      : "N",
                  style: AppTextStyle.regular12.copyWith(
                    fontSize: 20,
                    color:
                    AppColors.themeColor.primaryColor,
                  ),
                ),
              ),
            )),
          ),
        ),

        // 👉 NAME + SUBTITLE
        title: Obx(() => InkWell(
          onTap: () {
            Get.toNamed(Routes.EDITPROFILE);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.authController.profile.value?.name ??
                    "No Name",
                style: AppTextStyle.semiBold8.copyWith(
                  fontSize: 12,
                  color:
                  AppColors.themeColor.textPrimaryColor,
                ),
              ),
              Text(
                'How Are You Today',
                style: AppTextStyle.regular6.copyWith(
                  color:
                  AppColors.themeColor.textPrimaryColor,
                ),
              ),
            ],
          ),
        )),

        // 👉 NOTIFICATION ICON
        actions: [
          Bounce(
            onTap: () async{
              await Get.dialog(
                OverlayPages(),
                barrierDismissible: false,
              );
               // Get.to(NotifictionPage());
            },
            child: GFAvatar(
              radius: 18,
              backgroundColor:
              AppColors.themeColor.primaryColor,
              child: const Icon(
                Icons.notifications_none_outlined,
                color: Colors.white,
              ),
            ).paddingAll(10),
          ),
        ],
      ),

      // 👉 PAGE BODY
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Dashboard Overview",
                style: AppTextStyle.semiBold8.copyWith(
                  fontSize: 20,
                  color: AppColors.themeColor.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 16),
              _buildSummaryCards(context),
              const SizedBox(height: 24),
              _buildLeadContactSection(context),
              const SizedBox(height: 24),
              _buildCallsSection(context),
              const SizedBox(height: 24),
              _buildBottomAnalyticsChart1(context),
              const SizedBox(height: 24),
              _buildBottomAnalyticsChart2(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTextStyle.semiBold8.copyWith(
                    fontSize: 14,
                    color: AppColors.themeColor.textPrimaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: AppTextStyle.semiBold8.copyWith(
                    fontSize: 28,
                    color: AppColors.themeColor.textPrimaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyle.regular6.copyWith(
                    fontSize: 12,
                    color: AppColors.themeColor.textPrimaryColor.withAlpha(178),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Icon(icon, color: iconColor, size: 24),
          ),
        ],
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
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 130,
          ),
          children: [
            Obx(() => _buildSummaryCard(
              title: "Active Telecallers",
              value: "${controller.dashboardController.activeTelecallers.value}",
              subtitle: "Handling customer calls",
              bgColor: AppColors.themeColor.activekeyColor, // Light Blue
              icon: Icons.notifications_active_outlined,
              iconColor: AppColors.themeColor.primaryColor.withAlpha(200),
            )),
            Obx(() => _buildSummaryCard(
              title: "Leads",
              value: "${controller.dashboardController.leadsCount.value}",
              subtitle: "Awaiting contact",
              bgColor: AppColors.themeColor.avilablekeyColor, // Light Grey
              icon: Icons.person_add_outlined,
            iconColor: AppColors.themeColor.primaryColor.withAlpha(200),
            )),
            Obx(() => _buildSummaryCard(
              title: "Orders",
              value: "${controller.dashboardController.ordersCount.value}",
              subtitle: "Processed purchases",
              bgColor: AppColors.themeColor.completedBgColor, // Light Green
              icon: Icons.headset_mic_outlined,
              iconColor: AppColors.themeColor.primaryColor.withAlpha(200),
            )),
            Obx(() => _buildSummaryCard(
              title: "Forms Submitted",
              value: "${controller.dashboardController.formsSubmitted.value}",
              subtitle: "Customer inquiries received",
              bgColor: AppColors.themeColor.expairekeyColor, // Light Yellow
              icon: Icons.edit_document,
              iconColor: AppColors.themeColor.primaryColor.withAlpha(200),
            )),
          ],
        );
      },
    );
  }

  Widget _buildMetricBox(String title, String todayVal, String totalVal) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              title,
              style: AppTextStyle.semiBold8.copyWith(
                fontSize: 12,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      todayVal,
                      style: AppTextStyle.semiBold8.copyWith(fontSize: 20),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Today",
                      style: AppTextStyle.regular6.copyWith(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 5,),
              Container(width: 1, height: 40, color: Colors.grey.shade400),
              SizedBox(width: 5,),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      totalVal,
                      style: AppTextStyle.semiBold8.copyWith(fontSize: 20),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Total",
                      style: AppTextStyle.regular6.copyWith(fontSize: 12, color: Colors.grey),
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

  Widget _buildLeadContactSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.themeColor.avilablekeyColor, // Light Blue header
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              "Lead Contact",
              style: AppTextStyle.semiBold8.copyWith(
                fontSize: 16,
                color: const Color(0xFF1890FF),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 500 ? 4 : 2;
                return GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 120,
                  ),
                  children: [
                    Obx(() => _buildMetricBox(
                      "All",
                      "${controller.dashboardController.leadContactAllToday.value}",
                      "${controller.dashboardController.leadContactAllTotal.value}",
                    )),
                    Obx(() => _buildMetricBox(
                      "Completed",
                      "${controller.dashboardController.leadContactCompletedToday.value}",
                      "${controller.dashboardController.leadContactCompletedTotal.value}",
                    )),
                    Obx(() => _buildMetricBox(
                      "Scheduled",
                      "${controller.dashboardController.leadContactScheduledToday.value}",
                      "${controller.dashboardController.leadContactScheduledTotal.value}",
                    )),
                    Obx(() => _buildMetricBox(
                      "Pending",
                      "${controller.dashboardController.leadContactPendingToday.value}",
                      "${controller.dashboardController.leadContactPendingTotal.value}",
                    )),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.themeColor.callPendingColor, // Light Teal header
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              "Calls",
              style: AppTextStyle.semiBold8.copyWith(
                fontSize: 16,
                color: AppColors.themeColor.activekeyColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 500 ? 4 : 2;
                return GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 120,
                  ),
                  children: [
                    Obx(() => _buildMetricBox(
                      "Incoming",
                      "${controller.dashboardController.callsIncomingToday.value}",
                      "${controller.dashboardController.callsIncomingTotal.value}",
                    )),
                    Obx(() => _buildMetricBox(
                      "Missed",
                      "${controller.dashboardController.callsMissedToday.value}",
                      "${controller.dashboardController.callsMissedTotal.value}",
                    )),
                    Obx(() => _buildMetricBox(
                      "Not Answered",
                      "${controller.dashboardController.callsNotAnsweredToday.value}",
                      "${controller.dashboardController.callsNotAnsweredTotal.value}",
                    )),
                    Obx(() => _buildMetricBox(
                      "Outgoing",
                      "${controller.dashboardController.callsOutgoingToday.value}",
                      "${controller.dashboardController.callsOutgoingTotal.value}",
                    )),
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
            if (!isMobile) const SizedBox(width: 16),
            if (isMobile) const SizedBox(height: 16),
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
              child: _buildBarChartWidget(context, isMobile),
            ),
            if (!isMobile) const SizedBox(width: 16),
            if (isMobile) const SizedBox(height: 16),
            Expanded(
              flex: isMobile ? 0 : 1,
              child: _buildPieChartWidget(context, isMobile),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBarChartWidget(BuildContext context, bool isMobile) {
    return Container(
      height: 350,
      width: isMobile ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// ================= HEADER =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Calls Over Time",
                style: AppTextStyle.semiBold8.copyWith(fontSize: 16),
              ),
              _buildTimeFilter(context),
            ],
          ),

          SizedBox(height: 12),

          /// ================= CHART AREA =================
          Expanded(
            child: Obx(() {
              if (controller.dashboardController.isChartLoading.value) {
                return Container(
                  margin: EdgeInsets.symmetric(
                      vertical: Get.height * 0.08),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final data =
                  controller.dashboardController.barChartData;

              if (data.isEmpty) {
                return SizedBox(
                  height: 200,
                  child: const Center(
                    child: Text("No chart data available"),
                  ),
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
                              color: Colors.grey.shade300,
                              strokeWidth: 1,
                              dashArray: [4, 4],
                            );
                          },
                        ),

                        borderData: FlBorderData(show: false),

                        /// ===== TITLES =====
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),

                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index >= data.length) {
                                  return const SizedBox();
                                }

                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  space: 8,
                                  child: Text(
                                    data[index].label,
                                    style: const TextStyle(fontSize: 10),
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
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        /// ===== BARS =====
                        barGroups: data.asMap().entries.map((entry) {
                          int index = entry.key;
                          var spot = entry.value;

                          return BarChartGroupData(
                            x: index,
                            barsSpace: 10, // spacing between 2 bars
                            barRods: [
                              BarChartRodData(
                                toY: spot.incoming.count.toDouble(),
                                color: const Color(0xFF52C41A),
                                width: 14,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              BarChartRodData(
                                toY: spot.outgoing.count.toDouble(),
                                color: const Color(0xFF1890FF),
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
                            tooltipBgColor: Colors.white,
                            getTooltipItem:
                                (group, groupIndex, rod, rodIndex) {

                              final dataItem =
                              data[group.x.toInt()];

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
                                const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12),
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
                    const Color(0xFF52C41A), "Incoming"),
                _buildLegendItem(
                    const Color(0xFF1890FF), "Outgoing"),
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
          if (controller.dashboardController.selectedTimeFilter.value == 'Specific') {
            String dateText = "Select Date Range";

            if (controller.dashboardController.selectedDateRange.value != null) {
              final start = DateFormat('yyyy-MM-dd').format(
                  controller.dashboardController.selectedDateRange.value!.start);
              final end = DateFormat('yyyy-MM-dd').format(
                  controller.dashboardController.selectedDateRange.value!.end);
              dateText = "$start → $end";
            }

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF1890FF)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Text(
                        dateText,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey.shade500),
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
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller
                  .dashboardController.selectedTimeFilter.value,
              icon:
              const Icon(Icons.keyboard_arrow_down, size: 16),
              style: const TextStyle(
                  fontSize: 12, color: Colors.black87),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.dashboardController
                      .updateTimeFilter(newValue);

                  if (newValue == 'Specific' &&
                      controller.dashboardController
                          .selectedDateRange.value ==
                          null) {
                    showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    ).then((range) {
                      if (range != null) {
                        controller.dashboardController
                            .updateDateRange(range);
                      } else {
                        controller.dashboardController
                            .updateTimeFilter('Today');
                      }
                    });
                  }
                }
              },
              items: ['Today', 'Week', 'Month', 'Year', 'Specific']
                  .map((value) => DropdownMenuItem(
                value: value,
                child: Text(value),
              ))
                  .toList(),
            ),
          )),
        ),
      ],
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
          style: TextStyle(
            color: color,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPieChartWidget(BuildContext context, bool isMobile) {
    return Container(
      height: 350,
      width: isMobile ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Call Status Distribution",
            style: AppTextStyle.semiBold8.copyWith(fontSize: 16),
          ),
          const Expanded(child: SizedBox()),
          Center(
            child: SizedBox(
              height: 180,
              child: Obx(() {
                if (controller.dashboardController.isChartLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                int incoming = controller.dashboardController.incomingPieCount.value;
                int missed = controller.dashboardController.missedPieCount.value;
                int notAnswered = controller.dashboardController.notAnsweredPieCount.value;
                int outgoing = controller.dashboardController.outgoingPieCount.value;
                
                if (incoming == 0 && missed == 0 && notAnswered == 0 && outgoing == 0) {
                  return const Center(child: Text("No data for pie chart"));
                }

                return PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          controller.dashboardController.touchedPieIndex.value = -1;
                          return;
                        }
                        controller.dashboardController.touchedPieIndex.value =
                            pieTouchResponse.touchedSection!.touchedSectionIndex;
                      },
                    ),
                    sectionsSpace: 1,
                    centerSpaceRadius: 0,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                        color: const Color(0xFF52C41A), // Green - Incoming
                        value: incoming.toDouble(),
                        title: controller.dashboardController.touchedPieIndex.value == 0 ? incoming.toString() : '',
                        radius: controller.dashboardController.touchedPieIndex.value == 0 ? 100 : 90,
                        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      PieChartSectionData(
                        color: const Color(0xFFFAAD14), // Yellow/Orange - Missed
                        value: missed.toDouble(),
                        title: controller.dashboardController.touchedPieIndex.value == 1 ? missed.toString() : '',
                        radius: controller.dashboardController.touchedPieIndex.value == 1 ? 100 : 90,
                        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      PieChartSectionData(
                        color: const Color(0xFFFF4D4F), // Red - Not Answered
                        value: notAnswered.toDouble(),
                        title: controller.dashboardController.touchedPieIndex.value == 2 ? notAnswered.toString() : '',
                        radius: controller.dashboardController.touchedPieIndex.value == 2 ? 100 : 90,
                        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      PieChartSectionData(
                        color: const Color(0xFF1890FF), // Blue - Outgoing
                        value: outgoing.toDouble(),
                        title: controller.dashboardController.touchedPieIndex.value == 3 ? outgoing.toString() : '',
                        radius: controller.dashboardController.touchedPieIndex.value == 3 ? 100 : 90,
                        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const Expanded(child: SizedBox()),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItemm(color: const Color(0xFF52C41A), text: "Incoming"),
              const SizedBox(width: 16),
              _buildLegendItemm(color: const Color(0xFFFAAD14), text: "Missed"),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               _buildLegendItemm(color: const Color(0xFFFF4D4F), text: "Not Answered"),
               const SizedBox(width: 16),
               _buildLegendItemm(color: const Color(0xFF1890FF), text: "Outgoing"),
            ],
          ),
        ],
      ));
    }

  Widget _buildLegendItemm({required Color color, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
