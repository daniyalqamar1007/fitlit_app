
import 'package:flutter/cupertino.dart';
import '../view/Splash_screen/Splash_screen.dart';
class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static final Map<String, WidgetBuilder> routes = {
    splash: (context) =>  SplashScreen(),
  };
}