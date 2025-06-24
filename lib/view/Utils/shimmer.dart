import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitlip_app/view/Utils/Colors.dart';
import '../Utils/responsivness.dart';

class UserSuggestionCardShimmer extends StatelessWidget {
  const UserSuggestionCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Responsive.radius(12)),
      ),
      child: Container(
        width: Responsive.width(150),
        height: Responsive.height(200),
        margin: EdgeInsets.symmetric(
          horizontal: Responsive.width(10),
          vertical: Responsive.height(5),
        ),
        padding: EdgeInsets.all(Responsive.width(8)),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Circular shimmer for profile image
              Container(
                width: Responsive.width(90),
                height: Responsive.width(90),
                margin: EdgeInsets.only(top: Responsive.height(10)),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[400],
                  border: Border.all(color: appcolor, width: 2),
                ),
              ),

              // Rectangular shimmer for name
              Container(
                height: Responsive.height(16),
                width: Responsive.width(80),
                margin: EdgeInsets.only(top: Responsive.height(10)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[400],
                ),
              ),

              // Rectangular shimmer for follow button
              Container(
                margin: EdgeInsets.only(bottom: Responsive.height(10)),
                width: double.infinity,
                height: Responsive.height(36),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(Responsive.radius(8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
