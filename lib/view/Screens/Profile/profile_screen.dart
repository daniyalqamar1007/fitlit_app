import 'package:fitlip_app/main.dart';
import 'package:fitlip_app/routes/App_routes.dart';
import 'package:fitlip_app/view/Utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:fitlip_app/controllers/profile_controller.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../model/profile_model.dart';
import '../../Utils/Colors.dart';
import '../../Utils/globle_variable/globle.dart';
import '../../Widgets/custom_switch.dart';
import '../../Widgets/custom_tile.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isNotificationEnabled = true;
  bool isDarkMode = false;
  final ProfileController _profileController = ProfileController();

  @override
  void initState() {
    super.initState();
    if (_profileController.profileNotifier.value == null) {
      _loadUserProfile();
    }
  }

  // @override
  // void dispose() {
  //   _profileController.dispose();
  //   super.dispose();
  // }

  Future<void> _loadUserProfile() async {
    await _profileController.getUserProfile();
  }

  Future<void> _navigateToEditProfile() async {
   Navigator.pushNamed(context, AppRoutes.editprofile);


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.white,
      appBar: AppBar(
        backgroundColor: themeController.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFFAA8A00)),
        centerTitle: true,
        title:  Text(
          AppConstants.profile,
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: Color(0xFFAA8A00),
            fontSize: 20,
          ),
        ),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _profileController.isLoadingNotifier,
        builder: (context, isLoading, _) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFAA8A00)));
          }

          return ValueListenableBuilder<UserProfileModel?>(
            valueListenable: _profileController.profileNotifier,
            builder: (context, userProfile, _) {
              if (userProfile == null) {
                return const Center(child: Text('Failed to load profile data'));
              }

              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildProfileHeader(userProfile),
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
                      onChanged: (val) {
                        setState(() {
                          isDarkMode = val;
                          themeController.toggleTheme();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomListTile(
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
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserProfileModel userProfile) {
    return Row(
      children: [
      Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 0.5),
      ),
      child: ClipOval(
        child: userProfile.profileImage.isNotEmpty
            ? Image.network(
          userProfile.profileImage,
          fit: BoxFit.cover,
          alignment: const Alignment(0, -1), // Shift up to focus on face area
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/Images/circle_image.png',
              fit: BoxFit.cover,
            );
          },
        )
            : Image.asset(
          'assets/Images/circle_image.png',
          fit: BoxFit.cover,
        ),
      ),
    ),      const SizedBox(width: 12),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userProfile.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(userProfile.email,style:  GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 10),)
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: _navigateToEditProfile,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.withOpacity(0.5), width: 0.5)
            ),
            child: Image.asset('assets/Icons/edit_icon.png', scale: 4),
          ),
        )
      ],
    );
  }
}