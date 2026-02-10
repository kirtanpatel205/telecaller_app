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

          // ================= FAB =================
          // floatingActionButton:
          // controller.currentTab.value == 1 ||
          //     controller.currentTab.value == 2 ||
          //     controller.currentTab.value == 3
          //     ? FloatingActionButton(
          //   backgroundColor:
          //   controller.isCallStarted.value &&
          //       controller.currentTab.value != 3 &&
          //       controller.currentTab.value != 1
          //       ? AppColors.themeColor.otpWrongColor
          //       : controller.isCallTask.value
          //       ? AppColors.themeColor.otpRightColor
          //       : AppColors.themeColor.primaryColor,
          //
          //   child: controller.currentTab.value == 1
          //       ? Icon(Icons.add,
          //       color: AppColors.themeColor.cardColor)
          //       : controller.currentTab.value == 3
          //       ? const Icon(Icons.add)
          //       : controller.isCallStarted.value
          //       ? Icon(Icons.play_arrow,
          //       color:
          //       AppColors.themeColor.cardColor)
          //       : Icon(Icons.call,
          //       color:
          //       AppColors.themeColor.cardColor),
          //
          //   onPressed: () {
          //     if (controller.currentTab.value == 1) {
          //       Get.toNamed(Routes.ADDCUSTOMER, arguments: {
          //         "name": controller.selectedTabIndex.value
          //       });
          //     } else if (controller.currentTab.value == 3) {
          //       Get.toNamed(Routes.CREATEORDER);
          //     } else if (controller.isCallStarted.value) {
          //       controller.isCallStarted.value = false;
          //       controller.startCall(context);
          //       controller.isCallInProgress.value = true;
          //       Utils.showToast("Call Start");
          //     } else if (!controller.isSleepModeActive.value &&
          //         !controller.isCallTask.value) {
          //       controller.startCall(context);
          //       controller.isCallInProgress.value = true;
          //       Utils.showToast("Call Start");
          //     } else if (controller.isCallTask.value) {
          //       controller.isCallTask.value = false;
          //     }
          //   },
          // )
          //     : const SizedBox(),

          // ================= BOTTOM NAV =================
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
            },
          ),
        ),
      ),
    );
  }
}
