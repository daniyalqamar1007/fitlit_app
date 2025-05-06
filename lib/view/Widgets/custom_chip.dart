import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../Utils/Colors.dart';

// import '../Utils/Colors.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? appcolor : themeController.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? appcolor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? themeController.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Custom Calendar Day Item
class CalendarDayItem extends StatelessWidget {
  final String day;
  final int date;
  final bool isSelected;
  final VoidCallback onTap;

  const CalendarDayItem({
    Key? key,
    required this.day,
    required this.date,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(
              color: isSelected ? appcolor : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? appcolor.withOpacity(0.1) : Colors.transparent,
              border: isSelected ? Border.all(color: appcolor) : null,
            ),
            child: Center(
              child: Text(
                date.toString(),
                style: TextStyle(
                  color: isSelected ? appcolor : themeController.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}