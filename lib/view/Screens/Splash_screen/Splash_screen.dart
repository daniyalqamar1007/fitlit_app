import 'package:fitlip_app/routes/App_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../main.dart';
import '../../Utils/Colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String already_login="";
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    check();

    Future.delayed(const Duration(seconds: 3), () {
      if(already_login==null||already_login==""){
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);}
      else{
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
    });}


  Future<void> check()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    already_login = prefs.getString('token')??"";
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
