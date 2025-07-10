import 'dart:convert';
import 'package:fitlip_app/main.dart';
import 'package:fitlip_app/routes/App_routes.dart';
import 'package:fitlip_app/view/Screens/Profile/setting/contact_us.dart';
import 'package:fitlip_app/view/Utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:fitlip_app/controllers/profile_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../model/profile_model.dart';
import '../../Utils/Colors.dart';
import '../../Utils/globle_variable/globle.dart';
import '../../Widgets/custom_message.dart';
import '../../Widgets/custom_switch.dart';
import '../../Widgets/custom_tile.dart';
import 'edit_profile.dart';
import 'package:http/http.dart' as http;
// Add these imports at the top
import 'package:flutter/services.dart';

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
  
  // Add loading state for date changes
  final ValueNotifier<bool> _isDateLoadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isImageLoadingNotifier = ValueNotifier<bool>(false);

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
    _isDateLoadingNotifier.dispose();
    _isImageLoadingNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    await _profileController.getUserProfile();
  }

  // Add method to handle date changes with loading
  Future<void> _onDateChanged(DateTime newDate) async {
    _isDateLoadingNotifier.value = true;
    try {
      // Simulate API call or actual date change logic
      await Future.delayed(const Duration(seconds: 1));
      // Add your date change logic here
      // await _profileController.updateUserDate(newDate);
    } catch (e) {
      // Handle error
      print('Error updating date: $e');
    } finally {
      _isDateLoadingNotifier.value = false;
    }
  }

  Future<void> _navigateToEditProfile() async {
    Navigator.pushReplacementNamed(context, AppRoutes.editprofile);
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
        Uri.parse('$baseUrl/rating'),
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
        if (responseData['success'] == true ||
            responseData['status'] == 'success') {
          Navigator.pop(context);
          showAppSnackBar(
              context,
              responseData['message'] ??
                  'Thank you for rating us $rating star${rating > 1 ? 's' : ''}!',
              backgroundColor: appcolor);
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to submit rating');
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
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      print(token);
      final response = await http.delete(
        Uri.parse('$baseUrl/auth/delete-account'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true ||
            responseData['status'] == 'success') {
          await remove();
          showAppSnackBar(context,
              responseData['message'] ?? 'Account deleted successfully',
              backgroundColor: appcolor);
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
      showAppSnackBar(context, e.toString().replaceFirst('Exception: ', ''),
          backgroundColor: appcolor);
    }
  }

  void _showDeleteAccountDialog() {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxWidth: screenSize.width > 600 ? 400 : double.infinity,
            ),
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red, size: isSmallScreen ? 20 : 24),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Delete Account',
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 16 : 18,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Text(
                  'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade700,
                    height: 1.4,
                    fontSize: isSmallScreen ? 13 : 14,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16 : 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                          fontSize: isSmallScreen ? 13 : 14,
                        ),
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 8 : 12),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12 : 16,
                          vertical: isSmallScreen ? 8 : 10,
                        ),
                      ),
                      child: Text(
                        'Delete',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: isSmallScreen ? 13 : 14,
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
  }

  void _showRateAppDialog() {
    final localizations = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    
    _selectedRatingNotifier.value = 0;
    _isRatingDialogLoadingNotifier.value = false;
    _ratingErrorNotifier.value = null;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxWidth: screenSize.width > 600 ? 400 : double.infinity,
            ),
            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: isSmallScreen ? 60 : 80,
                    height: isSmallScreen ? 60 : 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: appcolor.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.star,
                      size: isSmallScreen ? 30 : 40,
                      color: appcolor,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 20),
                  Text(
                    localizations.rateOurApp,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: appcolor,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  Text(
                    localizations.rateAppDescription,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 24 : 30),
                  
                  // Error message - keep the same
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
                  
                  // Star rating - adjust size based on screen
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
                                    size: isSmallScreen ? 32 : 40,
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
                  
                  // Rating text
                  ValueListenableBuilder<int>(
                    valueListenable: _selectedRatingNotifier,
                    builder: (context, selectedRating, _) {
                      if (selectedRating > 0) {
                        return Column(
                          children: [
                            SizedBox(height: isSmallScreen ? 16 : 20),
                            Text(
                              _getRatingText(selectedRating),
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 14 : 16,
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
                  
                  SizedBox(height: isSmallScreen ? 24 : 30),
                  
                  // Action buttons
                  ValueListenableBuilder<bool>(
                    valueListenable: _isRatingDialogLoadingNotifier,
                    builder: (context, isLoading, _) {
                      if (isLoading) {
                        return Container(
                          height: 50,
                          child: Center(
                            child: LoadingAnimationWidget.fourRotatingDots(
                                color: appcolor, size: 20),
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
                                    padding: EdgeInsets.symmetric(
                                      vertical: isSmallScreen ? 10 : 12
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(color: Colors.grey.shade300),
                                    ),
                                  ),
                                  child: Text(
                                    localizations.cancel,
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmallScreen ? 14 : 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: isSmallScreen ? 8 : 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: selectedRating > 0
                                      ? () => _submitRating(selectedRating)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: selectedRating > 0
                                        ? appcolor
                                        : Colors.grey.shade300,
                                    padding: EdgeInsets.symmetric(
                                      vertical: isSmallScreen ? 10 : 12
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    localizations.submit,
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmallScreen ? 14 : 16,
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

  // Replace the entire build method with this responsive version
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isLandscape = screenSize.width > screenSize.height;
    
    // Set preferred orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
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
            fontSize: isSmallScreen ? 20 : 24,
          ),
        ),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _profileController.isLoadingNotifier,
        builder: (context, isLoading, _) {
          if (isLoading) {
            return Center(
                child: LoadingAnimationWidget.fourRotatingDots(
                    color: appcolor, size: 20));
          }
          return ValueListenableBuilder<UserProfileModel?>(
            valueListenable: _profileController.profileNotifier,
            builder: (context, userProfile, _) {
              if (userProfile == null) {
                return const Center(child: Text('Failed to load profile data'));
              }
              
              // Use LayoutBuilder to get constraints
              return LayoutBuilder(
                builder: (context, constraints) {
                  // Determine if we should use a different layout for landscape mode
                  if (isLandscape && screenSize.width > 600) {
                    return _buildLandscapeLayout(
                      context, 
                      userProfile, 
                      localizations, 
                      constraints
                    );
                  }
                  
                  // Default portrait layout
                  return _buildPortraitLayout(
                    context, 
                    userProfile, 
                    localizations, 
                    isSmallScreen
                  );
                }
              );
            },
          );
        },
      ),
    );
  }

  // Add these new methods for responsive layouts
  Widget _buildPortraitLayout(
    BuildContext context, 
    UserProfileModel userProfile, 
    AppLocalizations localizations,
    bool isSmallScreen
  ) {
    final responsivePadding = isSmallScreen ? 12.0 : 20.0;
    
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(responsivePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(userProfile),
            SizedBox(height: isSmallScreen ? 16 : 20),
            
            // Add date loading indicator
            ValueListenableBuilder<bool>(
              valueListenable: _isDateLoadingNotifier,
              builder: (context, isDateLoading, _) {
                if (isDateLoading) {
                  return Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LoadingAnimationWidget.fourRotatingDots(
                            color: appcolor, size: isSmallScreen ? 14 : 16),
                        SizedBox(width: isSmallScreen ? 8 : 12),
                        Text(
                          'Updating date...',
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 12 : 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  localizations.settings,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, 
                      fontSize: isSmallScreen ? 14 : 16),
                ),
              ),
            ),
            
            // Settings tiles with responsive spacing
            _buildSettingsTiles(context, localizations, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context, 
    UserProfileModel userProfile, 
    AppLocalizations localizations,
    BoxConstraints constraints
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // In landscape, we can show profile header in a more spread out way
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Profile image and info
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Profile image with larger size for landscape
                        GestureDetector(
                          onTap: _showFullScreenImage,
                          child: _buildProfileImage(userProfile, 80),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userProfile.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold, 
                            fontSize: 18
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          userProfile.email,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400, 
                            fontSize: 12
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _navigateToEditProfile,
                          icon: const Icon(Icons.edit, size: 16),
                          label: Text(
                            'Edit Profile',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appcolor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16, 
                              vertical: 8
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Right side - Settings
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date loading indicator
                      ValueListenableBuilder<bool>(
                        valueListenable: _isDateLoadingNotifier,
                        builder: (context, isDateLoading, _) {
                          if (isDateLoading) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  LoadingAnimationWidget.fourRotatingDots(
                                      color: appcolor, size: 16),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Updating date...',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                        child: Text(
                          localizations.settings,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, 
                            fontSize: 16
                          ),
                        ),
                      ),
                      
                      // Settings tiles
                      _buildSettingsTiles(context, localizations, false),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Extract settings tiles to a separate method for reuse
  Widget _buildSettingsTiles(
    BuildContext context, 
    AppLocalizations localizations,
    bool isSmallScreen
  ) {
    final tilePadding = isSmallScreen 
        ? const EdgeInsets.symmetric(vertical: 10, horizontal: 12)
        : const EdgeInsets.symmetric(vertical: 12, horizontal: 16);
    
    final tileIconSize = isSmallScreen ? 20.0 : 24.0;
    final tileFontSize = isSmallScreen ? 13.0 : 14.0;
    
    return Column(
      children: [
        _buildCustomListTile(
          image: "assets/Icons/language.png",
          title: localizations.language,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.language);
          },
          padding: tilePadding,
          iconSize: tileIconSize,
          fontSize: tileFontSize,
        ),
        _buildCustomListTile(
          image: "assets/Icons/policy.png",
          title: localizations.privacyPolicy,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.privacypolicy);
          },
          padding: tilePadding,
          iconSize: tileIconSize,
          fontSize: tileFontSize,
        ),
        _buildCustomListTile(
          icon: Icons.mail_outline,
          title: localizations.contactUs,
          onTap: _navigateToContactUs,
          padding: tilePadding,
          iconSize: tileIconSize,
          fontSize: tileFontSize,
        ),
        _buildCustomListTile(
          icon: Icons.star_border,
          title: localizations.rateApp,
          onTap: _showRateAppDialog,
          padding: tilePadding,
          iconSize: tileIconSize,
          fontSize: tileFontSize,
        ),
        _buildCustomListTile(
          icon: Icons.login_outlined,
          title: localizations.logout,
          onTap: () async {
            final shouldLogout = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.white,
                title: Text(localizations.confirmLogout,
                    style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontWeight: FontWeight.bold)),
                content: Text(localizations.areYouSureLogout,
                    style: GoogleFonts.poppins(color: Colors.black54)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(localizations.cancel,
                        style: GoogleFonts.poppins(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(context, true);
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
          padding: tilePadding,
          iconSize: tileIconSize,
          fontSize: tileFontSize,
        ),
        _buildCustomListTile(
          icon: Icons.delete_outline_outlined,
          title: localizations.delete,
          onTap: () {
            _showDeleteAccountDialog();
          },
          padding: tilePadding,
          iconSize: tileIconSize,
          fontSize: tileFontSize,
          isDestructive: true,
        ),
      ],
    );
  }

  // Custom list tile with responsive parameters
  Widget _buildCustomListTile({
    String? image,
    IconData? icon,
    required String title,
    required VoidCallback onTap,
    required EdgeInsets padding,
    required double iconSize,
    required double fontSize,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: padding,
        leading: image != null
            ? Image.asset(image, width: iconSize, height: iconSize)
            : Icon(icon, size: iconSize, color: isDestructive ? Colors.red : appcolor),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: iconSize - 6,
          color: Colors.grey.shade400,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
      ),
    );
  }

  // Replace the _buildProfileHeader method with this responsive version
  Widget _buildProfileHeader(UserProfileModel userProfile) {
    // Get screen width to determine responsive sizes
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    // Adjust image size based on screen width
    final double imageSize = isSmallScreen ? 50.0 : 60.0;
    final double fontSize = isSmallScreen ? 14.0 : 16.0;
    final double emailFontSize = isSmallScreen ? 9.0 : 10.0;
  
  return Row(
    children: [
      GestureDetector(
        onTap: _showFullScreenImage,
        child: _buildProfileImage(userProfile, imageSize),
      ),
      SizedBox(width: isSmallScreen ? 8 : 12),
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userProfile.name,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, 
                fontSize: fontSize
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              userProfile.email,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400, 
                fontSize: emailFontSize
              ),
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
      ),
      GestureDetector(
        onTap: _navigateToEditProfile,
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey.withOpacity(0.5), 
              width: 0.5
            )
          ),
          child: Image.asset(
            'assets/Icons/edit_icon.png', 
            scale: isSmallScreen ? 5 : 4
          ),
        ),
      )
    ],
  );
}

// Add a helper method for profile image with loading state
Widget _buildProfileImage(UserProfileModel userProfile, double imageSize) {
  return Container(
    width: imageSize,
    height: imageSize,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: Colors.grey.withOpacity(0.2), 
        width: 0.5
      ),
    ),
    child: ValueListenableBuilder<bool>(
      valueListenable: _isImageLoadingNotifier,
      builder: (context, isImageLoading, _) {
        return ClipOval(
          child: Stack(
            children: [
              // Main image
              Container(
                width: imageSize,
                height: imageSize,
                child: userProfile.profileImage.isNotEmpty
                  ? Image.network(
                      userProfile.profileImage,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                      alignment: const Alignment(0, -1),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          _isImageLoadingNotifier.value = false;
                          return child;
                        }
                        _isImageLoadingNotifier.value = true;
                        return Container(
                          width: imageSize,
                          height: imageSize,
                          color: Colors.grey.shade200,
                          child: Center(
                            child: LoadingAnimationWidget.fourRotatingDots(
                              color: appcolor,
                              size: imageSize * 0.25,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        _isImageLoadingNotifier.value = false;
                        return Image.asset(
                          'assets/Images/circle_image.png',
                          width: imageSize,
                          height: imageSize,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      'assets/Images/circle_image.png',
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                    ),
              ),
              // Loading overlay
              if (isImageLoading)
                Container(
                  width: imageSize,
                  height: imageSize,
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: LoadingAnimationWidget.fourRotatingDots(
                      color: Colors.white,
                      size: imageSize * 0.25,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    ),
  );
}

// Make the rate app dialog responsive
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
        body: OrientationBuilder(
          builder: (context, orientation) {
            return Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Image.network(
                    userProfile.profileImage,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Center(
                        child: LoadingAnimationWidget.fourRotatingDots(
                          color: Colors.white,
                          size: 30,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white.withOpacity(0.7),
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load image',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}
    }