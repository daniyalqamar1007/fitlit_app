import 'dart:math';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:fitlip_app/view/Screens/Profile/profile_screen.dart';
import 'package:flutter/material.dart';
import '../../../main.dart';
import '../../Utils/Colors.dart';
import 'hompage.dart';
import 'package:fitlip_app/view/Screens/Dashboard/social_media.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    WardrobeScreen(),
    Center(
      child: Text("Branding"),
    ),
    SocialMediaProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    double iconSize =
        MediaQuery.of(context).size.width * 0.06; // responsive icon size
    double navBarHeight = min(MediaQuery.of(context).size.height * 0.08, 75.0);
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: navBarHeight,
        backgroundColor: Colors.white,
        color: appcolor,
        buttonBackgroundColor: appcolor,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 300),
        items: <Widget>[
          Image.asset(
            'assets/Icons/home_icon.png',
            width: iconSize,
            height: iconSize,
            color: Colors.white,
          ),
          Image.asset(
            'assets/Icons/profile.png',
            width: iconSize,
            color: Colors.white,
            height: iconSize,
          ),
          Image.asset(
            'assets/Icons/wallet.png',
            width: iconSize,
            color: Colors.white,
            height: iconSize,
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
