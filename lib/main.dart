import 'package:fitlip_app/routes/App_routes.dart';
import 'package:fitlip_app/view/Screens/Splash_screen/Splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import 'controllers/themecontroller.dart';
import 'l10n/app_localizations.dart';
// Import optimization utilities
import 'utils/performance_monitoring.dart';
import 'utils/memory_optimization.dart';
import 'utils/network_optimization.dart';
import 'utils/image_optimization.dart';
import 'utils/deployment_verification.dart';

final themeController = ThemeController();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize optimization systems
  await _initializeOptimizations();

  // Run deployment verification in debug mode
  if (const bool.fromEnvironment('dart.vm.product') == false) {
    await _runDeploymentVerification();
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('es')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

/// Initialize all optimization systems
Future<void> _initializeOptimizations() async {
  try {
    // Start performance monitoring
    PerformanceMonitor().startMonitoring();
    
    // Start memory monitoring
    MemoryOptimization.startMemoryMonitoring();
    
    // Initialize network optimization
    NetworkOptimization().initialize();
    
    // Schedule image cache cleanup
    MemoryOptimization.scheduleImageCacheCleanup();
    
    debugPrint('✅ All optimization systems initialized');
  } catch (e) {
    debugPrint('❌ Error initializing optimizations: $e');
  }
}

/// Run deployment verification in debug mode
Future<void> _runDeploymentVerification() async {
  try {
    debugPrint('🔍 Running deployment verification...');
    final isReady = await DeploymentVerification.quickDeploymentCheck();
    
    if (isReady) {
      debugPrint('✅ App ready for deployment');
    } else {
      debugPrint('❌ App needs fixes before deployment');
    }
  } catch (e) {
    debugPrint('⚠️ Deployment verification error: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    
    // Preload critical images
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ImageOptimization.preloadCriticalImages(context);
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
              localizationsDelegates: [
                const AppLocalizationsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                ...context.localizationDelegates,
              ],
              supportedLocales: context.supportedLocales,
              locale: context.locale,
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
  
  @override
  void dispose() {
    // Clean up optimization systems on app disposal
    PerformanceMonitor().stopMonitoring();
    MemoryOptimization.stopMemoryMonitoring();
    MemoryOptimization.disposeAll();
    super.dispose();
  }
}
