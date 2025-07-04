import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';

class Responsive {
  static double fontSize(double size) => size.sp;
  static double width(double size) => size.w;
  static double height(double size) => size.h;
  static double radius(double size) => size.r;

  static EdgeInsets horizontalPadding(double value) => EdgeInsets.symmetric(horizontal: value.w);
  static EdgeInsets verticalPadding(double value) => EdgeInsets.symmetric(vertical: value.h);
  static EdgeInsets allPadding(double value) => EdgeInsets.all(value.r);
}
