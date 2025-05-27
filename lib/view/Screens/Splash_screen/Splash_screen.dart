import 'dart:io';

import 'package:fitlip_app/routes/App_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../controllers/profile_controller.dart';
import '../../../controllers/wardrobe_controller.dart';
import '../../../main.dart';
import '../../Utils/Colors.dart';
import '../../Utils/connection.dart';
import '../../Utils/globle_variable/globle.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ProfileController _profileController = ProfileController();
  final WardrobeController _wardrobeController = WardrobeController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    Future.delayed(const Duration(seconds: 2), () async {
      bool hasInternet = await checkInternetAndShowDialog(context);
      if (!hasInternet) return;



      await gettoken();
      if (token == "" || token == null) {
        bool shouldContinue = await _checkAppVersion();
        if (!shouldContinue) return;
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      } else {

        bool shouldContinue = await _checkAppVersion();
        if (!shouldContinue) return;
        await _loadUserProfile();
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
    });
  }

  Future<void> _loadUserProfile() async {
    await _profileController.getUserProfile();
    await _getUserInfoAndLoadItems();
  }

  Future<void> _getUserInfoAndLoadItems() async {
    try {
      await _wardrobeController.loadWardrobeItems();
      _updateSelectedItemsFromCurrentOutfit();
    } catch (e) {
      print("Error getting user info: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load wardrobe items'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateSelectedItemsFromCurrentOutfit() {
    if (_wardrobeController.shirtsNotifier.value.isNotEmpty) {
      selectedShirtId = _wardrobeController.shirtsNotifier.value.first.id;
    }
    if (_wardrobeController.pantsNotifier.value.isNotEmpty) {
      selectedPantId = _wardrobeController.pantsNotifier.value.first.id;
    }
    if (_wardrobeController.shoesNotifier.value.isNotEmpty) {
      selectedShoeId = _wardrobeController.shoesNotifier.value.first.id;
    }
    if (_wardrobeController.accessoriesNotifier.value.isNotEmpty) {
      selectedAccessoryId =
          _wardrobeController.accessoriesNotifier.value.first.id;
    }
  }

  Future<bool> _checkAppVersion() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}/app-settings/versions'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final info = await PackageInfo.fromPlatform();
        final currentVersion = info.version;
        print("current version is --------------");
print(info);
        if (Platform.isAndroid) {
          final deployedVersion = data['android_deployed_version'];
          if (_isVersionLower(currentVersion, deployedVersion)) {
            _showUpdateDialog(
              'A new version of the app is available. Please update to continue.',
              'https://play.google.com/store/apps/details?id=${info.packageName}',
            );
            return false;
          }
        } else if (Platform.isIOS) {
          final deployedVersion = data['ios_deployed_version'];
          if (_isVersionLower(currentVersion, deployedVersion)) {
            _showUpdateDialog(
              'A new version of the app is available. Please update to continue.',
              'https://apps.apple.com/app/idYOUR_APP_ID', // Replace with your App Store URL
            );
            return false;
          }
        }
      } else {
        print('Version check failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during version check: $e');
    }
    return true;
  }

  bool _isVersionLower(String current, String deployed) {
    List<int> currentParts =
    current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> deployedParts =
    deployed.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < deployedParts.length; i++) {
      if ((currentParts.length <= i ? 0 : currentParts[i]) <
          deployedParts[i]) {
        return true;
      } else if ((currentParts.length <= i ? 0 : currentParts[i]) >
          deployedParts[i]) {
        return false;
      }
    }
    return false;
  }

  void _showUpdateDialog(String message, String url) {
    showDialog(

      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Update Required",style: TextStyle(color: appcolor),),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () async {
              if (await canLaunch(url)) {
                await launch(url);
              }
            },
            child: Text("Update",style: TextStyle(color: appcolor),),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.white,
      body: Center(
        child: Image.asset(
          'assets/Images/splash_logo.png',
          scale: 4.5,
        ),
      ),
    );
  }
}
