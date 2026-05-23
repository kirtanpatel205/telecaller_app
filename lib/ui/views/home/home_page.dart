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
  final DashboardPage _dashboardPage = const DashboardPage();
  final LeadsPage _leadsPage = LeadsPage();
  final AutoDialerPage _autoDialerPage = const AutoDialerPage();
  final SettingPage _settingPage = const SettingPage();

  @override
  Widget build(BuildContext context) {
    return AppSafeArea(
      top: false,
      child: Obx(() {
        final bool isWebMode = controller.autoDialerController.currentMode.value == 'web';

        final List<Widget> screens = [
          _dashboardPage,
          _leadsPage,
          if (!isWebMode) _autoDialerPage,
          _settingPage,
        ];

        final List<Widget> navItems = [
          Icon(Icons.home, size: 24.sp, color: AppColors.themeColor.onPrimaryColor),
          Icon(Icons.call, size: 24.sp, color: AppColors.themeColor.onPrimaryColor),
          if (!isWebMode)
            Icon(Icons.quick_contacts_dialer, size: 24.sp, color: AppColors.themeColor.onPrimaryColor),
          Icon(Icons.settings, size: 24.sp, color: AppColors.themeColor.onPrimaryColor),
        ];

        // Guard against index out of bounds
        int currentIndex = controller.currentTab.value;
        if (currentIndex >= screens.length) {
          currentIndex = 0; // Reset to home
          Future.microtask(() => controller.currentTab.value = 0);
        }

        return Scaffold(
          backgroundColor: AppColors.themeColor.scaffoldBackgroundColor,
          body: screens[currentIndex],
          bottomNavigationBar: CurvedNavigationBar(
            key: ValueKey(isWebMode), // Ensure clean rebuild when mode switches
            index: currentIndex,
            height: 60.0,
            color: AppColors.themeColor.primaryColor,
            buttonBackgroundColor: AppColors.themeColor.primaryColor,
            backgroundColor: AppColors.themeColor.scaffoldBackgroundColor, // Match page background
            items: navItems,
            onTap: (index) {
              controller.onBottomTabChange(index);
            },
          ),
        );

      }),
    );
  }

}
