import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/ui/views/splash/splash_controller.dart';
import 'package:telecaller_app/ui/widgets/app_safe_area.dart';

class SplashPage extends GetView<SplashController> {
  SplashPage() {
    controller.startTime();
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return AppSafeArea(child: Scaffold(
      body: Center(
          child: Image.asset(
        'assets/images/Frame.png',
        width: screenWidth * 0.50,
        height: screenWidth * 0.50,
        fit: BoxFit.cover,
      )),
    ));
  }
}
