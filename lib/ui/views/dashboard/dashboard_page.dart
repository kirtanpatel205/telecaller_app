import 'package:bounce/bounce.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_routes.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/ui/views/home/overlay/overlay_pages.dart';
import 'package:telecaller_app/ui/widgets/custom-appbar.dart';
import 'package:telecaller_app/constants/app_dimens.dart';

import '../home/home_controller.dart';

class DashboardPage extends GetView<HomeController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        // 👉 PROFILE IMAGE
        leading: Padding(
          padding: EdgeInsets.only(left: 12.w),
          child: Bounce(
            onTap: () {
              Get.toNamed(Routes.EDITPROFILE);
            },
            child: Obx(() => Container(
              height: 40.h,
              width: 40.w,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: controller.authController.profile.value?.profile
                  ?.isNotEmpty ==
                  true
                  ? Image.network(
                "https://api-test.digibulkmarketing.com${controller.authController.profile.value!.profile!}",
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                Icon(Icons.error, size: 20.sp),
              )
                  : Center(
                child: Text(
                  controller.authController.profile.value?.name
                      ?.isNotEmpty ==
                      true
                      ? controller
                      .authController.profile.value!.name![0]
                      : "N",
                  style: AppTextStyle.bold12.copyWith(
                    fontSize: AppDimens.fontSize20,
                    color: AppColors.themeColor.primaryColor,
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
                    "no_name".tr,
                style: AppTextStyle.bold8.copyWith(
                  fontSize: AppDimens.fontSize12,
                  color: AppColors.themeColor.textPrimaryColor,
                ),
              ),
              Text(
                'how_are_you_today'.tr,
                style: AppTextStyle.regular6.copyWith(
                  fontSize: AppDimens.fontSize10,
                  color: AppColors.themeColor.textSecondaryColor,
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
            },
            child: GFAvatar(
              radius: 18.r,
              backgroundColor:
              AppColors.themeColor.primaryColor,
              child: Icon(
                Icons.notifications_none_outlined,
                color: Colors.white,
                size: 20.sp,
              ),
            ).paddingAll(10.w),
          ),
        ],
      ),

      // 👉 PAGE BODY
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppDimens.padding16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "dashboard_overview".tr,
                style: AppTextStyle.bold11.copyWith(
                  fontSize: AppDimens.fontSize20,
                  color: AppColors.themeColor.textPrimaryColor,
                ),
              ),
              SizedBox(height: 16.h),
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
        border: Border.all(color: AppColors.themeColor.bordercolror.withOpacity(0.5), width: 1.w),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.08),
            blurRadius: 15.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10.w,
            bottom: -10.h,
            child: Icon(
              icon,
              size: 70.sp,
              color: iconColor.withOpacity(0.04),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 18.sp,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value,
                        style: AppTextStyle.bold11.copyWith(
                          fontSize: AppDimens.fontSize22,
                          color: AppColors.themeColor.textPrimaryColor,
                        ),
                      ),
                    ),
                    Text(
                      title,
                      style: AppTextStyle.medium7.copyWith(
                        fontSize: AppDimens.fontSize12,
                        color: AppColors.themeColor.textSecondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
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
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            mainAxisExtent: 130.h,
          ),
          children: [
            Obx(() => _buildSummaryCard(
              title: "active_telecallers".tr,
              value: "${controller.dashboardController.activeTelecallers.value}",
              subtitle: "handling_customer_calls".tr,
              bgColor: AppColors.themeColor.activekeyColor, // Light Blue
              icon: Icons.notifications_active_outlined,
              iconColor: AppColors.themeColor.primaryColor.withAlpha(200),
            )),
            Obx(() => _buildSummaryCard(
              title: "Leads",
              value: "${controller.dashboardController.leadsCount.value}",
              subtitle: "awaiting_contact".tr,
              bgColor: AppColors.themeColor.avilablekeyColor, // Light Grey
              icon: Icons.person_add_outlined,
            iconColor: AppColors.themeColor.primaryColor.withAlpha(200),
            )),
            Obx(() => _buildSummaryCard(
              title: "orders".tr,
              value: "${controller.dashboardController.ordersCount.value}",
              subtitle: "processed_purchases".tr,
              bgColor: AppColors.themeColor.completedBgColor, // Light Green
              icon: Icons.headset_mic_outlined,
              iconColor: AppColors.themeColor.primaryColor.withAlpha(200),
            )),
            Obx(() => _buildSummaryCard(
              title: "forms_submitted".tr,
              value: "${controller.dashboardController.formsSubmitted.value}",
              subtitle: "customer_inquiries_received".tr,
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
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppColors.themeColor.cardBgColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.themeColor.bordercolror.withOpacity(0.5), width: 1.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.themeColor.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(AppDimens.radius12),
            ),
            child: Text(
              title,
              style: AppTextStyle.bold8.copyWith(
                fontSize: AppDimens.fontSize12,
                color: AppColors.themeColor.textPrimaryColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      todayVal,
                      style: AppTextStyle.bold11.copyWith(fontSize: AppDimens.fontSize20),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "today".tr,
                      style: AppTextStyle.regular6.copyWith(
                        fontSize: AppDimens.fontSize12,
                        color: AppColors.themeColor.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 5.w),
              Container(width: 1.w, height: 40.h, color: AppColors.themeColor.bordercolror),
              SizedBox(width: 5.w),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      totalVal,
                      style: AppTextStyle.bold11.copyWith(fontSize: AppDimens.fontSize20),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "total".tr,
                      style: AppTextStyle.regular6.copyWith(
                        fontSize: AppDimens.fontSize12,
                        color: AppColors.themeColor.textSecondaryColor,
                      ),
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
        color: AppColors.themeColor.cardBgColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.themeColor.bordercolror.withOpacity(0.5), width: 1.w),
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
            child: Text(
              "lead_contact".tr,
              style: AppTextStyle.bold8.copyWith(
                fontSize: AppDimens.fontSize16,
                color: AppColors.themeColor.primaryColor,
              ),
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
                    Obx(() => _buildMetricBox(
                      "all".tr,
                      "${controller.dashboardController.leadContactAllToday.value}",
                      "${controller.dashboardController.leadContactAllTotal.value}",
                    )),
                    Obx(() => _buildMetricBox(
                      "completed".tr,
                      "${controller.dashboardController.leadContactCompletedToday.value}",
                      "${controller.dashboardController.leadContactCompletedTotal.value}",
                    )),
                    Obx(() => _buildMetricBox(
                      "scheduled".tr,
                      "${controller.dashboardController.leadContactScheduledToday.value}",
                      "${controller.dashboardController.leadContactScheduledTotal.value}",
                    )),
                    Obx(() => _buildMetricBox(
                      "pending".tr,
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
        color: AppColors.themeColor.cardBgColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.themeColor.bordercolror.withOpacity(0.5), width: 1.w),
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
            child: Text(
              "calls".tr,
              style: AppTextStyle.bold8.copyWith(
                fontSize: AppDimens.fontSize16,
                color: Colors.white,
              ),
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
                    Obx(() => _buildMetricBox(
                      "incoming".tr,
                      "${controller.dashboardController.callsIncomingToday.value}",
                      "${controller.dashboardController.callsIncomingTotal.value}",
                    )),
                    Obx(() => _buildMetricBox(
                      "missed".tr,
                      "${controller.dashboardController.callsMissedToday.value}",
                      "${controller.dashboardController.callsMissedTotal.value}",
                    )),
                    Obx(() => _buildMetricBox(
                      "not_answered".tr,
                      "${controller.dashboardController.callsNotAnsweredToday.value}",
                      "${controller.dashboardController.callsNotAnsweredTotal.value}",
                    )),
                    Obx(() => _buildMetricBox(
                      "outgoing".tr,
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
        border: Border.all(color: AppColors.themeColor.bordercolror.withOpacity(0.5), width: 1.w),
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
              Text(
                "calls_over_time".tr,
                style: AppTextStyle.bold8.copyWith(fontSize: AppDimens.fontSize16),
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
                  child:  Center(
                    child: Text("no_chart_data_available".tr),
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
                                  space: 8.w,
                                  child: Text(
                                    data[index].label,
                                    style: TextStyle(fontSize: AppDimens.fontSize10),
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
                                    style: TextStyle(fontSize: AppDimens.fontSize10),
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
                                TextStyle(
                                    color: AppColors.themeColor.textPrimaryColor,
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
                    AppColors.themeColor.completedColor, "incoming".tr),
                _buildLegendItem(
                    AppColors.themeColor.primaryColor, "outgoing".tr),
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
            String dateText = "select_date_range".tr;

            if (controller.dashboardController.selectedDateRange.value != null) {
              final start = DateFormat('yyyy-MM-dd').format(
                  controller.dashboardController.selectedDateRange.value!.start);
              final end = DateFormat('yyyy-MM-dd').format(
                  controller.dashboardController.selectedDateRange.value!.end);
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
                  padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.themeColor.primaryColor.withOpacity(0.05),
                    border: Border.all(color: AppColors.themeColor.primaryColor.withOpacity(0.5), width: 1.w),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Text(
                        dateText,
                        style: AppTextStyle.medium7.copyWith(fontSize: AppDimens.fontSize12, color: AppColors.themeColor.primaryColor),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.calendar_today_rounded,
                          size: 14.sp, color: AppColors.themeColor.primaryColor),
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
            border: Border.all(color: AppColors.themeColor.bordercolror.withOpacity(0.5), width: 1.w),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller
                  .dashboardController.selectedTimeFilter.value,
              icon:
              Icon(Icons.keyboard_arrow_down_rounded, size: 18.sp, color: AppColors.themeColor.primaryColor),
              style: AppTextStyle.medium7.copyWith(
                  fontSize: AppDimens.fontSize12, color: AppColors.themeColor.textPrimaryColor),
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

  Widget _buildPieChartWidget(BuildContext context, bool isMobile) {
    return Container(
      height: 350.h,
      width: isMobile ? double.infinity : null,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.themeColor.cardBgColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.themeColor.bordercolror.withOpacity(0.5), width: 1.w),
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

                int incoming    = controller.dashboardController.incomingPieCount.value;
                int missed      = controller.dashboardController.missedPieCount.value;
                int notAnswered = controller.dashboardController.notAnsweredPieCount.value;
                int outgoing    = controller.dashboardController.outgoingPieCount.value;

                if (incoming == 0 && missed == 0 && notAnswered == 0 && outgoing == 0) {
                  return  Center(child: Text("no_chart_data_available".tr));
                }

                // ── Build valid data list ──────────────────────────────────
                List<Map<String, dynamic>> validData = [];
                if (incoming > 0)    validData.add({"value": incoming,    "color": AppColors.themeColor.completedColor});
                if (missed > 0)      validData.add({"value": missed,      "color": AppColors.themeColor.activekeyiconColor});
                if (notAnswered > 0) validData.add({"value": notAnswered, "color": AppColors.themeColor.failColor});
                if (outgoing > 0)    validData.add({"value": outgoing,    "color": AppColors.themeColor.primaryColor});

                // ── FIX: enforce minimum 2.5% so tiny slices stay visible ─
                // Without this, "not_answered_12".tr out of 3235 total = 0.37%
                // which renders as an invisible sliver on the pie chart.
                const double minPercent = 2.5;
                final double rawTotal = validData.fold(0.0, (sum, e) => sum + (e["value"] as int).toDouble());

                List<double> adjustedValues = validData.map((e) {
                  double pct = (e["value"] as int) / rawTotal * 100;
                  return pct.clamp(minPercent, 100.0);
                }).toList();

                // Re-normalise so adjusted values still sum to rawTotal
                final double adjSum = adjustedValues.fold(0.0, (s, v) => s + v);
                adjustedValues = adjustedValues.map((v) => v / adjSum * rawTotal).toList();
                // ─────────────────────────────────────────────────────────

                List<PieChartSectionData> pieChartSections = [];

                for (int i = 0; i < validData.length; i++) {
                  bool isTouched = controller.dashboardController.touchedPieIndex.value == i;
                  pieChartSections.add(
                    PieChartSectionData(
                      color: validData[i]["color"],
                      value: adjustedValues[i],          // ← adjusted value (visual only)
                      title: isTouched
                          ? (validData[i]["value"] as int).toString()  // ← show real value on touch
                          : '',
                      radius: isTouched ? 100 : 90,
                      titleStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
                    sections: pieChartSections,
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
              _buildLegendItem(AppColors.themeColor.completedColor, "incoming".tr),
              _buildLegendItem(AppColors.themeColor.activekeyiconColor, "missed".tr),
              _buildLegendItem(AppColors.themeColor.failColor, "not_answered".tr),
              _buildLegendItem(AppColors.themeColor.primaryColor, "outgoing".tr),
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
        border: Border.all(color: AppColors.themeColor.bordercolror.withOpacity(0.5), width: 1.w),
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
              Text(
                "leads_over_time".tr,
                style: AppTextStyle.semiBold8.copyWith(fontSize: 16),
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
                  child:  Center(child: Text("no_chart_data_available".tr)),
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
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index >= data.length) return const SizedBox();
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
                        barGroups: data.asMap().entries.map((entry) {
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
                                TextStyle(color: AppColors.themeColor.textPrimaryColor, fontSize: 12),
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
                    AppColors.themeColor.primaryColor, "total_leads".tr),
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
          if (controller.dashboardController.selectedLeadTimeFilter.value == 'Specific') {
            String dateText = "select_date_range".tr;
            if (controller.dashboardController.selectedLeadDateRange.value != null) {
              final start = DateFormat('yyyy-MM-dd').format(controller.dashboardController.selectedLeadDateRange.value!.start);
              final end = DateFormat('yyyy-MM-dd').format(controller.dashboardController.selectedLeadDateRange.value!.end);
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
                    initialDateRange: controller.dashboardController.selectedLeadDateRange.value,
                  );
                  if (range != null) {
                    controller.dashboardController.updateLeadDateRange(range);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.themeColor.primaryColor.withOpacity(0.05),
                    border: Border.all(color: AppColors.themeColor.primaryColor.withOpacity(0.5), width: 1.w),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Text(dateText, style: AppTextStyle.medium7.copyWith(fontSize: AppDimens.fontSize12, color: AppColors.themeColor.primaryColor)),
                      SizedBox(width: 8.w),
                      Icon(Icons.calendar_today_rounded, size: 14.sp, color: AppColors.themeColor.primaryColor),
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
            border: Border.all(color: AppColors.themeColor.bordercolror.withOpacity(0.5), width: 1.w),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.dashboardController.selectedLeadTimeFilter.value,
              icon: Icon(Icons.keyboard_arrow_down_rounded, size: 18.sp, color: AppColors.themeColor.primaryColor),
              style: AppTextStyle.medium7.copyWith(fontSize: AppDimens.fontSize12, color: AppColors.themeColor.textPrimaryColor),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.dashboardController.updateLeadTimeFilter(newValue);
                  if (newValue == 'Specific' && controller.dashboardController.selectedLeadDateRange.value == null) {
                    showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    ).then((range) {
                      if (range != null) {
                        controller.dashboardController.updateLeadDateRange(range);
                      } else {
                        controller.dashboardController.updateLeadTimeFilter('Today');
                      }
                    });
                  }
                }
              },
              items: ['Today', 'Week', 'Month', 'Year', 'Specific']
                  .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
            ),
          )),
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
        border: Border.all(color: AppColors.themeColor.bordercolror.withOpacity(0.5), width: 1.w),
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
            style: AppTextStyle.semiBold8.copyWith(fontSize: 16),
          ),
          const Expanded(child: SizedBox()),
          Center(
            child: SizedBox(
              height: 180,
              child: Obx(() {
                if (controller.dashboardController.isLeadChartLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                int completed = controller.dashboardController.leadCompletedPieCount.value;
                int scheduled = controller.dashboardController.leadScheduledPieCount.value;
                int pending = controller.dashboardController.leadPendingPieCount.value;
                
                if (completed == 0 && scheduled == 0 && pending == 0) {
                  return  Center(child: Text("no_chart_data_available".tr));
                }

                List<PieChartSectionData> pieChartSections = [];
                List<Map<String, dynamic>> validData = [];
                
                if (completed > 0) validData.add({"value": completed, "color": AppColors.themeColor.completedColor});
                if (scheduled > 0) validData.add({"value": scheduled, "color": AppColors.themeColor.activekeyiconColor});
                if (pending > 0) validData.add({"value": pending, "color": AppColors.themeColor.failColor});

                for (int i = 0; i < validData.length; i++) {
                  bool isTouched = controller.dashboardController.touchedLeadPieIndex.value == i;
                  pieChartSections.add(
                    PieChartSectionData(
                      color: validData[i]["color"],
                      value: validData[i]["value"].toDouble(),
                      title: isTouched ? validData[i]["value"].toString() : '',
                      radius: isTouched ? 100 : 90,
                      titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
                          controller.dashboardController.touchedLeadPieIndex.value = -1;
                          return;
                        }
                        controller.dashboardController.touchedLeadPieIndex.value =
                            pieTouchResponse.touchedSection!.touchedSectionIndex;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               _buildLegendItem(AppColors.themeColor.failColor, "pending".tr),
            ],
          ),
        ],
      )
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

}
