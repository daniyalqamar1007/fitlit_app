import 'package:fitlip_app/view/Utils/Colors.dart';
import 'package:fitlip_app/view/Utils/responsivness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';


class BrandingLaunchPage extends StatelessWidget {
  const BrandingLaunchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background with opacity
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Images/new.jpg'),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
          ),
          
          Center(
            child: SingleChildScrollView(
              padding: Responsive.allPadding(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo/Avatar
                  Container(
                    width: Responsive.width(120),
                    height: Responsive.height(120),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFB8860B),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: appcolor.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/Images/circle_image.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: Responsive.height(30)),
                  
                  // Coming Soon Text
                  Text(
                    'Coming Soon',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.fontSize(28),
                      fontWeight: FontWeight.w700,
                      color: appcolor,
                      letterSpacing: 1.5,
                    ),
                  ),
                  
                  SizedBox(height: Responsive.height(15)),
                  
                  // App Name
                  Text(
                    'FitLit',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: Responsive.fontSize(36),
                      fontWeight: FontWeight.w800,
                      color: appcolor,
                    ),
                  ),
                  
                  SizedBox(height: Responsive.height(30)),
                  
                  // Loading Animation
                  LoadingAnimationWidget.fourRotatingDots(
                    color: appcolor,
                    size: Responsive.width(40),
                  ),
                  
                  SizedBox(height: Responsive.height(40)),
                  
                  // Version Info
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.width(20), vertical: Responsive.height(10)),
                    decoration: BoxDecoration(
                      color: appcolor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(Responsive.radius(20)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'We are launching our first version',
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.fontSize(16),
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: Responsive.height(10)),
                        Text(
                          'v1.0.0',
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.fontSize(14),
                            color: appcolor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: Responsive.height(30)),
                  
                  // Features List
                  Column(
                    children: [
                      _buildFeatureItem(Icons.style, 'Fashion Outfits'),
                      _buildFeatureItem(Icons.calendar_today, 'Daily Style Tracking'),
                      _buildFeatureItem(Icons.people, 'Social Community'),
                      _buildFeatureItem(Icons.thumb_up, 'Style Recommendations'),
                    ],
                  ),
                  
                  SizedBox(height: Responsive.height(40)),
                  
                  // Contact/Subscribe Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appcolor,
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.width(30),
                        vertical: Responsive.height(15),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Responsive.radius(12)),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      // Handle subscription
                    },
                    child: Text(
                      'Notify Me When Launched',
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.fontSize(16),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive.height(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: appcolor,
            size: Responsive.fontSize(20),
          ),
          SizedBox(width: Responsive.width(10)),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: Responsive.fontSize(16),
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}