import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../main.dart';
import '../../../routes/App_routes.dart';
import '../../Utils/Colors.dart';
import '../../Utils/Constants.dart';
import '../../Utils/responsivness.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> onboardingData = [
    OnboardingPage(
      title: "Fashion that speaks for itself",
      description: "Indulge in a wardrobe that effortlessly blends sophistication with comfort, ensuring every outfit resonates with your unique flair.",
      highlightedText: "itself",
      titleColor: const Color(0xff272727),
      highlightColor: appcolor,
      image: "assets/Images/onboard1.png",
    ),
    OnboardingPage(
      title: "Organize. Create. Slay Every Day.",
      description: "Snap your outfits, build your dream closet, and plan every look with ease. Own your style journey — one outfit at a time.",
      highlightedText: "Every Day",
      titleColor: const Color(0xff272727),
      highlightColor: appcolor,
      image: "assets/Images/onboard2.png",
    ),
    OnboardingPage(
      title: "Your Style, Your Closet.",
      description: "Capture your wardrobe, create stunning outfits, and plan your style effortlessly. Stay organized, inspired your closet, your way.",
      highlightedText: "Closet",
      titleColor: const Color(0xff272727),
      highlightColor: appcolor,
      image: "assets/Images/onboard3.png",
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.signin);
    }
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        onboardingData.length,
            (index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: Responsive.width(4)),
            width: _currentPage == index ? Responsive.width(25) : Responsive.width(8),
            height: Responsive.height(7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Responsive.radius(4)),
              color: _currentPage == index ? appcolor : Colors.grey.shade300,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: PageView.builder(
              controller: _pageController,
              itemCount: onboardingData.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                return _buildOnboardingPage(onboardingData[index]);
              },
            ),
          ),
          Container(
            color: themeController.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: Responsive.width(20)),
                  child: _buildPageIndicator(),
                ),
                _buildNextButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return GestureDetector(
      onTap: _nextPage,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppConstants.buttonPadding.vertical.h,
          horizontal: AppConstants.buttonPadding.horizontal.w,
        ),
        decoration: BoxDecoration(
          color: appcolor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Responsive.radius(25)),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Text(
              "Next",
              style: TextStyle(
                color: themeController.white,
                fontSize: Responsive.fontSize(22),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    return Container(
      color: themeController.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 11,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(page.image),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: Responsive.horizontalPadding(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHighlightedTitle(page),
                  SizedBox(height: Responsive.height(4)),
                  Text(
                    page.description,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.fontSize(13),
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                      height: 1.5,
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

  Widget _buildHighlightedTitle(OnboardingPage page) {
    final titleParts = page.title.split(page.highlightedText);

    return RichText(
      text: TextSpan(
        style: GoogleFonts.playfairDisplay(
          fontSize: Responsive.fontSize(38),
          fontWeight: FontWeight.w700,
          color: page.titleColor,
          height: 0.99
        ),
        children: [
          TextSpan(text: titleParts[0]),
          TextSpan(
            text: page.highlightedText,
            style: GoogleFonts.playfair(
              fontSize: Responsive.fontSize(40),
              fontWeight: FontWeight.w700,
              color: page.highlightColor,
            ),
          ),
          if (titleParts.length > 1) TextSpan(text: titleParts[1]),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String highlightedText;
  final Color titleColor;
  final Color highlightColor;
  final String image;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.highlightedText,
    required this.titleColor,
    required this.highlightColor,
    required this.image,
  });
}
