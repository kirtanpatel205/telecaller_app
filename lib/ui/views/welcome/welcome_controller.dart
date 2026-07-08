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
          "image": 'assets/images/Screenshot 2026-06-10 151602.png',
          "title": 'Welcome to Truecaller App',
          "description":
              "Experience the best telecalling features with our \n Truecaller app that makes communication easier.",
        },
        {
          "image": 'assets/images/Screenshot 2026-06-10 151345.png',
          "title": 'Advance Reporting',
          "description":"The process of collecting data, breaking down information into \n meaningful pieces, and then putting it back together in a \n way that makes sense to the reader.",
        },
        {
          "image": 'assets/images/Screenshot 2026-06-10 151656.png',
          "title": '24 7 Service/Support',
          "description":"Customers can get help and find answers to questions as \n soon as they come up—24/7 and in real-time.",
        },
      ].obs; // this list is used for all data like images,text and subtext

  onPageChange(
    int index,
  ) // this function is used for changing the page of screen
  {
    currentPage.value = index;
  }
}
