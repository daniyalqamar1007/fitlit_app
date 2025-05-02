
import 'package:flutter/cupertino.dart';
import '../view/Screens/Auth/signup_screen.dart';
import '../view/Screens/Onboarding_screen/Onboarding_screen.dart';
import '../view/Screens/Splash_screen/Splash_screen.dart';
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String signup = '/signup';
  static final Map<String, WidgetBuilder> routes = {
    splash: (context) =>  SplashScreen(),
    onboarding: (context) =>  OnboardingScreen(),
    signup: (context) =>  SignUpScreen(),
  };
}
