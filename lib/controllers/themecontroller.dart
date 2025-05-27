import 'package:flutter/material.dart';

class ThemeController {
  // Notifies the app to rebuild when theme changes
  final ValueNotifier<bool> isDark = ValueNotifier(false);

  void toggleTheme() {
    isDark.value = !isDark.value;
  }

  // Define themed colors
  Color get white => isDark.value ? Colors.black : Colors.white;
  Color get black => isDark.value ? Colors.white : Colors.black;
  Color get appColor => const Color(0xff9F7B01);
  Color get accent => Colors.blue;
  Color get textSecondary => Colors.grey;
  Color get error => Colors.red;
  Color get hintTextColor => isDark.value ? Color(0x80CCCCCC) : Colors.white;
}
