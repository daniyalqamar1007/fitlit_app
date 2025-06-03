import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showAppSnackBar(BuildContext context, String message, {Color backgroundColor = Colors.black,Color textcolor = Colors.white}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.white,

          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: backgroundColor,
      duration: Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}
