import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_dimens.dart';
import 'package:telecaller_app/ui/views/auto_dialer/autodialer_page.dart';
import 'package:telecaller_app/ui/views/home/home_controller.dart';
import 'package:telecaller_app/ui/views/leads/leads_page.dart';
import 'package:telecaller_app/ui/views/setting/setting_page.dart';
import 'package:telecaller_app/ui/widgets/app_safe_area.dart';
import '../dashboard/dashboard_page.dart';

class HomePage extends GetView<HomeController> {

  final List<Widget> screens = [
    DashboardPage(),
    LeadsPage(),
    AutoDialerPage(),
    SettingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return AppSafeArea(
      top: false,
      child: Obx(
            () => Scaffold(
          backgroundColor: AppColors.themeColor.scaffoldBackgroundColor,

          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: true,
                child: screens[controller.currentTab.value],
              ),
            ],
          ),
          bottomNavigationBar: CurvedNavigationBar(
            index: controller.currentTab.value,
            height: 60.0,
            color: AppColors.themeColor.primaryColor,
            buttonBackgroundColor: AppColors.themeColor.primaryColor,
            backgroundColor: Colors.transparent,

            items: [
              Icon(Icons.home, size: 24.sp, color: AppColors.themeColor.onPrimaryColor),
              Icon(Icons.call, size: 24.sp, color: AppColors.themeColor.onPrimaryColor),
              Icon(Icons.quick_contacts_dialer, size: 24.sp, color: AppColors.themeColor.onPrimaryColor),
              Icon(Icons.settings, size: 24.sp, color: AppColors.themeColor.onPrimaryColor),
            ],

            onTap: (index) {
              controller.onBottomTabChange(index);
            },
          ),
        ),
      ),
    );
  }
}
