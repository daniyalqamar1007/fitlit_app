// import 'package:fitlip_app/main.dart';
// import 'package:fitlip_app/routes/App_routes.dart';
// import 'package:fitlip_app/view/Utils/Constants.dart';
// import 'package:flutter/material.dart';
// import 'package:fitlip_app/controllers/profile_controller.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// import '../../../model/profile_model.dart';
// import '../../Utils/Colors.dart';
// import '../../Utils/globle_variable/globle.dart';
// import '../../Widgets/custom_switch.dart';
// import '../../Widgets/custom_tile.dart';
// import 'edit_profile.dart';
//
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({Key? key}) : super(key: key);
//
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//   bool isNotificationEnabled = true;
//   bool isDarkMode = false;
//   final ProfileController _profileController = ProfileController();
//
//   @override
//   void initState() {
//     super.initState();
//     if (_profileController.profileNotifier.value == null) {
//       _loadUserProfile();
//     }
//   }
//
//   // @override
//   // void dispose() {
//   //   _profileController.dispose();
//   //   super.dispose();
//   // }
//
//   Future<void> _loadUserProfile() async {
//     await _profileController.getUserProfile();
//   }
//
//   Future<void> _navigateToEditProfile() async {
//    Navigator.pushNamed(context, AppRoutes.editprofile);
//
//
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: themeController.white,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: themeController.white,
//         elevation: 0,
// leading: BackButton(color: appcolor,),
//         centerTitle: true,
//         title:  Text(
//           AppConstants.profile,
//           style: GoogleFonts.playfairDisplay(
//             fontWeight: FontWeight.bold,
//             color: Color(0xFFAA8A00),
//             fontSize: 20,
//           ),
//         ),
//       ),
//       body: ValueListenableBuilder<bool>(
//         valueListenable: _profileController.isLoadingNotifier,
//         builder: (context, isLoading, _) {
//           if (isLoading) {
//             return const Center(child: CircularProgressIndicator(color: Color(0xFFAA8A00)));
//           }
//
//           return ValueListenableBuilder<UserProfileModel?>(
//             valueListenable: _profileController.profileNotifier,
//             builder: (context, userProfile, _) {
//               if (userProfile == null) {
//                 return const Center(child: Text('Failed to load profile data'));
//               }
//
//               return Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//                     _buildProfileHeader(userProfile),
//                     const SizedBox(height: 20),
//                      Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         AppConstants.settings,
//                         style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     CustomSwitchTile(
//                       image: "assets/Icons/notification.png",
//                       title: AppConstants.notifications,
//                       value: isNotificationEnabled,
//                       onChanged: (val) => setState(() => isNotificationEnabled = val),
//                     ),
//                     // const SizedBox(height: 10),
//                     // CustomSwitchTile(
//                     //   icon: Icons.dark_mode_outlined,
//                     //   title: AppConstants.darkMode,
//                     //   value: isDarkMode,
//                     //   onChanged: (val) {
//                     //     setState(() {
//                     //       isDarkMode = val;
//                     //       themeController.toggleTheme();
//                     //     });
//                     //   },
//                     // ),
//                     // const SizedBox(height: 10),
//                     CustomListTile(
//                       image: "assets/Icons/language.png",
//                       title: AppConstants.language,
//                       onTap: () {},
//                     ),
//                     CustomListTile(
//                       image: "assets/Icons/policy.png",
//                       title: AppConstants.privacyPolicy,
//                       onTap: () {
//                         Navigator.pushNamed(context, AppRoutes.privacypolicy);
//                       },
//                     ),
//                     CustomListTile(
//                       icon: Icons.mail_outline,
//                       title: AppConstants.contactUs,
//                       onTap: () {},
//                     ),
//                     CustomListTile(
//                       icon: Icons.star_border,
//                       title: AppConstants.rateApp,
//                       onTap: () {},
//                     ),
//                     CustomListTile(
//                       icon: Icons.login_outlined,
//                       title: "Logout",
//                       onTap: () async {
//                         final shouldLogout = await showDialog<bool>(
//                           context: context,
//                           builder: (context) => AlertDialog(
//                             backgroundColor: Colors.white,
//                             title:  Text('Confirm Logout',style: GoogleFonts.poppins(color: appcolor),),
//                             content:  Text('Are you sure you want to logout?',style: GoogleFonts.poppins(color:appcolor)),
//                             actions: [
//                               TextButton(
//                                 onPressed: () => Navigator.pop(context, false),
//                                 child:  Text('Cancel',style: GoogleFonts.poppins(color: appcolor)),
//                               ),
//                               TextButton(
//                                 onPressed: () => Navigator.pop(context, true),
//                                 child: const Text('Logout', style: TextStyle(color: Colors.red)),
//                               ),
//                             ],
//                           ),
//                         );
//
//                         if (shouldLogout ?? false) {
//                           await remove();
//                           Navigator.pushReplacementNamed(context, AppRoutes.signin);
//                         }
//                       },
//                     ),
//
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//   void _showFullScreenImage() {
//     final userProfile = _profileController.profileNotifier.value;
//     if (userProfile == null || userProfile.profileImage.isEmpty) return;
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => Scaffold(
//           backgroundColor: Colors.black,
//           appBar: AppBar(
//             backgroundColor: Colors.transparent,
//             iconTheme: const IconThemeData(color: Colors.white),
//             elevation: 0,
//           ),
//           body: Center(
//             child: InteractiveViewer(
//               child: Image.network(
//                 userProfile.profileImage,
//                 fit: BoxFit.contain,
//                 errorBuilder: (context, error, stackTrace) {
//                   return Image.asset(
//                     'assets/Images/circle_image.png',
//                     fit: BoxFit.contain,
//                   );
//                 },
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProfileHeader(UserProfileModel userProfile) {
//     return Row(
//       children: [
//       GestureDetector(
//         onTap:_showFullScreenImage,
//         child: Container(
//         width: 60,
//         height: 60,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           border: Border.all(color: Colors.grey.withOpacity(0.2), width: 0.5),
//         ),
//         child: ClipOval(
//           child: userProfile.profileImage.isNotEmpty
//               ? Image.network(
//             userProfile.profileImage,
//             fit: BoxFit.cover,
//             alignment: const Alignment(0, -1), // Shift up to focus on face area
//             errorBuilder: (context, error, stackTrace) {
//               return Image.asset(
//                 'assets/Images/circle_image.png',
//                 fit: BoxFit.cover,
//               );
//             },
//           )
//               : Image.asset(
//             'assets/Images/circle_image.png',
//             fit: BoxFit.cover,
//           ),
//         ),
//             ),
//       ),      const SizedBox(width: 12),
//         Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               userProfile.name,
//               style:  GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//             Text(userProfile.email,style:  GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 10),)
//           ],
//         ),
//         const Spacer(),
//         GestureDetector(
//           onTap: _navigateToEditProfile,
//           child: Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.grey.withOpacity(0.5), width: 0.5)
//             ),
//             child: Image.asset('assets/Icons/edit_icon.png', scale: 4),
//           ),
//         )
//       ],
//     );
//   }
// }
import 'package:fitlip_app/main.dart';
import 'package:fitlip_app/routes/App_routes.dart';
import 'package:fitlip_app/view/Screens/Profile/setting/contact_us.dart';
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

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  bool isNotificationEnabled = true;
  bool isDarkMode = false;
  final ProfileController _profileController = ProfileController();
  late AnimationController _ratingAnimationController;
  late Animation<double> _starAnimation;
  bool _isRatingDialogLoading = false;
  int _selectedRating = 0;

  @override
  void initState() {
    super.initState();
    if (_profileController.profileNotifier.value == null) {
      _loadUserProfile();
    }
    _ratingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _starAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _ratingAnimationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _ratingAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    await _profileController.getUserProfile();
  }

  Future<void> _navigateToEditProfile() async {
    Navigator.pushNamed(context, AppRoutes.editprofile);
  }

  Future<void> _navigateToContactUs() async {
    final userProfile = _profileController.profileNotifier.value;
    if (userProfile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContactUsScreen(userProfile: userProfile),
        ),
      );
    } else {
      // Show error message if profile is not loaded
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile data not available. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRateAppDialog() {
    setState(() {
      _selectedRating = 0;
      _isRatingDialogLoading = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: appcolor.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.star,
                        size: 40,
                        color: appcolor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Rate Our App',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: appcolor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We\'d love to hear your feedback!\nHow would you rate your experience?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Star Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              _selectedRating = index + 1;
                            });
                            _ratingAnimationController.forward().then((_) {
                              _ratingAnimationController.reverse();
                            });
                          },
                          child: AnimatedBuilder(
                            animation: _starAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _selectedRating == index + 1 ? _starAnimation.value : 1.0,
                                child: Icon(
                                  Icons.star,
                                  size: 40,
                                  color: index < _selectedRating
                                      ? Colors.amber
                                      : Colors.grey.shade300,
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ),

                    if (_selectedRating > 0) ...[
                      const SizedBox(height: 20),
                      Text(
                        _getRatingText(_selectedRating),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: appcolor,
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),

                    // Action Buttons
                    if (_isRatingDialogLoading)
                      Container(
                        height: 50,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: appcolor,
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _selectedRating > 0 ? () async {
                                setDialogState(() {
                                  _isRatingDialogLoading = true;
                                });

                                // Simulate API call
                                await Future.delayed(const Duration(seconds: 2));

                                Navigator.pop(context);

                                // Show thank you message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Thank you for rating us $_selectedRating star${_selectedRating > 1 ? 's' : ''}!',
                                      style: GoogleFonts.poppins(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              } : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedRating > 0 ? appcolor : Colors.grey.shade300,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Submit',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedRating > 0 ? Colors.white : Colors.grey.shade500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return "We're sorry to hear that 😔";
      case 2:
        return "We'll work to improve 😐";
      case 3:
        return "Thanks for the feedback! 😊";
      case 4:
        return "Great! We're glad you like it 😄";
      case 5:
        return "Awesome! You're amazing! 🎉";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: themeController.white,
        elevation: 0,
        leading: BackButton(color: appcolor),
        centerTitle: true,
        title: Text(
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppConstants.settings,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomSwitchTile(
                      image: "assets/Icons/notification.png",
                      title: AppConstants.notifications,
                      value: isNotificationEnabled,
                      onChanged: (val) => setState(() => isNotificationEnabled = val),
                    ),
                    CustomListTile(
                      image: "assets/Icons/language.png",
                      title: AppConstants.language,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.language);
                      },
                    ),
                    CustomListTile(
                      image: "assets/Icons/policy.png",
                      title: AppConstants.privacyPolicy,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.privacypolicy);
                      },
                    ),
                    CustomListTile(
                      icon: Icons.mail_outline,
                      title: AppConstants.contactUs,
                      onTap: _navigateToContactUs,
                    ),
                    CustomListTile(
                      icon: Icons.star_border,
                      title: AppConstants.rateApp,
                      onTap: _showRateAppDialog,
                    ),

                    CustomListTile(
                      icon: Icons.login_outlined,
                      title: "Logout",
                      onTap: () async {
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.white,
                            title: Text('Confirm Logout', style: GoogleFonts.poppins(color: appcolor)),
                            content: Text('Are you sure you want to logout?', style: GoogleFonts.poppins(color: appcolor)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Cancel', style: GoogleFonts.poppins(color: appcolor)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Logout', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (shouldLogout ?? false) {
                          await remove();
                          Navigator.pushReplacementNamed(context, AppRoutes.signin);
                        }
                      },
                    ),
                    CustomListTile(
                      icon: Icons.delete_outline_outlined,

                      title: AppConstants.Delete,
                      onTap: (){

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

  void _showFullScreenImage() {
    final userProfile = _profileController.profileNotifier.value;
    if (userProfile == null || userProfile.profileImage.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(
                userProfile.profileImage,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/Images/circle_image.png',
                    fit: BoxFit.contain,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfileModel userProfile) {
    return Row(
      children: [
        GestureDetector(
          onTap: _showFullScreenImage,
          child: Container(
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
          ),
        ),
        const SizedBox(width: 12),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userProfile.name,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              userProfile.email,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 10),
            )
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: _navigateToEditProfile,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.withOpacity(0.5), width: 0.5)),
            child: Image.asset('assets/Icons/edit_icon.png', scale: 4),
          ),
        )
      ],
    );
  }
}