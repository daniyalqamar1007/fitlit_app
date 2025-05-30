import 'package:fitlip_app/routes/App_routes.dart';
import 'package:fitlip_app/view/Screens/Splash_screen/Splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // generated file
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/themecontroller.dart';
final themeController = ThemeController();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? languageCode = prefs.getString('language_code') ?? 'en';

  runApp(MyApp(locale: Locale(languageCode)));
}

class MyApp extends StatefulWidget {
  final Locale locale;

  const MyApp({super.key, required this.locale});

  @override
  State<MyApp> createState() => _MyAppState();
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;
  @override
  void initState() {
    super.initState();
    _locale = widget.locale;
  }

  void setLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: themeController.isDark,
          builder: (context, isDarkMode, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'FitLip App',
              locale: _locale,
              supportedLocales: const [
                Locale('en'),
                Locale('es'),
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
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
              ),
              initialRoute: AppRoutes.splash,
              onGenerateInitialRoutes: (initialRoute) {
                if (AppRoutes.routes.containsKey(initialRoute)) {
                  return [
                    MaterialPageRoute(builder: AppRoutes.routes[initialRoute]!)
                  ];
                }
                return [MaterialPageRoute(builder: (_) => const SplashScreen())];
              },
              routes: AppRoutes.routes,
            );
          },
        );
      },
    );
  }
}
