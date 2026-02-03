import 'package:flutter/material.dart';

class AppSafeArea extends StatelessWidget {
  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  final EdgeInsets minimum;

  const AppSafeArea({
    super.key,
    required this.child,
    this.top = false,
    this.bottom = true,
    this.left = true,
    this.right = true,
    this.minimum = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        minimum: minimum,
        child: child,
      ),
    );
  }
}
