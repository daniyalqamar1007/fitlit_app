
import 'package:flutter/cupertino.dart';
import '../view/Screens/Onboarding_screen/Onboarding_screen.dart';
import '../view/Screens/Splash_screen/Splash_screen.dart';
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static final Map<String, WidgetBuilder> routes = {
    splash: (context) =>  SplashScreen(),
    onboarding: (context) =>  OnboardingScreen(),
  };
}
