import 'package:fitlip_app/routes/App_routes.dart';
import 'package:fitlip_app/view/Splash_screen/Splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black54,
      systemNavigationBarColor: Colors.brown,
    ),
  );

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitLip App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.light,
          primary: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),

      initialRoute: AppRoutes.splash, // Make sure this matches your route name
      onGenerateInitialRoutes: (initialRoute) {
        if (AppRoutes.routes.containsKey(initialRoute)) {
          return [MaterialPageRoute(builder: AppRoutes.routes[initialRoute]!)];
        }
        return [MaterialPageRoute(builder: (_) => const SplashScreen())];
      },
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Page not found',style:TextStyle(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.black),)),
          ),
        );
      },
      routes: AppRoutes.routes,
    );
  }
}


