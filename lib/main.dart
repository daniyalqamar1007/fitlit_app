import 'package:fitlip_app/routes/App_routes.dart';
import 'package:fitlip_app/view/Screens/Splash_screen/Splash_screen.dart';
import 'package:fitlip_app/view/Utils/Colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'controllers/themecontroller.dart';
final themeController = ThemeController();
Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      systemNavigationBarColor: Colors.brown,
    ),
  );
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeController.isDark,
      builder: (context, isDarkMode, _) {
        return SafeArea(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'FitLip App',
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: themeController.black,
                brightness: Brightness.light,
                primary: themeController.black,
              ),
              scaffoldBackgroundColor: themeController.white,
              appBarTheme: AppBarTheme(
                elevation: 0,
                centerTitle: true,
                backgroundColor: themeController.black,
                foregroundColor: themeController.white,
              ),
              textTheme: TextTheme(
                bodyMedium: TextStyle(color: themeController.black),
              ),
              inputDecorationTheme: InputDecorationTheme( 
                hintStyle: TextStyle(color: themeController.hintTextColor),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: themeController.appColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: themeController.appColor, width: 2),
                ),
              ),
            ),
            initialRoute: AppRoutes.dashboard,
            onGenerateInitialRoutes: (initialRoute) {
              if (AppRoutes.routes.containsKey(initialRoute)) {
                return [
                  MaterialPageRoute(builder: AppRoutes.routes[initialRoute]!)
                ];
              }
              return [
                MaterialPageRoute(builder: (_) => SplashScreen())
              ];
            },
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  body: Center(
                    child: Text(
                      'Page not found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: themeController.black,
                      ),
                    ),
                  ),
                ),
              );
            },
            routes: AppRoutes.routes,
          ),
        );
      },
    );
  }
}



