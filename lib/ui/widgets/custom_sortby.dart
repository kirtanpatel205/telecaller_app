import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/constants/app_text_style.dart';


class CustomSortby extends StatefulWidget {
  final List<String> items;
  final Function(String) onChanged;
  final String selectedItem;

  const CustomSortby({
    Key? key,
    required this.items,
    required this.onChanged,
    required this.selectedItem,
  }) : super(key: key);

  @override
  _CustomSortbyState createState() => _CustomSortbyState();
}

class _CustomSortbyState extends State<CustomSortby> {
  late String dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.selectedItem;
  }

  void _showSortBottomSheet() {
    String tempValue = dropdownValue;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      backgroundColor: AppColors.themeColor.cardBgColor,
      builder: (BuildContext context) {
        // Calculate desired height dynamically
        final int itemCount = widget.items.length;
        final double itemHeight = 50.0; // Estimated height per item row
        final double baseHeight = 100.0; // Fixed height for header + padding
        final double maxHeight = MediaQuery.of(context).size.height * 0.6;

        double calculatedHeight =
            baseHeight + (itemCount * itemHeight).clamp(0, maxHeight - baseHeight);

        return Container(
          height: calculatedHeight,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'sortby'.tr,
                style: AppTextStyle.bold7.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.themeColor.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Divider(
                color: AppColors.themeColor.bordercolror ??
                    Colors.black.withOpacity(0.1),
                thickness: 1,
              ),
              Expanded(
                child: widget.items.isEmpty
                    ? Text(
                  'No sort options available',
                  style: AppTextStyle.bold7,
                )
                    : ListView.builder(
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.toUpperCase(),
                            style: AppTextStyle.bold7.copyWith(
                              color: AppColors.themeColor.textPrimaryColor,
                            ),
                          ),
                          Radio<String>(
                            value: item,
                            groupValue: tempValue,
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  dropdownValue = value;
                                });
                                widget.onChanged(value);
                                Navigator.pop(context);
                              }
                            },
                            activeColor: AppColors.themeColor.primaryColor,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Divider(
                color: AppColors.themeColor.bordercolror ??
                    Colors.black.withOpacity(0.1),
                thickness: 1,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showSortBottomSheet,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.themeColor.bgColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: AppColors.themeColor.primaryColor.withOpacity(0.2),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1.0,
              blurRadius: 4.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                '${'sortby'.tr}: $dropdownValue',
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bold7.copyWith(
                  color: AppColors.themeColor.textPrimaryColor,
                  fontSize: 10,
                ),
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.sort,
              color: AppColors.themeColor.textPrimaryColor,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
