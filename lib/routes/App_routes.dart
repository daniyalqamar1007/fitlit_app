import 'package:fitlip_app/view/Screens/Auth/Forgot_password/forgot_screen.dart';
import 'package:fitlip_app/view/Screens/Auth/Forgot_password/new_password.dart';
import 'package:fitlip_app/view/Screens/Auth/Otp/otp_screen.dart';
import 'package:fitlip_app/view/Screens/Auth/sign_in.dart';
import 'package:fitlip_app/view/Screens/Dashboard/bottomnavbar.dart';
import 'package:fitlip_app/view/Screens/Profile/edit_profile.dart';
import 'package:fitlip_app/view/Screens/Profile/profile_screen.dart';
import 'package:fitlip_app/view/Screens/Profile/setting/contact_us.dart';
import 'package:fitlip_app/view/Screens/Profile/setting/language_screen.dart';
import 'package:flutter/cupertino.dart';
import '../controllers/auth_controller.dart';
import '../view/Screens/Auth/signup_screen.dart';
import '../view/Screens/Dashboard/social_media.dart';
import '../view/Screens/Dashboard/social_media/add_new_friend.dart';
import '../view/Screens/Onboarding_screen/Onboarding_screen.dart';
import '../view/Screens/Profile/setting/privacypolicy.dart';
import '../view/Screens/Splash_screen/Splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String signup = '/signup';
  static const String signin = '/signin';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String forgot = '/forgot';
  static const String otp = '/otp';
  static const String newpassword = '/newpassword';
  static const String social = '/social';
  static const String privacypolicy = '/privacypolicy';
  static const String editprofile = '/edit';
  static const String language = '/language';
  static const String addfriend = '/addfriend';

  static const String contact = '/contact';
  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => SplashScreen(),
    onboarding: (context) => OnboardingScreen(),
    signup: (context) => SignUpScreen(),
    signin: (context) => SignInScreen(),
    dashboard: (context) => HomeScreen(),
    profile: (context) => ProfileScreen(),
    social: (context) => SocialMediaProfile(),
    forgot: (context) => ForgotPasswordScreen(),
    contact: (context) => ContactUsScreen(),
    language: (context) => LanguageScreen(),
    privacypolicy: (context) => PrivacyPolicyScreen(),
    editprofile: (context) => EditProfileScreen(),
    addfriend: (context) => AddFriendsPage(),
    newpassword: (context) => NewPasswordScreen(
          email: "dhsgfjh@",

        ),
  };
}
