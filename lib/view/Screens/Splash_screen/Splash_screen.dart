import 'package:fitlip_app/routes/App_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../controllers/profile_controller.dart';
import '../../../controllers/wardrobe_controller.dart';
import '../../../main.dart';
import '../../Utils/Colors.dart';
import '../../Utils/globle_variable/globle.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ProfileController _profileController = ProfileController();
  final WardrobeController _wardrobeController = WardrobeController();
  WardrobeController controller=WardrobeController();
  String already_login="";
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    Future.delayed(const Duration(seconds: 3), () async {
      await gettoken();
      print(token);
      if (token == "" || token == null) {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      } else {
        _loadUserProfile();
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
    });
  }

  Future<void> _loadUserProfile() async {
    // Get user profile data
    await _profileController.getUserProfile();

    _getUserInfoAndLoadItems();
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
    print("coming2");
    // Update selected IDs based on first items in each category
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
      selectedAccessoryId = _wardrobeController.accessoriesNotifier.value.first.id;
    }
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
        child: Image.asset('assets/Images/splash_logo.png',scale: 4.5,),
      ),
    );
  }
}
