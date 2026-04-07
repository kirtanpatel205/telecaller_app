import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/ui/views/home/home_controller.dart';

class NotifictionPage extends GetView<HomeController>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("notification_page".tr),),
    );
  }
}