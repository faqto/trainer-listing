import 'package:flutter/material.dart';

import '../../pages/home/home_constants.dart';

class FilterDropdown extends StatelessWidget {
  final String value;
  final String defaultValue;
  final List<String> values;
  final ValueChanged<String> onChanged;

  const FilterDropdown({
    super.key,
    required this.value,
    required this.defaultValue,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final active = value != defaultValue;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(right: space1),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      constraints: const BoxConstraints(minWidth: 150),
      decoration: BoxDecoration(
        color: active ? primaryColor : Colors.white.withAlpha(230),
        border: Border.all(color: active ? primaryColor : cardBorderColor),
        borderRadius: BorderRadius.circular(14),
        boxShadow: active ? premiumCardShadows : null,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: values.contains(value) ? value : defaultValue,
          dropdownColor: Colors.white,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: active ? Colors.white : mutedColor,
          ),
          isDense: true,
          selectedItemBuilder: (context) {
            return values.map((item) {
              return Text(
                item,
                style: TextStyle(
                  color: active ? Colors.white : inkColor,
                  fontWeight: FontWeight.w700,
                ),
              );
            }).toList();
          },
          items: values
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    style: TextStyle(
                      color: item == value && active ? primaryColor : inkColor,
                      fontWeight: FontWeight.w700,
                    ),
                    child: Text(item),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}
