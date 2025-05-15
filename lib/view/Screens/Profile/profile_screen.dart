import 'package:fitlip_app/main.dart';
import 'package:fitlip_app/routes/App_routes.dart';
import 'package:fitlip_app/view/Utils/Constants.dart';
import 'package:flutter/material.dart';

import '../../Utils/Colors.dart';
import '../../Utils/globle_variable/globle.dart';
import '../../Widgets/custom_switch.dart';
import '../../Widgets/custom_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isNotificationEnabled = true;
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.white,
      appBar: AppBar(
        backgroundColor: themeController.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFFAA8A00)),
        centerTitle: true,
        title: const Text(
          AppConstants.profile,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFAA8A00),
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppConstants.settings,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            CustomSwitchTile(
              // icon: Icons.notifications_none,
              image: "assets/Icons/notification.png",
              title: AppConstants.notifications,
              value: isNotificationEnabled,
              onChanged: (val) => setState(() => isNotificationEnabled = val),
            ),
            const SizedBox(height: 10),
            CustomSwitchTile(
              icon: Icons.dark_mode_outlined,
              title: AppConstants.darkMode,
              value: isDarkMode,
              onChanged: (val){
                setState(() {
                  isDarkMode = val;          // this updates the switch UI
                  themeController.toggleTheme();  // this updates the app theme
                });


              },
            ),
            const SizedBox(height: 10),
            CustomListTile(
              // icon: Icons.language,
              image: "assets/Icons/language.png",
              title: AppConstants.language,
              onTap: () {},
            ),
            CustomListTile(
              image: "assets/Icons/policy.png",
              title: AppConstants.privacyPolicy,
              onTap: () {},
            ),
            CustomListTile(
              icon: Icons.mail_outline,
              title: AppConstants.contactUs,
              onTap: () {},
            ),
            CustomListTile(
              icon: Icons.star_border,
              title: AppConstants.rateApp,
              onTap: () {},
            ),
            CustomListTile(
              icon: Icons.login_outlined,
              title: "logout",
              onTap: () async {
await remove();
Navigator.pushReplacementNamed(context, AppRoutes.signin);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage('assets/Images/circle_image.png'), // update path
        ),
        const SizedBox(width: 12),
        const Text(
          'Johnny Cage',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const Spacer(),
       Container(
         padding: EdgeInsets.all(10),
         decoration: BoxDecoration(
           shape: BoxShape.circle,
           border: Border.all(color: Colors.grey.withOpacity(0.5),width: 0.5)
         ),
         child: Image.asset('assets/Icons/edit_icon.png',scale: 4,),
       )
      ],
    );
  }
}
