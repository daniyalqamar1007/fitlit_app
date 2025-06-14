
import 'dart:async';
import 'dart:convert';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitlip_app/routes/App_routes.dart';
import 'package:fitlip_app/controllers/themecontroller.dart';
import 'package:fitlip_app/view/Screens/Dashboard/selectbackground.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/avatar_controller.dart';
import '../../../controllers/background_image_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../../controllers/wardrobe_controller.dart';
import '../../../controllers/outfit_controller.dart';
import '../../../main.dart';
import '../../../model/background_image_model.dart';
import '../../../model/outfit_model.dart';
import '../../../model/profile_model.dart';
import '../../../model/wardrobe_model.dart';
import '../../Utils/Colors.dart';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import '../../Utils/connection.dart';
import '../../Utils/globle_variable/globle.dart';
import '../../Utils/responsivness.dart';
import '../../Widgets/custom_message.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({Key? key}) : super(key: key);

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<UserProfileModel?> profileNotifier =
  ValueNotifier<UserProfileModel?>(null);
  final ProfileController _profileController = ProfileController();
  DateTime _focusedDay = DateTime.now();
  WardrobeController controller = WardrobeController();
  DateTime? _selectedDay;
  final AvatarController _avatarController = AvatarController();
  bool _isGeneratingAvatar = false;
  final ImagePicker _picker = ImagePicker();
  String? _avatarUrl;
  bool _isUploading = false;

  SharedPreferences? _prefs;
  double _uploadProgress = 0.0;
  Timer? _uploadProgressTimer;
  int _currentShirtIndex = 0;
  int _currentPantIndex = 0;
  int _currentShoeIndex = 0;
  bool _isSwipeGenerating = false;
  String? _swipeDirection; // 'up', 'down', 'left', 'right'
  String? _swipeCategory;
  String? userProfileImage;
  String? profileImage;
  int _currentAvatarIndex = 0;
  String outfitMessage="";
  String currenturl="";
  final WardrobeController _wardrobeController = WardrobeController();
  final OutfitController _outfitController = OutfitController();
  AnimationController? _avatarAnimationController;
  Animation<Offset>? _slideOutAnimation;
  Animation<Offset>? _slideInAnimation;
  bool _isLoading = false;
  bool _isAnimatingIn = false;
  String loadingType = "";
  List<String> _userAvatars = [];
  // int _currentAvatarIndex = 0;
  bool _isLoadingAvatars = false;
  bool isLoadingItems = true;
  bool isSavingOutfit = false;
  String? leftMessage;
  String? rightMessage;
TextEditingController messagecontroller=TextEditingController();
  String? selectedShirtId;
  String? selectedPantId;
  String? selectedShoeId; final BackgroundImageController _backgroundImageController = BackgroundImageController();
  String? selectedAccessoryId;
  List<BackgroundImageModel> _apiBackgrounds = [];
  bool _isLoadingBackgrounds = false;
  String _currentBackgroundPath = 'assets/Images/back1.png';
  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
     _loadBackgroundImages();
    _loadUserProfile();
    _getUserInfoAndLoadItems();
    _loadAllUserAvatars(); // Add this line
    _wardrobeController.statusNotifier.addListener(_handleStatusChange);
    _avatarController.statusNotifier.addListener(_handleAvatarStatusChange);
    _loadAvatarDates();
    // _checkExistingOutfit(_focusedDay);
  }
  Future<void> _loadBackgroundImages() async {
    setState(() {
      _isLoadingBackgrounds = true;
    });

    try {
      // Implement this method to get your auth token
      if (token != null) {
        final success = await _backgroundImageController.getAllBackgroundImages(token: token!);
        if (success) {
          setState(() {
            _apiBackgrounds = _backgroundImageController.backgroundImagesNotifier.value;
          });
        }
      }
    } catch (e) {
      print("Error loading background images: $e");
    } finally {
      setState(() {
        _isLoadingBackgrounds = false;
      });
    }
  }
  void   _handleStatusChange() {
    if (mounted) {
      setState(() {
        isLoadingItems =
            _wardrobeController.statusNotifier.value == WardrobeStatus.loading;
      });
    }
  }
 
  void _handleAvatarStatusChange() {
    if (mounted) {
      setState(() {
        _isGeneratingAvatar = _avatarController.statusNotifier.value ==
            AvatarGenerationStatus.loading;
      });
    }
  }
    Future<void> _loadAllUserAvatars() async {
      try {
        setState(() {
          _isLoadingAvatars = true;
        });
  
        final response = await http.get(
          Uri.parse('${baseUrl}/avatar/user-avatars'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        print(response.body);
        print(response.statusCode);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true && data['avatars'] != null) {
            setState(() {
              _userAvatars = List<String>.from(data['avatars']);
              _currentAvatarIndex = 0;
            });
          }
        }
      } catch (e) {
        print('Error loading user avatars: $e');
      } finally {
        setState(() {
          _isLoadingAvatars = false;
        });
      }
    }
  
    String? _getCurrentAvatarImage(UserProfileModel? userProfile) {
      // First check if we have avatars loaded and valid index
      if (_userAvatars.isNotEmpty && _currentAvatarIndex < _userAvatars.length) {
        return _userAvatars[_currentAvatarIndex];
      }
  
      // If we have an avatar URL from API
      if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
        return _avatarUrl;
      }
  
      // Otherwise show profile image as default
      if (userProfile?.profileImage.isNotEmpty == true) {
        return userProfile!.profileImage;
      }
  
      // Fallback to null (will show loading or error)
      return null;
    }
  
    void _handleShirtSwipe(String direction) {
      final shirts = _wardrobeController.shirtsNotifier.value;
      if (shirts.isEmpty) {
        showAppSnackBar(context,'No shirts available in your wardrobe', backgroundColor: appcolor);
  
  
        return;
      }
  
      int newIndex = _currentShirtIndex;
  
      if (direction == 'next') {
        newIndex = (_currentShirtIndex + 1) % shirts.length;
      } else if (direction == 'previous') {
        newIndex = (_currentShirtIndex - 1 + shirts.length) % shirts.length;
      }
  
      if (newIndex != _currentShirtIndex) {
        setState(() {
          _currentShirtIndex = newIndex;
          selectedShirtId = shirts[newIndex].id;
        });
  
        _generateAvatarFromSwipe('shirt', direction);
        _animateItemChange('shirt');
      }
    }
  
    void _handlePantSwipe(String direction) {
      final pants = _wardrobeController.pantsNotifier.value;
      if (pants.isEmpty) {
        showAppSnackBar(context,'No pants available in your wardrobe', backgroundColor: appcolor);
  
        return;
      }
  
      int newIndex = _currentPantIndex;
  
      if (direction == 'next') {
        newIndex = (_currentPantIndex + 1) % pants.length;
      } else if (direction == 'previous') {
        newIndex = (_currentPantIndex - 1 + pants.length) % pants.length;
      }
  
      if (newIndex != _currentPantIndex) {
        setState(() {
          _currentPantIndex = newIndex;
          selectedPantId = pants[newIndex].id;
        });
  
        _generateAvatarFromSwipe('pant', direction);
        _animateItemChange('pant');
      }
    }
  
    void _handleShoeSwipe(String direction) {
      final shoes = _wardrobeController.shoesNotifier.value;
      if (shoes.isEmpty) {
        showAppSnackBar(context,'No shoes available in your wardrobe', backgroundColor: appcolor);
  
        return;
      }
  
      int newIndex = _currentShoeIndex;
  
      if (direction == 'next') {
        newIndex = (_currentShoeIndex + 1) % shoes.length;
      } else if (direction == 'previous') {
        newIndex = (_currentShoeIndex - 1 + shoes.length) % shoes.length;
      }
  
      if (newIndex != _currentShoeIndex) {
        setState(() {
          _currentShoeIndex = newIndex;
          selectedShoeId = shoes[newIndex].id;
        });
  
        _generateAvatarFromSwipe('shoes', direction);
        _animateItemChange('shoes');
      }
    }
    Future<void> _generateAvatarFromSwipe(String category, String direction) async {
      final localizations = AppLocalizations.of(context)!;
  
      // Check internet connection
      bool hasInternet = await checkInternetAndShowDialog(context);
      if (!hasInternet) {
        return;
      }
  
      // Validate all required items are selected
      if (selectedShirtId == null ||
          selectedPantId == null ||
          selectedShoeId == null ||
          selectedAccessoryId == null) {
        showAppSnackBar(context,'No shoes available in your wardrobe', backgroundColor: appcolor);
  
            return;
      }
  
      try {
        setState(() {
          _isSwipeGenerating = true;
        });
  
        // Show swipe feedback
        _showSwipeDirection(category, direction);
  
        final response = await _avatarController.generateAvatar(
          shirtId: selectedShirtId,
          accessories_id: selectedAccessoryId,
          pantId: selectedPantId,
          shoeId: selectedShoeId,
          token: token,
          profile: _profileController.profileNotifier.value!.profileImage,
        );
  
        if (response.avatar != null) {
          await _loadAllUserAvatars();
  
          setState(() {
            _avatarUrl = response.avatar!;
            profileImage = response.avatar!;
            _isSwipeGenerating = false;
          });
  
        } else {
          setState(() {
            _isSwipeGenerating = false;
          });
          showAppSnackBar(context,'Failed to generate avatar', backgroundColor: appcolor);
  
        }
      } catch (e) {
        setState(() {
          _isSwipeGenerating = false;
        });
        showAppSnackBar(context,'Error generating avatar: ${e.toString()}', backgroundColor: appcolor);
  
      }
    }
  
  // Updated image container without emojis
    Widget _buildImageWithLoadingEnhanced(String category, List<WardrobeItem> items) {
      WardrobeItem? selectedItem = _getSelectedItemForCategory(category, items);
      String? imageUrl = selectedItem?.imageUrl ?? items.first.imageUrl;
  
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl ?? '',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(
                    _getIconForCategory(category),
                    color: Colors.grey,
                    size: 24,
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: LoadingAnimationWidget.fourRotatingDots(
                       color:appcolor,size:20

                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Enhanced selection indicator
          if (_isItemSelected(category))
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: appcolor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          // Category indicator without emoji
          // if (_isItemSelected(category))
          //   Positioned(
          //     top: 2,
          //     left: 2,
          //     child: Container(
          //       padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          //       decoration: BoxDecoration(
          //         color: appcolor.withOpacity(0.9),
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //       child: Text(
          //         _getCategoryLabel(category),
          //         style: TextStyle(
          //           fontSize: 8,
          //           color: Colors.white,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      );
    }
  
  
    void _showSwipeDirection(String category, String direction) {
      String message = '';
  
      switch (category) {
        case 'shirt':
          message = direction == 'next' ? 'Next Shirt' : 'Previous Shirt';
          break;
        case 'pant':
          message = direction == 'next' ? 'Next Pants' : 'Previous Pants';
          break;
        case 'shoes':
          message = direction == 'next' ? 'Next Shoes' : 'Previous Shoes';
          break;
      }
  
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: appcolor,
          duration: Duration(milliseconds: 800),
        ),
      );
    }
  
  
  // Update your _updateSelectedItemsFromCurrentOutfit method
    void _updateSelectedItemsFromCurrentOutfit() {
      // Update selected IDs and indices based on first items in each category
      if (_wardrobeController.shirtsNotifier.value.isNotEmpty) {
        selectedShirtId = _wardrobeController.shirtsNotifier.value.last.id;
        _currentShirtIndex = _wardrobeController.shirtsNotifier.value.length - 1;
      }
  
      if (_wardrobeController.pantsNotifier.value.isNotEmpty) {
        selectedPantId = _wardrobeController.pantsNotifier.value.last.id;
        _currentPantIndex = _wardrobeController.pantsNotifier.value.length - 1;
      }
  
      if (_wardrobeController.shoesNotifier.value.isNotEmpty) {
        selectedShoeId = _wardrobeController.shoesNotifier.value.last.id;
        _currentShoeIndex = _wardrobeController.shoesNotifier.value.length - 1;
      }
  
      if (_wardrobeController.accessoriesNotifier.value.isNotEmpty) {
        selectedAccessoryId = _wardrobeController.accessoriesNotifier.value.last.id;
      }
    }
  
  
    Future<void> _getUserInfoAndLoadItems() async {
      // final localizations = AppLocalizations.of(context)!;
      try {
        setState(() {
          isLoadingItems = true;
        });
  
        await _wardrobeController.loadWardrobeItems();
  
        // After loading items, set default selections
        _updateSelectedItemsFromCurrentOutfit();
      } catch (e) {
        print("Error getting user info: $e");
        // if (mounted) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text(localizations.failedToLoadWardrobeItems),
        //       backgroundColor: Colors.red,
        //     ),
        //   );
        // }
      }
    }
  
    Future<void> _loadUserProfile() async {
      await _profileController.getUserProfile();
      _profileController.profileNotifier.addListener(() {
        final profile = _profileController.profileNotifier.value;
        if (profile != null) {
          print("id is ${profile.id}");
          _checkExistingOutfit(_focusedDay);
        } else {
          print("User profile still null");
        }
      });
    }
  
    // Check if there's an existing outfit for the selected date
    Future<void> _checkExistingOutfit(DateTime date) async {
      // final localizations = AppLocalizations.of(context)!;
      try {
        setState(() {
          isLoadingItems = true; // Show loading indicator
        });
        // bool hasInternet = await checkInternetAndShowDialog(context);
        // if (!hasInternet) {
        //   return;
        // }
        print(_profileController.profileNotifier.value!.id);
        final outfit = await _outfitController.getOutfitByDate(
            token: token!,
            date: date,
            id: _profileController.profileNotifier.value!.id);
        print("coming ios $outfit");
        if (outfit != "") {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text(
          //       localizations.updateAvailableForThisDate,
          //       style: GoogleFonts.poppins(color: Colors.white),
          //     ),
          //     backgroundColor: appcolor,
          //     duration: Duration(seconds: 1),
          //   ),
          // );
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text(
          //       localizations.noOutfitAvailableForThisDate,
          //       style: GoogleFonts.poppins(color: Colors.white),
          //     ),
          //     backgroundColor: appcolor,
          //     duration: Duration(seconds: 1),
          //   ),
          // );
          setState(() {
            _avatarUrl = outfit; // Update the avatar URL state
            profileImage = outfit; // Also update profileImage for saving
          });
          _updateAvatarBasedOnOutfit(outfit);
  
          // Show brief success message that an outfit was found
        } else {}
  
        setState(() {
          isLoadingItems = false; // Hide loading indicator
        });
      } catch (e) {
        print("Error checking existing outfit: $e");
        setState(() {
          isLoadingItems = false;
        });
      }
    }
  
    void _updateAvatarBasedOnOutfit(outfit) {
      print(outfit);
      _avatarUrl = outfit;
      _currentAvatarIndex = 1;
      // Logic to update avatar based on outfit components
      // This is a simplified implementation
      if (outfit.shirtId != null && outfit.pantId != null) {
        setState(() {
          _avatarUrl = outfit;
          profileImage = outfit;
          _currentAvatarIndex = 0; // Default to first index for API avatars
        });
      } else if (outfit.shirtId != null) {
        setState(() {
          _currentAvatarIndex = 1; // Shirt only
        });
      } else if (outfit.pantId != null) {
        setState(() {
          _currentAvatarIndex = 2; // Pants only
        });
      } else {
        setState(() {
          _currentAvatarIndex = 5; // Default
        });
      }
    }
  
  
    Future<void> _saveOutfit(BuildContext context) async {
      // Show confirmation dialog
      bool hasInternet = await checkInternetAndShowDialog(context);
      if (!hasInternet) {
        return;
      }
      bool confirmed = await _showSaveOutfitConfirmationDialog();
      if (!confirmed) return;
  
      setState(() {
        isSavingOutfit = true;
      });
  
      try {
        // Get the current avatar URL being displayed
        final currentAvatarUrl =
        _getCurrentAvatarImage(_profileController.profileNotifier.value);
  
        if (currentAvatarUrl == null || currentAvatarUrl.isEmpty) {
          setState(() {
            isSavingOutfit = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No avatar available to save'),
              backgroundColor: appcolor,
            ),
          );
          return;
        }
        if (selectedShirtId == null ||
            selectedPantId == null ||
            selectedShoeId == null||
            selectedAccessoryId == null
        ){
  
  
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Please select item first,missing item"),
              backgroundColor: appcolor,
            ),
          );
          setState(() {
            isSavingOutfit = false;
          });
  
          return;
        }
  
        final result = await _outfitController.saveOutfit(
          token: token!,
          shirtId: selectedShirtId ?? "",
          pantId: selectedPantId ?? "",
          shoeId: selectedShoeId ?? "",
          accessoryId: selectedAccessoryId,
          backgroundimageurl:currenturl,
          message: outfitMessage,
          // accessoryId: selectedAccessoryId ?? "",
          avatarurl: currentAvatarUrl,
          date: _selectedDay ?? _focusedDay,
        );
  
        setState(() {
          isSavingOutfit = false;
        });
  
        if (result) {
  
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Outfit saved successfully for ${_getFormattedDate(_selectedDay ?? _focusedDay)}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: appcolor,
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else {
  
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to save outfit',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: appcolor,
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
  
        }
      } catch (e) {
        setState(() {
          isSavingOutfit = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: appcolor,
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
  
      }
    }
    Future<void> _loadAvatarDates() async {
      if (token != null) {
        await _outfitController.loadAllAvatarDates(token: token!);
      }
    }
  void _showBackgroundSelectionSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackgroundSelectionSheet(
        currentBackgroundPath: _currentBackgroundPath,
        appColor: appcolor,
        onBackgroundSelected: (backgroundPath) async {
          setState(() {
            _currentBackgroundPath = backgroundPath;
          });

          // Reload background images to get the updated status
          await _loadBackgroundImages();

          // Force rebuild of the entire screen to show new background
          setState(() {});

          _showSuccessSnackBar("Background updated successfully!");
        },
      ),
    );
  }
  // Add this helper function for success messages
    void _showSuccessSnackBar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: Responsive.fontSize(12),
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: appcolor,
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: Responsive.allPadding(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Responsive.radius(10)),
          ),
        ),
      );
    }
  
    String _getFormattedDate(DateTime date) {
      return "${date.day} ${_getMonthName(date.month)} ${date.year}";
    }
  
    Future<bool> _showSaveOutfitConfirmationDialog() async {
      final localizations = AppLocalizations.of(context)!;
      bool result = false;
      TextEditingController messageController = TextEditingController();
  
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            localizations.saveOutfit,
            style: GoogleFonts.poppins(
              color: appcolor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${localizations.doYouWantToSaveThisOutfit(_getFormattedDate(_selectedDay ?? _focusedDay))}',
                style: GoogleFonts.poppins(),
              ),
              SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: 'Add a note (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                style: GoogleFonts.poppins(),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                result = false;
              },
              child: Text(
                localizations.cancel,
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
  
                outfitMessage = messageController.text.trim();
                Navigator.of(context).pop();
                result = true;
              },
              child: Text(
                localizations.save,
                style: GoogleFonts.poppins(
                  color: appcolor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
      return result;
    }
    @override
    void dispose() {
      _avatarAnimationController?.dispose();
      _wardrobeController.statusNotifier.removeListener(_handleStatusChange);
      _wardrobeController.dispose();
      _outfitController.dispose();
      _avatarController.statusNotifier.removeListener(_handleAvatarStatusChange);
      _avatarController.dispose();
  
      super.dispose();
    }
  
    @override
    Widget build(BuildContext context) {
      final localizations = AppLocalizations.of(context)!;

      return RefreshIndicator(
        color: appcolor,
        backgroundColor: white,
        onRefresh: () async {
          await _getUserInfoAndLoadItems();
          await _loadUserProfile();
          await _loadAvatarDates();
          await _loadBackgroundImages(); // Added this line
        },
        child: Scaffold(
          backgroundColor: themeController.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.7,
                          child: _buildBackgroundImage(),
                        ),
                      ),
                      Padding(
                        padding: Responsive.allPadding(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTopRow(),
                            SizedBox(height: Responsive.height(20)),
                            _buildThreeColumnSection(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: Responsive.allPadding(16.0),
                    child: _buildCalendarSection(controller),
                  ),
                  SizedBox(
                    height: Responsive.height(40),
                  )
                ],
              ),
            ),
          ),
          floatingActionButton: SizedBox(
            width: Responsive.width(100),
            height: Responsive.height(35),
            child: RawMaterialButton(
                onPressed: _showBackgroundSelectionSheet,
                fillColor: appcolor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      bool isLargeScreen = constraints.maxWidth > 600;

                      return Flex(
                        direction: isLargeScreen ? Axis.horizontal : Axis.vertical,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                          Text(
                            " background",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Responsive.fontSize(8),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                )
            ),
          ),
        ),
      );
    }
  Widget _buildBackgroundImage() {
    // Show loading state while backgrounds are being fetched
    if (_isLoadingBackgrounds) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[200],
        child: Center(
          child: LoadingAnimationWidget.fourRotatingDots(

            color:appcolor,size:40
          ),
        ),
      );
    }

    // Check if we have any backgrounds loaded
    if (_apiBackgrounds.isEmpty) {
      return Container(
        color: Colors.grey[200],
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Text(
            'No backgrounds available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Try to find the selected background from API backgrounds
    try {
      final selectedBackground = _apiBackgrounds.firstWhere(
            (bg) => bg.status == true,
      );
      currenturl=selectedBackground.imageUrl;

      return Container(
        width: double.infinity,
        height: double.infinity,
        child: Image.network(
          selectedBackground.imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[200],
              child: Center(
                child: LoadingAnimationWidget.fourRotatingDots(
                color:appcolor,
                  size:20
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[200],
            child: Center(
              child: Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 50,
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      // No background with status == true found
      // You can either show the first background or show fallback
      if (_apiBackgrounds.isNotEmpty) {
        // Option 1: Show first available background
        return Container(
          width: double.infinity,
          height: double.infinity,
          child: Image.network(
            _apiBackgrounds.first.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[200],
                child: Center(
                  child: LoadingAnimationWidget.fourRotatingDots(
                   color:appcolor,size:20
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[200],
              child: Center(
                child: Icon(
                  Icons.broken_image,
                  color: Colors.grey,
                  size: 50,
                ),
              ),
            ),
          ),
        );
      }

      // Fallback if no background is selected or available
      return Container(
        color: Colors.grey[200],
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Text(
            'No background selected',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
  }
      Widget _buildTopRow() {
        final localizations = AppLocalizations.of(context)!;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.profile);
                },
                child: ValueListenableBuilder<UserProfileModel?>(
                  valueListenable: _profileController.profileNotifier,
                  builder: (context, userProfile, _) {
                    if (userProfile == null) {
                      return LoadingAnimationWidget.fourRotatingDots(
                        color: appcolor,size:20
                      );
                    }

                    return
                      ClipOval(
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: userProfile.profileImage.isNotEmpty
                              ? Image.network(
                            userProfile.profileImage,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: LoadingAnimationWidget.fourRotatingDots(
                                  color: appcolor,size:20
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Image.asset(
                              'assets/Images/circle_image.png',
                              fit: BoxFit.cover,
                            ),
                          )
                              : Image.asset(
                            'assets/Images/circle_image.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      );

                  },
                ),
              ),
            ),
            SizedBox(
              width: Responsive.width(10),
            ),
            Expanded(
              flex: 3,
              child: Text(
                localizations.fitlit,
                style: GoogleFonts.playfairDisplay(
                  color: appcolor,
                  fontSize: Responsive.fontSize(22),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              width: Responsive.width(40),
            ),
            GestureDetector(
              onTap: isSavingOutfit
                  ? null
                  : () async {
                await _saveOutfit(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                height: 30,
                decoration: BoxDecoration(
                  color: isSavingOutfit ? Colors.grey : appcolor.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: isSavingOutfit
                    ? SizedBox(
                  width: 16,
                  height: 16,
                  child: LoadingAnimationWidget.fourRotatingDots(
                   color:appcolor,size:20
                  ),
                )
                    : Text(
                  localizations.save,
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10),
                ),
              ),
            ),
          ],
        );
      }

      Widget _buildThreeColumnSection() {
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // First Column - Date, Shirts, Accessories, Pants, Shoes
              Expanded(
                flex: 4,
                child: _buildFirstColumn(),
              ),

              // Second Column - Avatar
              Expanded(
                flex: 8,
                child: _buildAvatarColumn(),
              ),

              // Third Column - Similar to first column
              Expanded(
                flex: 4,
                child: _buildThirdColumn(),
              ),
            ],
          ),
        );
      }

      Widget _buildFirstColumn() {
        final localizations = AppLocalizations.of(context)!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Date section
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.width(10),
                  vertical: Responsive.height(10)),
              decoration: BoxDecoration(
                color: appcolor.withOpacity(0.7),
                borderRadius: BorderRadius.circular(Responsive.radius(30)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_month_sharp,
                    color: Colors.white,
                    size: Responsive.fontSize(14),
                  ),
                  Text(" ${_focusedDay.day} ${_getMonthName(_focusedDay.month)}",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.fontSize(10),
                      )),
                ],
              ),
            ),

            SizedBox(
              height: Responsive.height(10),
            ),

            // Shirts
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.width(14), vertical: Responsive.height(8)),
              height: Responsive.height(30),
              decoration: BoxDecoration(
                color: appcolor.withOpacity(0.7),
                borderRadius: BorderRadius.circular(Responsive.radius(30)),
              ),
              child: Text(
                localizations.shirts,
                style: GoogleFonts.poppins(
                  fontSize: Responsive.fontSize(10),
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              height: Responsive.height(10),
            ),
            _buildWardrobeItemContainer('shirt'),
            SizedBox(height: Responsive.height(7)),

            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.width(12), vertical: Responsive.height(8)),
              height: Responsive.height(30),
              decoration: BoxDecoration(
                color: appcolor.withOpacity(0.7),
                borderRadius: BorderRadius.circular(Responsive.radius(30)),
              ),
              child: Text(
                'Accessories',
                style: GoogleFonts.poppins(
                  fontSize: Responsive.fontSize(9),
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              height: Responsive.height(7),
            ),
            _buildWardrobeItemContainer('accessories'),
            SizedBox(
              height: Responsive.height(7),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.width(14), vertical: Responsive.height(8)),
              height: Responsive.height(30),
              decoration: BoxDecoration(
                color: appcolor.withOpacity(0.7),
                borderRadius: BorderRadius.circular(Responsive.radius(30)),
              ),
              child: Text(
                localizations.pants,
                style: GoogleFonts.poppins(
                  fontSize: Responsive.fontSize(10),
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              height: Responsive.height(7),
            ),

            _buildWardrobeItemContainer('pant'),
            SizedBox(
              height: Responsive.height(7),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.width(14), vertical: Responsive.height(8)),
              height: Responsive.height(30),
              decoration: BoxDecoration(
                color: appcolor.withOpacity(0.7),
                borderRadius: BorderRadius.circular(Responsive.radius(30)),
              ),
              child: Text(
                localizations.shoes,
                style: GoogleFonts.poppins(
                  fontSize: Responsive.fontSize(10),
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              height: Responsive.height(7),
            ),
            _buildWardrobeItemContainer('shoes'),
          ],
        );
      }

      void _showFullImageDialog(BuildContext context, String url) {
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: "Dismiss",
          barrierColor: Colors.black.withOpacity(0.85),
          transitionDuration: Duration(milliseconds: 300),
          pageBuilder: (_, __, ___) {
            return GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(
                  child: Container(
                    margin: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15)],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        url,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 100,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          transitionBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              child: ScaleTransition(
                scale: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                child: child,
              ),
            );
          },
        );
      }

      String _getMonthName(int month) {
        final localizations = AppLocalizations.of(context)!;
        var months = [
          localizations.jan,
          localizations.feb,
          localizations.mar,
          localizations.apr,
          localizations.may,
          localizations.jun,
          localizations.jul,
          localizations.aug,
          localizations.sep,
          localizations.oct,
          localizations.nov,
          localizations.dec,
          //
          // 'Feb',
          // 'Mar',
          // 'Apr',
          // 'May',
          // 'Jun',
          // 'Jul',
          // 'Aug',
          // 'Sep',
          // 'Oct',
          // 'Nov',
          // 'Dec'
        ];
        return months[month - 1];
      }

      Widget _buildWardrobeItemContainer(String category) {
        ValueNotifier<List<WardrobeItem>> notifier;
        switch (category) {
          case 'shirt':
            notifier = _wardrobeController.shirtsNotifier;
            break;
          case 'pant':
            notifier = _wardrobeController.pantsNotifier;
            break;
          case 'shoes':
            notifier = _wardrobeController.shoesNotifier;
            break;
          case 'accessories':
            notifier = _wardrobeController.accessoriesNotifier;
            break;
          default:
            notifier = _wardrobeController.shirtsNotifier;
        }

        return GestureDetector(
          onTap: () {
            _showItemSelectionDialog(category, notifier);
          },
          child: ValueListenableBuilder<List<WardrobeItem>>(
            valueListenable: notifier,
            builder: (context, items, child) {
              return Container(
                width: Responsive.width(60),
                height: Responsive.height(56),
                margin: const EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                  color: themeController.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  // Enhanced border for selected items
                  border: _isItemSelected(category)
                      ? Border.all(color: appcolor, width: 3)
                      : Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
                ),
                child: items.isEmpty
                    ? Center(
                  child: Icon(
                    _getIconForCategory(category),
                    color: Colors.grey,
                    size: MediaQuery.of(context).size.width * 0.07,
                  ),
                )
                    : _buildImageWithLoadingEnhanced(category, items),
              );
            },
          ),
        );
      }



    void _animateItemChange(String category) {
      setState(() {
        // Trigger rebuild with animation
      });

      // Add haptic feedback
      HapticFeedback.selectionClick();

      Future.delayed(Duration(milliseconds: 100), () {
        setState(() {
          // Additional UI updates if needed
        });
      });
    }


    bool _isItemSelected(String category) {
      switch (category) {
        case 'shirt':
          return selectedShirtId != null;
        case 'pant':
          return selectedPantId != null;
        case 'shoes':
          return selectedShoeId != null;
        case 'accessories':
          return selectedAccessoryId != null;
        default:
          return false;
      }
    }

    WardrobeItem? _getSelectedItemForCategory(
        String category, List<WardrobeItem> items)
    {
      String? selectedId;

      switch (category) {
        case 'shirt':
          selectedId = selectedShirtId;
          break;
        case 'pant':
          selectedId = selectedPantId;
          break;
        case 'shoes':
          selectedId = selectedShoeId;
          break;
        case 'accessories':  // Changed from 'accessory' to 'accessories'
          selectedId = selectedAccessoryId;
          break;
      }

      if (selectedId == null) return null;

      for (var item in items) {
        if (item.id == selectedId) {
          return item;
        }
      }

      return null;
    }

    void _showItemSelectionDialog(
        String category, ValueNotifier<List<WardrobeItem>> notifier)
    {
      if (notifier.value.isEmpty) {
        showAppSnackBar(context,'No ${category} available in your wardrobe', backgroundColor: Colors.red);


        return;
      }
      final localizations = AppLocalizations.of(context)!;

      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select ${category.substring(0, 1).toUpperCase() + category.substring(1)}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: appcolor,
                  ),
                ),
                SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: Container(
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: notifier.value.length,
                      itemBuilder: (context, index) {
                        final item = notifier.value[index];
                        bool isSelected = false;

                        switch (category) {
                          case 'shirt':
                            isSelected = selectedShirtId == item.id;
                            break;
                          case 'pant':
                            isSelected = selectedPantId == item.id;
                            break;
                          case 'shoes':
                            isSelected = selectedShoeId == item.id;
                            break;
                          case 'accessories':
                            isSelected = selectedAccessoryId == item.id;
                            break;
                        }

                        return GestureDetector(
                          onTap: () {
                            switch (category) {
                              case 'shirt':
                                setState(() {
                                  selectedShirtId = item.id;
                                });
                                break;
                              case 'pant':
                                setState(() {
                                  selectedPantId = item.id;
                                });
                                break;
                              case 'shoes':
                                setState(() {
                                  selectedShoeId = item.id;
                                });
                                break;
                              case 'accessories':
                                setState(() {
                                  selectedAccessoryId = item.id;
                                });
                                break;
                            }
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(color: appcolor, width: 2)
                                  : Border.all(color: Colors.grey.shade300),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                GestureDetector(
                                  onLongPress: () {
                                    _showFullImageDialog(context, item.imageUrl!);
                                  },
                                  child: Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.network(
                                        item.imageUrl ?? '',
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Center(
                                            child: Icon(
                                              _getIconForCategory(category),
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: Container(
                                      padding: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: appcolor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        localizations.cancel,
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    IconData _getIconForCategory(String category) {
      switch (category.toLowerCase()) {
        case 'shirt':
          return FontAwesomeIcons.shirt; // T-shirt icon
        case 'pant':
          return FontAwesomeIcons.personHalfDress; // Clothes/vest icon
        case 'shoes':
          return FontAwesomeIcons.shoePrints; // Shoe icon
        case 'accessories':
          return FontAwesomeIcons.glasses; // Glasses icon
        default:
          return FontAwesomeIcons.tag; // Generic category icon
      }
    }
    void _handleRegionSwipe(String region, DragEndDetails details) {
      // Prevent swipe if currently generating
      if (_isSwipeGenerating || _isGeneratingAvatar) {
        showAppSnackBar(context,'Please wait, avatar is being generated...', backgroundColor: appcolor);

        return;
      }

      // Check horizontal velocity for left/right swipe
      double horizontalVelocity = details.velocity.pixelsPerSecond.dx;
      const double minVelocity = 300.0; // Reduced for more sensitive detection

      if (horizontalVelocity.abs() < minVelocity) return;

      // Determine swipe direction
      String direction = horizontalVelocity > 0 ? 'previous' : 'next';

      // Add haptic feedback
      HapticFeedback.selectionClick();

      // Handle swipe based on region
      switch (region) {
        case 'shirt':
          _handleShirtSwipe(direction);
          break;
        case 'pant':
          _handlePantSwipe(direction);
          break;
        case 'shoes':
          _handleShoeSwipe(direction);
          break;
      }
    }

    Widget _buildAvatarColumn() {
      return ValueListenableBuilder<UserProfileModel?>(
        valueListenable: _profileController.profileNotifier,
        builder: (context, userProfile, child) {
          final currentAvatarImage = _avatarUrl?.isNotEmpty == true
              ? _avatarUrl
              : _getCurrentAvatarImage(userProfile);

          if (currentAvatarImage != null && currentAvatarImage.isNotEmpty) {
            profileImage = currentAvatarImage;
          }

          final isImageValid = currentAvatarImage != null && currentAvatarImage.isNotEmpty;

          return Container(
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Avatar image with region-specific gesture detection
                Container(
                  width: Responsive.width(350),
                  height: Responsive.height(350),
                  child: Stack(
                    children: [
                      // Main avatar image
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: (_isLoading || !isImageValid || _isSwipeGenerating)
                            ? Center(
                          key: const ValueKey('loading'),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                            ],
                          ),
                        )
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            currentAvatarImage,
                            key: ValueKey(currentAvatarImage),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: LoadingAnimationWidget.fourRotatingDots(
                           color:appcolor,size:30
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.error,
                                  color: Colors.grey,
                                  size: 50,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Invisible overlay regions for swipe detection
                      if (isImageValid && !_isSwipeGenerating && !_isGeneratingAvatar) ...[
                        // Shirt region (top 40% of image)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: Responsive.height(350) * 0.6, // 40% for shirt
                          child: GestureDetector(
                            onPanEnd: (details) => _handleRegionSwipe('shirt', details),
                            child: Container(
                              decoration: BoxDecoration(
                                // Uncomment for debugging - shows region boundaries
                                // color: Colors.red.withOpacity(0.2),
                                // border: Border.all(color: Colors.red, width: 2),
                              ),
                              child: Center(
                                child: _isSwipeGenerating
                                    ? Container()
                                    : Container(

                                ),
                              ),
                            ),
                          ),
                        ),

                        // Pants region (middle 35% of image)
                        Positioned(
                          top: Responsive.height(350) * 0.6, // Start after shirt
                          left: 0,
                          right: 0,
                          height: Responsive.height(350) * 0.3, // 35% for pants
                          child: GestureDetector(
                            onPanEnd: (details) => _handleRegionSwipe('pant', details),
                            child: Container(
                              decoration: BoxDecoration(
                                // Uncomment for debugging
                                // color: Colors.blue.withOpacity(0.2),
                                // border: Border.all(color: Colors.blue, width: 2),
                              ),
                              child: Center(
                                child: _isSwipeGenerating
                                    ? Container()
                                    : Container(

                                ),
                              ),
                            ),
                          ),
                        ),

                        // Shoes region (bottom 25% of image)
                        Positioned(
                          top: Responsive.height(350) * 0.9, // Start after pants
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onPanEnd: (details) => _handleRegionSwipe('shoes', details),
                            child: Container(
                              decoration: BoxDecoration(
                                // Uncomment for debugging
                                // color: Colors.green.withOpacity(0.2),
                                // border: Border.all(color: Colors.green, width: 2),
                              ),
                              child: Center(
                                child: _isSwipeGenerating
                                    ? Container()
                                    : Container(

                                  // ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Loading overlay when generating
                if (_isSwipeGenerating || _isGeneratingAvatar)
                  Container(
                    width: Responsive.width(350),
                    height: Responsive.height(350),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LoadingAnimationWidget.fourRotatingDots(
                            color:appcolor,size:20
                          ),
                          SizedBox(height: 15),
                          Text(
                            'Generating Avatar...',
                            style: GoogleFonts.poppins(
                              color: appcolor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    }


    Widget _buildThirdColumn() {
      final localizations = AppLocalizations.of(context)!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: _isGeneratingAvatar
                    ? null
                    : () async {
                  _showAnimatedCategoryDialog(context);
                //  _generateAvatar(context);
                }, // Call the generate avatar method
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: Responsive.width(4),
                      vertical: Responsive.height(5)),
                  height: Responsive.height(30),
                  decoration: BoxDecoration(
                    color: appcolor.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(Responsive.radius(30)),
                  ),
                  child: Row(
                    children: [
                      if (_isGeneratingAvatar)
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: LoadingAnimationWidget.fourRotatingDots(
                              color:appcolor,size:20
                          ),
                        )
                      else
                        Icon(
                          Icons.file_upload_outlined,
                          color: Colors.white,
                          size: Responsive.fontSize(14),
                          weight: 10,
                        ),
                      SizedBox(width: 2),
                      Text(
                        _isGeneratingAvatar
                            ? localizations.uploadingItem
                            : localizations.upload,
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: Responsive.fontSize(8)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
        ],
      );
    }

    void _showAnimatedCategoryDialog(BuildContext context) {
      final localizations = AppLocalizations.of(context)!;
      String? selectedCategory;
      String? selectedSubcategory;
      bool showSubcategories = false;
      List<String> subcategories = [];

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: themeController.white,
                title: Text(
                  showSubcategories
                      ? 'Select ${selectedCategory} Type'
                      : localizations.selectCategory,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.fontSize(18),
                    fontWeight: FontWeight.w600,
                    color: appcolor,
                  ),
                  textAlign: TextAlign.center,
                ),
                content: AnimatedContainer(
                  duration: Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!showSubcategories) ...[
                        // Main categories
                        AnimatedOpacity(
                          duration: Duration(milliseconds: 400),
                          opacity: showSubcategories ? 0.0 : 1.0,
                          child: Column(
                            children: [
                              _buildAnimatedCategoryButton(
                                  'Shirts', selectedCategory, (category) {
                                setState(() {
                                  selectedCategory = category;
                                  subcategories = getSubcategoriesForCategory(
                                      context, category);
                                  selectedSubcategory = null;
                                  Future.delayed(Duration(milliseconds: 100), () {
                                    setState(() {
                                      showSubcategories = true;
                                    });
                                  });
                                });
                              }),
                              _buildAnimatedCategoryButton(
                                  localizations.accessories, selectedCategory,
                                      (category) {
                                    setState(() {
                                      selectedCategory = category;
                                      subcategories = getSubcategoriesForCategory(
                                          context, category);
                                      selectedSubcategory = null;
                                      Future.delayed(Duration(milliseconds: 100), () {
                                        setState(() {
                                          showSubcategories = true;
                                        });
                                      });
                                    });
                                  }),
                              _buildAnimatedCategoryButton(
                                  'Pants', selectedCategory, (category) {
                                setState(() {
                                  selectedCategory = category;
                                  subcategories = getSubcategoriesForCategory(
                                      context, category);
                                  selectedSubcategory = null;
                                  Future.delayed(Duration(milliseconds: 100), () {
                                    setState(() {
                                      showSubcategories = true;
                                    });
                                  });
                                });
                              }),
                              _buildAnimatedCategoryButton(
                                  'Shoes', selectedCategory, (category) {
                                setState(() {
                                  selectedCategory = category;
                                  subcategories = getSubcategoriesForCategory(
                                      context, category);
                                  selectedSubcategory = null;
                                  Future.delayed(Duration(milliseconds: 100), () {
                                    setState(() {
                                      showSubcategories = true;
                                    });
                                  });
                                });
                              }),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Subcategories with animation
                        AnimatedOpacity(
                          duration: Duration(milliseconds: 400),
                          opacity: showSubcategories ? 1.0 : 0.0,
                          child: Column(
                            children: subcategories.map((subcategory) {
                              return _buildAnimatedCategoryButton(
                                subcategory,
                                selectedSubcategory,
                                    (value) {
                                  setState(() {
                                    selectedSubcategory = value;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  if (showSubcategories)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          showSubcategories = false;
                          selectedCategory = null;
                        });
                      },
                      child: Text(
                        localizations.back,
                        style: GoogleFonts.poppins(color: themeController.black),
                      ),
                    )
                  else
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        localizations.cancel,
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    ),
                  TextButton(
                    onPressed: (showSubcategories && selectedSubcategory != null)
                        ? () {
                      Navigator.of(context).pop();
                      _openCameraWithGoogleVision(
                          selectedCategory!, selectedSubcategory!);
                    }
                        : null,
                    child: Text(
                      localizations.openCamera,
                      style: GoogleFonts.poppins(
                        color: (showSubcategories && selectedSubcategory != null)
                            ? appcolor
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    // Helper method to build animated category buttons
    Widget _buildAnimatedCategoryButton(
        String category, String? selectedCategory, Function(String) onSelect) {
      bool isSelected = selectedCategory == category;

      return AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(vertical: Responsive.height(4.0)),
        child: InkWell(
          onTap: () => onSelect(category),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: Responsive.height(12)),
            decoration: BoxDecoration(
              color: isSelected ? appcolor : Colors.white,
              borderRadius: BorderRadius.circular(Responsive.radius(8)),
              border: Border.all(
                color: isSelected ? appcolor : Colors.grey.shade300,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: appcolor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
              ],
            ),
            child: Center(
              child: Text(
                category,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Helper method to get subcategories based on selected category
    List<String> getSubcategoriesForCategory(
        BuildContext context, String category)
    {
      final loc = AppLocalizations.of(context)!;

      switch (category) {
        case 'Shirts':
          return [
            loc.tShirt,
            loc.halfShirt,
            loc.casualShirt,
            loc.dressShirt,
            loc.poloShirt,
          ];
        case 'Accessories':
          return [
            loc.necklace,
            loc.bracelet,
            loc.earring,
            loc.watch,
            loc.belt,
            loc.hat,
            loc.scarf,
          ];
        case 'Pants':
          return [
            loc.jeans,
            loc.trousers,
            loc.shorts,
            loc.cargo,
            loc.trackPants,
            loc.formalPants,
          ];
        case 'Shoes':
          return [
            loc.sneakers,
            loc.formalShoes,
            loc.boots,
            loc.loafers,
            loc.sandals,
            loc.sportsShoes,
          ];
        default:
          return [];
      }
    }

    // Method to open camera with Google Vision integration
    void _openCameraWithGoogleVision(String category, String subcategory) async {
      final loc = AppLocalizations.of(context)!;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Center(
              child: Container(
                padding: Responsive.allPadding(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Responsive.radius(10)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LoadingAnimationWidget.fourRotatingDots(
                        color:appcolor,size:20
                    ),
                    SizedBox(height: Responsive.height(16)),
                    Text(
                      loc.openingCamera,
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

      try {
        // Pick an image from camera
        final XFile? image = await _picker.pickImage(source: ImageSource.camera);

        // Close loading dialog
        Navigator.pop(context);

        if (image != null) {
          File imageFile = File(image.path);

          // Here you would normally implement Google Vision AI integration
          // For now, we'll just show a confirmation dialog
          _showImageCapturedDialog(category, subcategory, imageFile);
        }
      } catch (e) {
        // Close loading dialog in case of error
        Navigator.pop(context);

        // Show error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(loc.error(error)),
              content: Text(loc.failedToOpenCamera(e.toString())),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(loc.ok),
                ),
              ],
            );
          },
        );
      }
    }


    void _showImageCapturedDialog(
        String category, String subcategory, File imageFile)
    {
      _isUploading = false;
      _uploadProgress = 0.0;
      final loc = AppLocalizations.of(context)!;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Text(
                  _isUploading ? loc.uploadingItem : loc.itemCaptured,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: appcolor,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_isUploading)
                      Text(
                        loc.itemSuccessfullyCaptured(subcategory),
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    SizedBox(height: 16),
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(imageFile),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (_isUploading) ...[
                      SizedBox(height: 20),
                      Column(
                        children: [
                          // Custom loading animation (similar to OTP screen)
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: appcolor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: LoadingAnimationWidget.fourRotatingDots(
                                color:appcolor,size:20
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            loc.addingToWardrobe,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${(_uploadProgress * 100).toInt()}%',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: appcolor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                actions: _isUploading
                    ? [] // No buttons when loading
                    : [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      loc.cancel,
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      // Start upload process with loading animation
                      setState(() {
                        _isUploading = true;
                        _uploadProgress = 0.0;
                      });

                      // Start the progress animation
                      _startUploadProgressAnimation(setState);
                      // bool hasInternet =
                      // await checkInternetAndShowDialog(context);
                      // if (!hasInternet) {
                      //   return;
                      // }
                      try {
                        await _wardrobeController.uploadWardrobeItem(
                            category: category,
                            subCategory: subcategory,
                            imageFile: imageFile,
                            avatarurl: profileImage!,
                            context: context,
                            token: token);
                        _completeUploadProgress(setState);
  //                       if(_wardrobeController.errorNotifier.value!=null){
  //
  //                         showAppSnackBar(context,'Failed to upload image:Network failure', backgroundColor: Colors.red);
  // return;
  //                       }



                        // Slight delay to show 100% completion
                        // await Future.delayed(Duration(milliseconds: 5000));
                        // await _getUserInfoAndLoadItems();
                        await Future.delayed(Duration(milliseconds: 5000));
                        await _getUserInfoAndLoadItems();

                        _uploadProgressTimer?.cancel();
                        Navigator.pop(context);
                      } catch (e) {
                        // Complete progress animation even on error
                        await _completeUploadProgress(setState);

                        await Future.delayed(Duration(milliseconds: 500));

                        if (context.mounted) {
                          _uploadProgressTimer?.cancel();
                          Navigator.pop(context);
                          showAppSnackBar(context,'Failed to save image: ${e.toString()}', backgroundColor: Colors.red);


                        }
                        await _getUserInfoAndLoadItems();
                      }},

                    child: Text(
                      loc.addToWardrobe,
                      style: GoogleFonts.poppins(
                        color: appcolor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    }




    void _startUploadProgressAnimation(StateSetter setState) {
      // Cancel existing timer if any
      _uploadProgressTimer?.cancel();

      // Create a simulated loading animation
      const totalDuration = 3000; // 3 seconds in milliseconds
      const interval = 50; // Update every 50ms for smoother animation
      const steps = totalDuration ~/ interval;
      const incrementPerStep = 0.95 / steps; // Reach 95% in the given duration

      _uploadProgressTimer =
          Timer.periodic(Duration(milliseconds: interval), (timer) {
            if (_uploadProgress >= 0.95) {
              timer.cancel();
            } else {
              setState(() {
                _uploadProgress += incrementPerStep;
                if (_uploadProgress > 0.95) _uploadProgress = 0.95; // Cap at 95%
              });
            }
          });
    }

  // Helper method to complete the progress animation
    Future<void> _completeUploadProgress(StateSetter setState) async {
      _uploadProgressTimer?.cancel();

      // Complete the progress to 100% with a smooth animation
      _uploadProgressTimer = Timer.periodic(Duration(milliseconds: 30), (timer) {
        if (_uploadProgress >= 1.0) {
          timer.cancel();
        } else {
          setState(() {
            _uploadProgress += 0.05;
            if (_uploadProgress > 1.0) _uploadProgress = 1.0;
          });
        }
      });
    }
  Widget _buildCalendarSection(WardrobeController controller) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          loc.calendarTitle,
          style: GoogleFonts.poppins(
            color: appcolor,
            fontSize: Responsive.fontSize(18),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: Responsive.height(8)),
        ValueListenableBuilder<DateTime>(
          valueListenable: controller.selectedDayNotifier,
          builder: (context, DateTime selectedDay, _) {
            return ValueListenableBuilder<DateTime>(
              valueListenable: controller.focusedDayNotifier,
              builder: (context, DateTime focusedDay, _) {
                return ValueListenableBuilder<CalendarFormat>(
                  valueListenable: controller.calendarFormatNotifier,
                  builder: (context, CalendarFormat calendarFormat, _) {
                    return ValueListenableBuilder<List<AvatarData>>(
                      valueListenable: _outfitController.avatarDatesNotifier,
                      builder: (context, List<AvatarData> avatarDates, _) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(Responsive.radius(16)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TableCalendar(
                            availableGestures: AvailableGestures.none,
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: focusedDay,
                            calendarFormat: calendarFormat,
                            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                            onDaySelected: (selectedDay, focusedDay) {
                              controller.selectedDayNotifier.value = selectedDay;
                              controller.focusedDayNotifier.value = focusedDay;
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                              _checkExistingOutfit(selectedDay);
                            },
                            onDayLongPressed: (selectedDay, focusedDay) {
                              _showAvatarMessage(selectedDay);
                            },
                            onPageChanged: (focusedDay) {
                              controller.focusedDayNotifier.value = focusedDay;
                            },
                            eventLoader: (day) {
                              if (isSameDay(day, _focusedDay)) return [];
                              if (_outfitController.hasAvatarForDate(day)) {
                                return ['avatar'];
                              }
                              return [];
                            },
                            calendarStyle: CalendarStyle(
                              markersMaxCount: 200,
                              outsideDaysVisible: false,
                              isTodayHighlighted: true,
                              todayDecoration: BoxDecoration(
                                color: appcolor.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: BoxDecoration(
                                color: appcolor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            headerStyle: HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                              titleTextStyle: GoogleFonts.poppins(
                                fontSize: Responsive.fontSize(16),
                                fontWeight: FontWeight.w600,
                                color: appcolor,
                              ),
                              leftChevronIcon: Icon(
                                Icons.chevron_left,
                                color: appcolor,
                              ),
                              rightChevronIcon: Icon(
                                Icons.chevron_right,
                                color: appcolor,
                              ),
                            ),
                            calendarBuilders: CalendarBuilders(
                              selectedBuilder: (context, date, _) {
                                return Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: appcolor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${date.day}',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                );
                              },
                              todayBuilder: (context, date, _) {
                                return Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: appcolor.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${date.day}',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                );
                              },
                              markerBuilder: (context, day, events) {
                                if (events.isEmpty || isSameDay(day, DateTime.now())) {
                                  return const SizedBox(); // ❌ No dot on today
                                }
                                return Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 4, right: 4),
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color:appcolor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

// Method to show avatar message popup on long press
  void _showAvatarMessage(DateTime date) {
    final message = _outfitController.getMessageForDate(date);

    if (message != null && message.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Avatar Message',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: appcolor,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    DateFormat('dd/MM/yyyy').format(date),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: appcolor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      message,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Close',
                      style: GoogleFonts.poppins(
                        color: appcolor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      // Show message that no avatar message exists for this date
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No avatar message for this date'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
class AvatarRegion {
  static const int SHIRT_START = 0;
  static const int SHIRT_END = 512;
  static const int PANT_START = 513;
  static const int PANT_END = 1300;
  static const int SHOE_START = 1301;
  static const int SHOE_END = 1536;
}
