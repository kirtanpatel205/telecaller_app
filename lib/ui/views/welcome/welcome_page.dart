import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_dimens.dart';
import 'package:telecaller_app/constants/app_routes.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/ui/views/welcome/welcome_controller.dart';
import 'package:telecaller_app/ui/widgets/ProminentDisclosurePage.dart';
import 'package:telecaller_app/ui/widgets/app_safe_area.dart';
import 'package:telecaller_app/ui/widgets/custom_button.dart';

// import 'package:getwidget/getwidget.dart';

class WelcomePage extends GetView<WelcomeController> {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return AppSafeArea(child: Obx(() =>
        Scaffold(
          body: Stack(
            children: [
              PageView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.onBoardingData.length,
                controller: controller.pageController,
                onPageChanged: (index) {
                  controller.onPageChange(index);
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.15),
                    child: Column(
                      children: [
                        Flexible(
                          child: Image.asset(
                            controller.onBoardingData[index]['image'],
                            width: 0.8.sw,
                          ),
                        ),
                        SizedBox(height: 30.h),
                        Padding(
                          padding: EdgeInsets.zero,
                          child: Text(
                            controller.onBoardingData[index]['title'],
                            style: AppTextStyle.bold7.copyWith(
                              fontSize: AppDimens.fontSize18,
                              color: AppColors.themeColor.textPrimaryColor,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40.w),
                          child: Text(
                            "${controller.onBoardingData[index]['description']}"
                                .tr.trParams({"nl": "n".tr}),
                            textAlign: TextAlign.center,
                            style: AppTextStyle.regular7.copyWith(
                              fontSize: AppDimens.fontSize12,
                              color: AppColors.themeColor.textSecondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List<Widget>.generate(
                            controller.onBoardingData.length, (index) {
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            height: 8.h,
                            width: (index == controller.currentPage.value)
                                ? 24.w
                                : 8.w,
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50.r),
                                color: (index == controller.currentPage.value)
                                    ? AppColors.themeColor.primaryColor
                                    : AppColors.themeColor.textSecondaryColor.withOpacity(0.3)),
                          );
                        })),
                    SizedBox(
                      height: 30.h,
                    ),
                    (controller.currentPage ==
                        controller.onBoardingData.length - 1)
                        ? CustomButton(
                      onClick: () {
                        Get.to(ProminentDisclosurePage());
                      },
                      title: 'Get Started',
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10.w),
                          child: TextButton(
                            onPressed: () {
                              Get.to(ProminentDisclosurePage());
                            },
                            child: Text('Skip'.tr,
                                style: AppTextStyle.medium7.copyWith(
                                    fontSize: AppDimens.fontSize14,
                                    color: AppColors.themeColor.textSecondaryColor,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(right: 10.w),
                          child: TextButton(
                            onPressed: () {
                              if (controller.pageController.page! <
                                  controller.onBoardingData.length - 1) {
                                controller.pageController.nextPage(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.ease);
                              } else {
                                Get.to(ProminentDisclosurePage());
                              }
                            },
                            child: Text('Next'.tr,
                                style: AppTextStyle.bold7.copyWith(
                                    fontSize: AppDimens.fontSize14,
                                    color: AppColors.themeColor.primaryColor,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ],
                    )
                  ],
                ).paddingAll(16.r),
              )
            ],
          ),
        )));
  }
}
