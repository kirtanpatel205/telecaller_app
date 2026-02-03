import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class WelcomeController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    // allpermisio();
  }

  // allpermisio()async{
  //   BackgroundService().initialize();
  //   BackgroundService().fetchSimInfo();
  //   await Get.put<FCMService>(FCMService()).init();
  //   await Get.put<AppService>(AppService()).init();
  // }

  PageController pageController =
      PageController(); // this is for pageViewBuilder

  RxInt currentPage = 0.obs; // this is use for current page of welcome screen

  RxList onBoardingData =
      [
        {
          "image": 'assets/images/d1.png',
          "title": 'User Friendly'.tr,
          "description":
              "User-friendly is a term that describes features and @nl functions that make using a device, system or website easier.",
        },
        {
          "image": 'assets/images/d2.png',
          "title": 'Advance Reporting'.tr,
          "description":"he process of collecting data, breaking down information into @nl meaningful pieces, and then putting it back together in a @nl way that makes sense to the reader.",

        },
        {
          "image": 'assets/images/d3.png',
          "title": '24 7 Service/Support'.tr,
          "description":"customers can get help and find answers to questions as @nl soon as they come up—24/7 and in real-time.",

        },
      ].obs; // this list is used for all data like images,text and subtext

  onPageChange(
    int index,
  ) // this function is used for changing the page of screen
  {
    currentPage.value = index;
  }
}
