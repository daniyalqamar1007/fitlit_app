import 'dart:convert';

import 'package:fitlip_app/main.dart';
import 'package:fitlip_app/routes/App_routes.dart';
import 'package:fitlip_app/view/Screens/Profile/setting/contact_us.dart';
import 'package:fitlip_app/view/Utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:fitlip_app/controllers/profile_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../model/profile_model.dart';
import '../../Utils/Colors.dart';
import '../../Utils/globle_variable/globle.dart';
import '../../Widgets/custom_message.dart';
import '../../Widgets/custom_switch.dart';
import '../../Widgets/custom_tile.dart';
import 'edit_profile.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  bool isNotificationEnabled = true;
  bool isDarkMode = false;
  final ProfileController _profileController = ProfileController();
  late AnimationController _ratingAnimationController;
  late Animation<double> _starAnimation;

  final ValueNotifier<bool> _isRatingDialogLoadingNotifier =
      ValueNotifier<bool>(false);
  final ValueNotifier<int> _selectedRatingNotifier = ValueNotifier<int>(0);
  final ValueNotifier<String?> _ratingErrorNotifier =
      ValueNotifier<String?>(null);

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
      CurvedAnimation(
          parent: _ratingAnimationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _ratingAnimationController.dispose();
    _isRatingDialogLoadingNotifier.dispose();
    _selectedRatingNotifier.dispose();
    _ratingErrorNotifier.dispose();
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

  Future<void> _submitRating(int rating) async {
    _isRatingDialogLoadingNotifier.value = true;
    _ratingErrorNotifier.value = null;

    try {
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/rating'), // Replace with your actual API endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'rating': rating,
          'message': _getRatingMessage(rating),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // Check for success in response
        if (responseData['success'] == true ||
            responseData['status'] == 'success') {
          // Rating submitted successfully
          Navigator.pop(context);
          showAppSnackBar(context,  responseData['message'] ??
              'Thank you for rating us $rating star${rating > 1 ? 's' : ''}!', backgroundColor: appcolor);


          // Show success message
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text(
          //     ,
          //       style: GoogleFonts.poppins(color: Colors.white),
          //     ),
          //     backgroundColor: Colors.green,
          //     behavior: SnackBarBehavior.floating,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //   ),
          // );
        } else {
          throw Exception(responseData['message'] ?? 'Failed to submit rating');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Server error occurred');
      }
    } catch (e) {
      _ratingErrorNotifier.value = e.toString().replaceFirst('Exception: ', '');
      print('Error submitting rating: $e');
    } finally {
      _isRatingDialogLoadingNotifier.value = false;
    }
  }

  Future<void> _deleteAccount() async {
    try {
      // Get the stored token (assuming you have a method to get it)

      if (token == null) {
        throw Exception('Authentication token not found');
      }
      print(token);
      final response = await http.delete(
        Uri.parse(
            '$baseUrl/auth/delete-account'), // Replace with your actual API endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // Check for success in response
        if (responseData['success'] == true ||
            responseData['status'] == 'success') {
          // Account deleted successfully
          // Clear any stored data
          await remove(); // Clear stored token/data
          showAppSnackBar(context,  responseData['message'] ?? 'Account deleted successfully', backgroundColor: appcolor);

          // Show success message


          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.signin,
                (Route<dynamic> route) => false,
          );
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to delete account');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Server error occurred');
      }
    } catch (e) {
      print('Error deleting account: $e');

      // Show error message
      showAppSnackBar(context,   e.toString().replaceFirst('Exception: ',''), backgroundColor: appcolor);


    }
  }

// Add this method to show confirmation dialog
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Text(
                'Delete Account',
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteAccount();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRateAppDialog() {
    final localizations = AppLocalizations.of(context)!;
    // Reset values
    _selectedRatingNotifier.value = 0;
    _isRatingDialogLoadingNotifier.value = false;
    _ratingErrorNotifier.value = null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
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
                  localizations.rateOurApp,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: appcolor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.rateAppDescription,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 30),

                // Error Message
                ValueListenableBuilder<String?>(
                  valueListenable: _ratingErrorNotifier,
                  builder: (context, errorMessage, _) {
                    if (errorMessage != null) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red.shade600, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Star Rating
                ValueListenableBuilder<int>(
                  valueListenable: _selectedRatingNotifier,
                  builder: (context, selectedRating, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            _selectedRatingNotifier.value = index + 1;
                            _ratingAnimationController.forward().then((_) {
                              _ratingAnimationController.reverse();
                            });
                          },
                          child: AnimatedBuilder(
                            animation: _starAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: selectedRating == index + 1
                                    ? _starAnimation.value
                                    : 1.0,
                                child: Icon(
                                  Icons.star,
                                  size: 40,
                                  color: index < selectedRating
                                      ? Colors.amber
                                      : Colors.grey.shade300,
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    );
                  },
                ),

                ValueListenableBuilder<int>(
                  valueListenable: _selectedRatingNotifier,
                  builder: (context, selectedRating, _) {
                    if (selectedRating > 0) {
                      return Column(
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            _getRatingText(selectedRating),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: appcolor,
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                const SizedBox(height: 30),

                // Action Buttons
                ValueListenableBuilder<bool>(
                  valueListenable: _isRatingDialogLoadingNotifier,
                  builder: (context, isLoading, _) {
                    if (isLoading) {
                      return Container(
                        height: 50,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: appcolor,
                          ),
                        ),
                      );
                    }

                    return ValueListenableBuilder<int>(
                      valueListenable: _selectedRatingNotifier,
                      builder: (context, selectedRating, _) {
                        return Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                                child: Text(
                                  localizations.cancel,
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
                                onPressed: selectedRating > 0
                                    ? () => _submitRating(selectedRating)
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: selectedRating > 0
                                      ? appcolor
                                      : Colors.grey.shade300,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  localizations.submit,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: selectedRating > 0
                                        ? Colors.white
                                        : Colors.grey.shade500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
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

  String _getRatingMessage(int rating) {
    final localizations = AppLocalizations.of(context)!;
    switch (rating) {
      case 1:
        return localizations.ratingResponse1;
      case 2:
        return localizations.ratingResponse2;
      case 3:
        return localizations.ratingResponse3;
      case 4:
        return localizations.ratingResponse4;
      case 5:
        return localizations.ratingResponse5;
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: themeController.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: themeController.white,
        elevation: 0,
        leading: BackButton(color: appcolor),
        centerTitle: true,
        title: Text(
          localizations.profile,
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: Color(0xFFAA8A00),
            fontSize: 24,
          ),
        ),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _profileController.isLoadingNotifier,
        builder: (context, isLoading, _) {
          if (isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFFAA8A00)));
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
                        localizations.settings,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                    // const SizedBox(height: 16),
                    // CustomSwitchTile(
                    //   image: "assets/Icons/notification.png",
                    //   title: AppConstants.notifications,
                    //   value: isNotificationEnabled,
                    //   onChanged: (val) => setState(() => isNotificationEnabled = val),
                    // ),
                    CustomListTile(
                      image: "assets/Icons/language.png",
                      title: localizations.language,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.language);
                      },
                    ),
                    CustomListTile(
                      image: "assets/Icons/policy.png",
                      title: localizations.privacyPolicy,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.privacypolicy);
                      },
                    ),
                    CustomListTile(
                      icon: Icons.mail_outline,
                      title: localizations.contactUs,
                      onTap: _navigateToContactUs,
                    ),
                    CustomListTile(
                      icon: Icons.star_border,
                      title: localizations.rateApp,
                      onTap: _showRateAppDialog,
                    ),

                    CustomListTile(
                      icon: Icons.login_outlined,
                      title: localizations.logout,
                      onTap: () async {
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.white,
                            title: Text(localizations.confirmLogout,
                                style: GoogleFonts.poppins(color: Colors.red,fontWeight: FontWeight.bold)),
                            content: Text(localizations.areYouSureLogout,
                                style: GoogleFonts.poppins(color: Colors.black54)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(localizations.cancel,
                                    style:
                                        GoogleFonts.poppins(color: Colors.grey)),
                              ),
                              ElevatedButton(
                                style:  ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),),
                                onPressed: () async { Navigator.pop(context, true);

                                await remove();

                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRoutes.signin,
                                      (Route<dynamic> route) => false,
                                );


                                },

                                child: Text(localizations.logout,
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );




                      },
                    ),
                    CustomListTile(
                      icon: Icons.delete_outline_outlined,
                      title: localizations.delete,
                      onTap: () {
                        _showDeleteAccountDialog();
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
              border:
                  Border.all(color: Colors.grey.withOpacity(0.2), width: 0.5),
            ),
            child: ClipOval(
              child: userProfile.profileImage.isNotEmpty
                  ? Image.network(
                      userProfile.profileImage,
                      fit: BoxFit.cover,
                      alignment: const Alignment(
                          0, -1), // Shift up to focus on face area
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
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              userProfile.email,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400, fontSize: 10),
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
                border: Border.all(
                    color: Colors.grey.withOpacity(0.5), width: 0.5)),
            child: Image.asset('assets/Icons/edit_icon.png', scale: 4),
          ),
        )
      ],
    );
  }
}
