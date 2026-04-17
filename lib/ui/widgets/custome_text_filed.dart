import 'package:bounce/bounce.dart';
import 'package:control_style/control_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_text_style.dart';

class CustomTextFormField extends StatelessWidget {
  final String? hint;
  final String? Function(String?)? validator;
  final int? maxLine;
  final bool? isReadOnly;
  final TextEditingController controller;
  final TextInputType inputType;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;

  //final TextInputAction inputAction;

  const CustomTextFormField({
    Key? key,
    this.hint,
    this.maxLine,
    this.inputFormatters,
    this.validator,
    this.inputType = TextInputType.name,
    //  this.inputAction = TextInputAction.next,
    required this.controller,
    this.suffixIcon,
    this.isReadOnly,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.next,
      validator: this.validator,
      readOnly: isReadOnly ?? false,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        suffixIcon: suffixIcon,
        border: DecoratedInputBorder(
          shadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1.0,
                blurRadius: 2.0,
                offset: Offset(1.0, 1.0))
          ],
          child: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
        ),
        focusedBorder: DecoratedInputBorder(
          shadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1.0,
                blurRadius: 2.0,
                offset: Offset(1.0, 1.0))
          ],
          child: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
        ),
        fillColor: AppColors.themeColor.cardColor,
        hintText: this.hint,
        hintStyle: AppTextStyle.medium8.copyWith(fontSize: 14),
      ),
      controller: this.controller,
      keyboardType: this.inputType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
