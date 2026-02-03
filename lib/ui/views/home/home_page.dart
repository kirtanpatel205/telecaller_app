import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_routes.dart';
import 'package:telecaller_app/core/helpers/storage.dart';
import 'package:telecaller_app/ui/views/home/home_controller.dart';
import 'package:telecaller_app/ui/widgets/custom_button.dart';

class HomePage extends GetView<HomeController>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(

      appBar: AppBar(
        title:  Text("Home"),

      ),

      body: Column(
        children: [
          Text("User Logout"),
          SizedBox(height: 20,),
          CustomButton(onClick: (){
            Storage.clearStorage();
            Get.offAllNamed(Routes.LOGIN);
          }, title: "Logout")

        ],
      ),


    );
  }
}