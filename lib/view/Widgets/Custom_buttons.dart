import 'package:flutter/material.dart';
import '../../main.dart';
import '../Utils/Colors.dart';
import '../Utils/Constants.dart';


class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? color;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? appcolor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          ),
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
        ),
        child: isLoading
            ? const CircularProgressIndicator()
            : Text(text, style: AppTextStyles.button.copyWith(color: themeController.white)),
      ),
    );
  }
}