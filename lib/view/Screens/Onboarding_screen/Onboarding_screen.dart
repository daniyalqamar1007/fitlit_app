import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../routes/App_routes.dart';
import '../../Utils/Colors.dart';
import '../../Utils/Constants.dart';

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
      titleColor: Color(0xff272727),
      highlightColor: appcolor,
      image: "assets/Images/onboard1.png", // Use your full-screen image here
    ),
    OnboardingPage(
      title: "Organize. Create. Slay Every Day.",
      description: "Snap your outfits, build your dream closet, and plan every look with ease. Own your style journey — one outfit at a time.",
      highlightedText: "Every Day",
      titleColor: Color(0xff272727),
      highlightColor: appcolor,
      image: "assets/Images/onboard2.png", // Use your full-screen image here
    ),
    OnboardingPage(
      title: "Your Style, Your Closet.",
      description: "Capture your wardrobe, create stunning outfits, and plan your style effortlessly. Stay organized, inspired your closet, your way.",
      highlightedText: "Closet",
      titleColor: Color(0xff272727),
      highlightColor: appcolor,
      image: "assets/Images/onboard3.png", // Use your full-screen image here
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
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        onboardingData.length,
            (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == index ? 30 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: _currentPage == index
                  ? appcolor
                  : Colors.grey.shade300,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: onboardingData.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                return _buildOnboardingPage(onboardingData[index]);
              },
            ),
          ),

          // Bottom controls in a row - positioned at bottom
          Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Page indicator
                Padding(
                    padding:EdgeInsets.only(left: 20),
                    child: _buildPageIndicator()),

                // Next button
                _buildNextButton(),
              ],
            ),
          ),
        ],
      )
    );
  }

  Widget _buildNextButton() {
    return GestureDetector(
      onTap: _nextPage,
      child: Container(
         padding: AppConstants.buttonPadding,
        decoration: BoxDecoration(
          color: appcolor, // Gold color button
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), // Rounded top-left corner
            // topRight: Radius.circular(8),

          ),

        ),
        child: Material(
          color: Colors.transparent,
          child: Center(
            child:Text("Next",style: TextStyle(color: Colors.white,fontSize: 22,fontWeight: FontWeight.w400),)
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Full Image (takes about 60% of the screen)
          Expanded(
            flex: 7,
            child: Container(
              // margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(

                // borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage(page.image),
                  fit: BoxFit.fitWidth,
                ),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black.withOpacity(0.1),
                //     blurRadius: 10,
                //     offset: Offset(0, 4),
                //   ),
                // ],
              ),
            ),
          ),

          // Content below image (40% of screen)
          Expanded(
            flex: 4,
            child: Padding(
              padding:  EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title with highlighted part
                  _buildHighlightedTitle(page),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    page.description,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Empty space for the bottom controls

        ],
      ),
    );
  }

  Widget _buildHighlightedTitle(OnboardingPage page) {
    // Split the title into parts based on the highlighted text
    final titleParts = page.title.split(page.highlightedText);

    return RichText(
      text: TextSpan(
        style: GoogleFonts.playfairDisplay(
          fontSize: 38,
          fontWeight: FontWeight.w700,
          color: page.titleColor,

        ),
        children: [
          TextSpan(text: titleParts[0]),
          TextSpan(
            text: page.highlightedText,
            style: GoogleFonts.playfair(
              fontSize: 40,
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

// Enhanced OnboardingPage model
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