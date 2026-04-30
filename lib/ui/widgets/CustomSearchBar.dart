

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_dimens.dart';
import 'package:telecaller_app/constants/app_text_style.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final Function(String)? onSearch;
  final String? hintText;
  final Duration debounceDuration;

  const CustomSearchBar({
    Key? key,
    this.controller,
    this.onSearch,
    this.hintText,
    this.debounceDuration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  Timer? _debounce;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(widget.debounceDuration, () {
      if (widget.onSearch != null) {
        widget.onSearch!(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final theme = AppColors.themeColor;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: _isFocused 
                  ? theme.primaryColor.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: _isFocused 
                ? theme.primaryColor.withOpacity(0.5) 
                : theme.bordercolror.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          onChanged: _onSearchChanged,
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            if (widget.onSearch != null) {
              widget.onSearch!(value);
            }
          },
          style: AppTextStyle.medium7.copyWith(
            color: theme.textPrimaryColor,
            fontSize: AppDimens.fontSize14,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText ?? "search_name_phone_email".tr,
            hintStyle: AppTextStyle.medium7.copyWith(
              color: theme.textSecondaryColor.withOpacity(0.6),
              fontSize: AppDimens.fontSize14,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _isFocused ? theme.primaryColor : theme.textSecondaryColor,
              size: 22.sp,
            ),
            suffixIcon: widget.controller != null && widget.controller!.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: theme.textSecondaryColor,
                      size: 20.sp,
                    ),
                    onPressed: () {
                      widget.controller!.clear();
                      _onSearchChanged("");
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
        ),
      );
    });
  }
}
