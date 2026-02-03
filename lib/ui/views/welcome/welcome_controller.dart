
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class WelcomeController extends GetxController{



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

  PageController pageController = PageController();// this is for pageViewBuilder

  RxInt currentPage = 0.obs;  // this is use for current page of welcome screen

   RxList onBoardingData = [

     {
       "image": 'assets/images/d1.png',
       "title": 'welcome1'.tr,
       "description": 'welcomeD1'.tr,
     },
     {
       "image": 'assets/images/d2.png',
       "title": 'welcome2'.tr,
       "description": 'welcomeD2'.tr,
     },
     {
       "image": 'assets/images/d3.png',
       "title": 'welcome3'.tr,
       "description": 'welcomeD3'.tr,
     },

   ].obs; // this list is used for all data like images,text and subtext

  onPageChange(int index) // this function is used for changing the page of screen
  {
    currentPage.value = index;
  }



}