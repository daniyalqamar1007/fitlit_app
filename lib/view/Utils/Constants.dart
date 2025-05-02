import 'package:fitlip_app/view/Utils/Colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
class AppConstants {
  static const List<String> onboardingImageUrls = [
    'https://your-bucket.s3.amazonaws.com/onboarding1.jpg',
    'https://your-bucket.s3.amazonaws.com/onboarding2.jpg',
    'https://your-bucket.s3.amazonaws.com/onboarding3.jpg',
  ];
  static const List<Map<String, String>> onboardingData = [
    {
      'title': 'Fashion that speaks for itself',
      'description': 'Includes in a wardrobe that effortlessly blends sophistication with comfort...',
    },
    {
      'title': 'Organize. Create. Slay Every Day.',
      'description': 'Snap your outfits, build your dream closet, and plan every look with ease...',
    },
    {
      'title': 'Your Style, Your Closet.',
      'description': 'Capture your wardrobe, create stunning outfits, and plan your style effortlessly...',
    },
  ];
  static const double buttonHeight = 50;
  static const double buttonBorderRadius = 8;
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: 44, vertical: 12);
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 24);
  static const double indicatorSize = 8;
  static const double indicatorSpacing = 4;
}
class AppDimensions {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 14.0;
  static const double buttonHeight = 50.0;
}
class AppTextStyles {
  static TextStyle get headlineSmall => GoogleFonts.playfairDisplay(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: appcolor,
  );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: appcolor,
  );

  static TextStyle get button => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}
