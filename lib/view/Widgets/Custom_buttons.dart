import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final double? elevation;
  final double? width;
  final double? height;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.color,
    this.textColor,
    this.padding,
    this.borderRadius,
    this.elevation,
    this.width,
    this.height,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.colorScheme.primary;
    final buttonTextColor = textColor ?? Colors.white;

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50,
      child: isOutlined
          ? OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: buttonColor,
          side: BorderSide(color: buttonColor),
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
        ),
        child: child,
      )
          : FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: buttonTextColor,
          elevation: elevation ?? 0,
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
        ),
        child: child,
      ),
    );
  }
}