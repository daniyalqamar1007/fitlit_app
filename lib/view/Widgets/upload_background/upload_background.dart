  import 'dart:ui';

  import 'package:flutter/cupertino.dart';
  import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';

  import '../../Utils/responsivness.dart';

  class UploadBackgroundButton extends StatelessWidget {
    final VoidCallback onPressed;
    final Color appColor;

    const UploadBackgroundButton({
      Key? key,
      required this.onPressed,
      required this.appColor,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return SizedBox(
        width: Responsive.width(160),
        height: Responsive.height(40),
        child: RawMaterialButton(
          onPressed: onPressed,
          fillColor: appColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Responsive.radius(20)),
          ),
          child: Padding(
            padding: Responsive.horizontalPadding(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wallpaper,
                  color: Colors.white,
                  size: Responsive.fontSize(18),
                ),
                SizedBox(width: Responsive.width(8)),
                Text(
                  "Background",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: Responsive.fontSize(12),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }