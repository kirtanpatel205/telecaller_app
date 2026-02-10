import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_colors.dart';
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
      child: Obx(
            () => Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,

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
            height: 70,
            color: AppColors.themeColor.primaryColor,
            buttonBackgroundColor:
            AppColors.themeColor.primaryColor,
            backgroundColor: Colors.transparent,

            items: const [
              Icon(Icons.home, size: 26, color: Colors.white),
              Icon(Icons.call, size: 26, color: Colors.white),
              Icon(Icons.quick_contacts_dialer, size: 26, color: Colors.white),
              Icon(Icons.settings,
                  size: 26, color: Colors.white),
            ],

            onTap: (index) {
              controller.onBottomTabChange(index);
              controller.navigateToPage(index);
            },
          ),
        ),
      ),
    );
  }
}
