import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomCard extends StatelessWidget {
  final Widget? child;
  final Function()? onClick;
  final bool showLine;
  final Color? lineColor;
  final Color? bgColor;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double radius;

  const CustomCard(
      {Key? key,
      this.onClick,
      this.showLine = false,
      this.lineColor,
      this.child,
      this.padding = const EdgeInsets.only(top: 0,left: 5,right: 5),
      this.margin = const EdgeInsets.all(5),
      this.radius = 20,
      this.bgColor})
      : super(key: key);

  Widget cc({
    bool showLine = false,
    required Color lineColor,
    required Widget child,
  }) {
    return Card(
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return this.onClick != null
        ? Bounce(
            onTap: this.onClick,
            child: mainCardContent(),
          )
        : mainCardContent();
  }

  Widget mainCardContent() {
    return Container(
        margin: this.showLine ? this.margin : EdgeInsets.zero,
        padding: this.showLine ? this.padding : EdgeInsets.zero,
        child: Column(
            //mainAxisSize: MainAxisSize.max,
            children: [
              if (this.showLine)
                Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      alignment: Alignment.bottomRight,
                      width: Get.width * 0.15,
                      height: 2,
                      margin: EdgeInsets.only(right: Get.width * 0.06),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: this.lineColor),
                    )),
              Container(
                  //    color: Colors.white,

                  padding: this.showLine ? EdgeInsets.zero : this.padding,
                  // decoration: BoxDecoration(
                  //   borderRadius: BorderRadius.circular(this.radius),
                  //   color: this.bgColor ?? AppColors.themeColor.cardColor,
                  //   boxShadow: [
                  //     BoxShadow(
                  //         color: Colors.white.withOpacity(0.5),
                  //         blurRadius: 4.0,
                  //         offset: Offset(0.0, 3.0)),
                  //   ],
                  // ),
                  width: double.infinity,
                  child: Card(
                      color: this.bgColor,
                      margin: this.showLine ? EdgeInsets.zero : this.margin,
                      child: this.child))
            ]));
  }
}
