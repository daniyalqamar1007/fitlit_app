import 'package:flutter/material.dart';
import '../../Utils/Colors.dart';
import 'hompage.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    WardrobeScreen(),
    Center(child: Text("Profile")),
    Center(child: Text("Wallet")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }

  Widget _buildCustomBottomNavBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, 'assets/Icons/home_icon.png', 'Wardrobe'),
          _buildNavItem(1, 'assets/Icons/profile.png', 'Profile'),
          _buildNavItem(2, 'assets/Icons/wallet.png', 'Wallet'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String imagePath, String label) {
    final isSelected = index == _currentIndex;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        width: 70,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20))
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Selected item with blue circle background
            if (isSelected)
              Container(

                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20))
                ),
                child: Center(
                  child: Image.asset(
                    imagePath,
                    width: 32,
                    height: 32,
                    color: appcolor,
                  ),
                ),
              )
            else // Unselected item
              Image.asset(
                imagePath,
                width: 24,
                height: 24,
                color:appcolor,
              ),


          ],
        ),
      ),
    );
  }
}