import 'package:fitlip_app/view/Utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';

class CustomSwitchTile extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? image;
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitchTile({
    super.key,
    this.icon,
    required this.title,
    this.image,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: image == "" || image == null
          ? Icon(
              icon,
              color: appcolor,
              size: 25,
            )
          : Image.asset(
              image!,
              scale: 3.5,
            ),
      title: Text(title,
          style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: themeController.black)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: themeController.white,
        activeTrackColor: appcolor,
        inactiveThumbColor: appcolor,
        inactiveTrackColor: themeController.white,
      ),
    );
  }
}
