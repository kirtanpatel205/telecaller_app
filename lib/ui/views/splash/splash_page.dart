import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      backgroundColor: Colors.white,
      body: Center(
          child: Image.asset(
        'assets/images/Frame.png',
        width: 0.5.sw,
        fit: BoxFit.contain,
      )),
    ));
  }
}
