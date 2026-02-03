
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_routes.dart';
import 'package:telecaller_app/constants/app_text_style.dart';
import 'package:telecaller_app/ui/views/welcome/welcome_controller.dart';
import 'package:telecaller_app/ui/widgets/app_safe_area.dart';
import 'package:telecaller_app/ui/widgets/custom_button.dart';

// import 'package:getwidget/getwidget.dart';

class WelcomePage extends GetView<WelcomeController> {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return AppSafeArea(child: Obx(() => Scaffold(
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
                      //mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Image.asset(
                            controller.onBoardingData[index]['image'],
                            width: 0.8.sw,
                          ),
                        ),
                        SizedBox(height: 30),
                        // SizedBox(height: screenHeight *  0.07,),
                        // Center(
                        //     child:
                        Padding(
                          padding: EdgeInsets.all(0.0),
                          child: Text(
                            controller.onBoardingData[index]['title'],
                            style:
                                AppTextStyle.titleBold.copyWith(fontSize: 18),
                            //style: AppTextStyle.bold13.copyWith(fontSize: 20,color: AppColors.themeColor.textPrimaryColor),
                          ),
                        ),
                        SizedBox(height: 40),

                        Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text(
                              "${controller.onBoardingData[index]['description']}"
                                  .trParams({"nl": "\n"}),
                              // (controller.onBoardingData[index]['description'],
                              textAlign: TextAlign.center,
                              style: AppTextStyle.regular9.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      AppColors.themeColor.textPrimaryColor)),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List<Widget>.generate(
                            controller.onBoardingData.length, (index) {
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            height: 10,
                            width: (index == controller.currentPage.value)
                                ? 10
                                : 10,
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: (index == controller.currentPage.value)
                                    ? AppColors.themeColor.primaryColor
                                    : AppColors.themeColor.textSecondaryColor),
                          );
                        })),
                    SizedBox(
                      height: screenHeight * 0.05,
                    ),
                    (controller.currentPage ==
                            controller.onBoardingData.length - 1)
                        ? CustomButton(

                          onClick: () => Get.toNamed(Routes.LOGIN),
                            title: 'getstarted'.tr,
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.only(left: screenWidth * 0.01),
                                child: TextButton(
                                  onPressed: () {

                                    // Navigate to login page
                                    Get.toNamed(Routes.LOGIN);
                                  },
                                  child: Text('skip'.tr,
                                      style: AppTextStyle.regular8.copyWith(
                                          fontSize: 12,
                                          color: AppColors
                                              .themeColor.textPrimaryColor,
                                          fontWeight: FontWeight.w500)),
                                ),
                              ),

                              Padding(
                                padding:
                                    EdgeInsets.only(right: screenWidth * 0.01),
                                child: TextButton(
                                  onPressed: () {
                                    if (controller.pageController.page! <
                                        controller.onBoardingData.length - 1) {
                                      controller.pageController.nextPage(
                                          duration: Duration(milliseconds: 300),
                                          curve: Curves.ease);
                                    } else {
                                     Get.toNamed(Routes.LOGIN);
                                    }
                                  },
                                  child: Text('next'.tr,
                                      style: AppTextStyle.regular8.copyWith(
                                          fontSize: 12,
                                          color:
                                              AppColors.themeColor.primaryColor,
                                          fontWeight: FontWeight.w500)),
                                ),
                              ),
                              //  ),
                            ],
                          )
                  ],
                ).paddingAll(8.r),
              )
            ],
          ),
        )));
  }
}
