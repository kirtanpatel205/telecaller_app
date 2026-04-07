import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomDropdown extends StatelessWidget {
  final RxString selectedValue;
  final List<Map<String, String>> items;
  final String hintText;
  final Function(String) onChanged;

  const CustomDropdown({
    Key? key,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    this.hintText = "select_an_option",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1.0,
            blurRadius: 4.0,
            offset: const Offset(1.0, 1.0),
          )
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Obx(() => DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedValue.value.isEmpty
              ? null
              : selectedValue.value,
          hint: Text(hintText.tr),
          onChanged: (value) {
            if (value != null) {
              selectedValue.value = value;
              onChanged(value);
            }
          },
          items: items.map<DropdownMenuItem<String>>((option) {
            return DropdownMenuItem<String>(
              value: option["value"],
              child: Text(option["label"] ?? ""),
            );
          }).toList(),
        ),
      )),
    );
  }
}
