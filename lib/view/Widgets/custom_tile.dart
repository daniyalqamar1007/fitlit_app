import 'package:fitlip_app/main.dart';
import 'package:fitlip_app/view/Utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomListTile extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? image;
  final VoidCallback onTap;

  const CustomListTile({
    super.key,
    this.icon,
    this.image,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 1.0),
      leading: image == "" || image == null
          ? Icon(icon, color: appcolor)
          : Image.asset(
              image!,
              scale: 3.5,
            ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: themeController.black),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFFAA8A00)),
      onTap: onTap,
    );
  }
}
