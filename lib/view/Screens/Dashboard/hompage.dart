import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitlip_app/routes/App_routes.dart';
import 'package:fitlip_app/controllers/themecontroller.dart';
import 'package:fitlip_app/view/Screens/Dashboard/selectbackground.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/fast_avatar_controller.dart';
import '../../../services/fast_swiping_service.dart';
import '../../../services/fast_background_service.dart';
import '../../../controllers/profile_controller.dart';
import '../../../controllers/wardrobe_controller.dart';
import '../../../controllers/outfit_controller.dart';
import '../../../main.dart';
import '../../../model/background_image_model.dart';
import '../../../model/outfit_model.dart';
import '../../../model/profile_model.dart';
import '../../../model/wardrobe_model.dart';
import '../../../services/upload_isolate_service.dart';
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
  DateTime? _selectedDay;
  final FastAvatarController _avatarController = FastAvatarController();
  bool _isGeneratingAvatar = false;
  final ImagePicker _picker = ImagePicker();
  String? _avatarUrl;

  // Optimized avatar URLs for faster loading
  final List<String> avatarUrls = [
    'https://fitlit-assets.s3.us-east-2.amazonaws.com/wardrobe/1747930630870-image.png',
    'https://fitlit-assets.s3.us-east-2.amazonaws.com/wardrobe/1747934549164-image.png',
    'https://fitlit-assets.s3.us-east-2.amazonaws.com/wardrobe/1747935456493-image.png',
    'https://fitlit-assets.s3.us-east-2.amazonaws.com/wardrobe/1747937370671-image.png',
    'https://fitlit-assets.s3.us-east-2.amazonaws.com/wardrobe/1747938354346-image.png',
    'https://fitlit-assets.s3.us-east-2.amazonaws.com/wardrobe/1747938907353-image.png',
  ];

  int currentIndexx = 0;
  String? staticurl = "https://fitlit-assets.s3.us-east-2.amazonaws.com/wardrobe/1747930630870-image.png";
  bool _isLoadingg = false;

  // Fast navigation methods
  void _goToNext() {
    setState(() {
      currentIndexx = (currentIndexx + 1) % avatarUrls.length;
      staticurl = avatarUrls[currentIndexx];
    });
  }

  void _goToPrevious() {
    setState(() {
      currentIndexx = (currentIndexx - 1 + avatarUrls.length) % avatarUrls.length;
      staticurl = avatarUrls[currentIndexx];
    });
  }

  SharedPreferences? _prefs;

  // Fast swiping state
  int _currentShirtIndex = 0;
  int _currentPantIndex = 0;
  int _currentShoeIndex = 0;
  int _currentGlassesIndex = 0;
  int _currentCapIndex = 0;
  bool _isSwipeGenerating = false;

  String? userProfileImage;
  String? profileImage;
  int _currentAvatarIndex = 0;
  String outfitMessage = "";
  String? currenturl;

  // Single wardrobe controller instance (fixed duplication)
  final WardrobeController _wardrobeController = WardrobeController();
  final OutfitController _outfitController = OutfitController();
  AnimationController? _avatarAnimationController;

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
  TextEditingController messagecontroller = TextEditingController();
  String? selectedShirtId;
  String? selectedPantId;
  String? selectedShoeId;
  final FastBackgroundService _backgroundService = FastBackgroundService();
  String? selectedAccessoryId;
  List<BackgroundImageModel> _apiBackgrounds = [];
  bool _isLoadingBackgrounds = false;
  String _currentBackgroundPath = 'assets/Images/back1.png';
  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadBackgroundImages();
    UploadIsolateService.initialize();

    // Listen for upload completion
    _listenForUploadCompletion();
    _loadUserProfile();
    _getUserInfoAndLoadItems();
    _loadAllUserAvatars(); // Add this line
    _wardrobeController.statusNotifier.addListener(_handleStatusChange);
    _avatarController.statusNotifier.addListener(_handleAvatarStatusChange);
    _loadAvatarDates();
    // _checkExistingOutfit(_focusedDay);
  }

  Future<void> _startBackgroundUpload(
      String category, String subcategory, File imageFile) async
  {
    try {
      print("cojgdsuds");
      print(category);
      print(subcategory);
      print(imageFile);

      final uploadId = await _wardrobeController.uploadWardrobeItemInBackground(
        category: category,
        subCategory: subcategory,
        imageFile: imageFile,
        avatarurl: _profileController.profileNotifier.value!.profileImage,
        token: token,
      );

      // Show initial success message
      showAppSnackBar(
        context,
        'Upload started! Processing in background...',
        backgroundColor: appcolor,
      );

      // Wait 5 seconds then show background processing message
      Timer(Duration(seconds: 5), () {
        if (mounted) {
          _showBackgroundProcessingNotification();
        }
      });
    } catch (e) {
      print(e.toString());
      showAppSnackBar(
        context,
        'Failed to start upload: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    }
  }

  void _showBackgroundProcessingNotification() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(Icons.cloud_upload, color: appcolor),
              SizedBox(width: 8),
              Text(
                'Processing in Background',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: appcolor,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your item is being processed in the background. You can continue using the app normally.',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                'You\'ll be notified when it\'s ready!',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showUploadProgressDialog();
              },
              child: Text(
                'View Progress',
                style: GoogleFonts.poppins(color: appcolor),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: GoogleFonts.poppins(
                    color: appcolor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _listenForUploadCompletion() {
    _wardrobeController.uploadProgressNotifier.addListener(() {
      if (!mounted) return;

      final uploads = _wardrobeController.uploadProgressNotifier.value;

      for (final progress in uploads.values) {
        if (progress.isCompleted && !progress.hasShownNotification) {
          // Mark as notification shown to prevent duplicate notifications
          progress.hasShownNotification = true;

          // Show success notification
          showAppSnackBar(
            context,
            '${progress.subCategory} added to wardrobe successfully!',
            backgroundColor: appcolor,
          );

          // Refresh wardrobe items after small delay
          Future.delayed(Duration(milliseconds: 500), () {
            if (mounted) {
              _getUserInfoAndLoadItems();
              setState(() {}); // Force rebuild to update UI
            }
          });
        } else if (progress.isError && !progress.hasShownNotification) {
          // Mark as notification shown
          progress.hasShownNotification = true;

          // Show error notification
          showAppSnackBar(
            context,
            'Failed to upload ${progress.subCategory}: ${progress.error}',
            backgroundColor: Colors.red,
          );
        }
      }
    });
  }

  Future<void> _loadBackgroundImages() async {
    setState(() {
      _isLoadingBackgrounds = true;
    });

    try {
      // Implement this method to get your auth token
      if (token != null) {
        final success = await _backgroundService.getAllBackgroundImages(
            token: token!);
        if (success) {
          setState(() {
            _apiBackgrounds =
                _backgroundService.backgroundImagesNotifier.value;
          });
          print("teh first ");
          print(_apiBackgrounds.length);
          print(_apiBackgrounds.first);
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

  void _handleStatusChange() {
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
            FastAvatarStatus.loading;
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

  // ⚡ Optimized fast shirt swiping
  void _handleShirtSwipe(String direction) async {
    final shirts = _wardrobeController.shirtsNotifier.value;
    if (shirts.isEmpty) {
      showAppSnackBar(context, 'No shirts available in your wardrobe',
          backgroundColor: appcolor);
      return;
    }

    // Use optimized fast swiping service
    final result = await FastSwipingService.handleSmartSwipe(
      category: 'shirt',
      direction: direction == 'next' ? 'right' : 'left',
      items: shirts,
      currentIndex: _currentShirtIndex,
      avatarController: _avatarController,
      currentIds: {
        'shirt': selectedShirtId,
        'pant': selectedPantId,
        'shoe': selectedShoeId,
        'accessory': selectedAccessoryId,
      },
      preloadNext: true,
    );

    if (result.success && result.newIndex != null) {
      setState(() {
        _currentShirtIndex = result.newIndex!;
        selectedShirtId = result.selectedItem!.id;
        if (result.avatarUrl != null) {
          _avatarUrl = result.avatarUrl;
          profileImage = result.avatarUrl;
        }
      });
      _animateItemChange('shirt');
    }
  }

  // ⚡ Optimized fast pant swiping
  void _handlePantSwipe(String direction) async {
    final pants = _wardrobeController.pantsNotifier.value;
    if (pants.isEmpty) {
      showAppSnackBar(context, 'No pants available in your wardrobe',
          backgroundColor: appcolor);
      return;
    }

    // Use optimized fast swiping service
    final result = await FastSwipingService.handleSmartSwipe(
      category: 'pant',
      direction: direction == 'next' ? 'right' : 'left',
      items: pants,
      currentIndex: _currentPantIndex,
      avatarController: _avatarController,
      currentIds: {
        'shirt': selectedShirtId,
        'pant': selectedPantId,
        'shoe': selectedShoeId,
        'accessory': selectedAccessoryId,
      },
      preloadNext: true,
    );

    if (result.success && result.newIndex != null) {
      setState(() {
        _currentPantIndex = result.newIndex!;
        selectedPantId = result.selectedItem!.id;
        if (result.avatarUrl != null) {
          _avatarUrl = result.avatarUrl;
          profileImage = result.avatarUrl;
        }
      });
      _animateItemChange('pant');
    }
  }

  // ⚡ Optimized fast shoe swiping
  void _handleShoeSwipe(String direction) async {
    final shoes = _wardrobeController.shoesNotifier.value;
    if (shoes.isEmpty) {
      showAppSnackBar(context, 'No shoes available in your wardrobe',
          backgroundColor: appcolor);
      return;
    }

    // Use optimized fast swiping service
    final result = await FastSwipingService.handleSmartSwipe(
      category: 'shoe',
      direction: direction == 'next' ? 'right' : 'left',
      items: shoes,
      currentIndex: _currentShoeIndex,
      avatarController: _avatarController,
      currentIds: {
        'shirt': selectedShirtId,
        'pant': selectedPantId,
        'shoe': selectedShoeId,
        'accessory': selectedAccessoryId,
      },
      preloadNext: true,
    );

    if (result.success && result.newIndex != null) {
      setState(() {
        _currentShoeIndex = result.newIndex!;
        selectedShoeId = result.selectedItem!.id;
        if (result.avatarUrl != null) {
          _avatarUrl = result.avatarUrl;
          profileImage = result.avatarUrl;
        }
      });
      _animateItemChange('shoe');
    }
  }

  // ⚡ Optimized fast glasses swiping (accessories filtered by subCategory)
  void _handleGlassesSwipe(String direction) async {
    final allAccessories = _wardrobeController.accessoriesNotifier.value;
    final glasses = allAccessories
        .where((w) => (w.subCategory.toLowerCase() == 'glasses' || w.subCategory.toLowerCase() == 'spectacles'))
        .toList();
    if (glasses.isEmpty) {
      showAppSnackBar(context, 'No glasses available in your wardrobe',
          backgroundColor: appcolor);
      return;
    }

    final result = await FastSwipingService.handleSmartSwipe(
      category: 'accessory',
      direction: direction == 'next' ? 'right' : 'left',
      items: glasses,
      currentIndex: _currentGlassesIndex,
      avatarController: _avatarController,
      currentIds: {
        'shirt': selectedShirtId,
        'pant': selectedPantId,
        'shoe': selectedShoeId,
        'accessory': selectedAccessoryId,
      },
      preloadNext: true,
    );

    if (result.success && result.newIndex != null) {
      setState(() {
        _currentGlassesIndex = result.newIndex!;
        selectedAccessoryId = result.selectedItem!.id;
        if (result.avatarUrl != null) {
          _avatarUrl = result.avatarUrl;
          profileImage = result.avatarUrl;
        }
      });
      _animateItemChange('accessory');
    }
  }

  // ⚡ Optimized fast cap swiping (accessories filtered by subCategory)
  void _handleCapSwipe(String direction) async {
    final allAccessories = _wardrobeController.accessoriesNotifier.value;
    final caps = allAccessories
        .where((w) => (w.subCategory.toLowerCase() == 'cap' || w.subCategory.toLowerCase() == 'hat'))
        .toList();
    if (caps.isEmpty) {
      showAppSnackBar(context, 'No caps available in your wardrobe',
          backgroundColor: appcolor);
      return;
    }

    final result = await FastSwipingService.handleSmartSwipe(
      category: 'accessory',
      direction: direction == 'next' ? 'right' : 'left',
      items: caps,
      currentIndex: _currentCapIndex,
      avatarController: _avatarController,
      currentIds: {
        'shirt': selectedShirtId,
        'pant': selectedPantId,
        'shoe': selectedShoeId,
        'accessory': selectedAccessoryId,
      },
      preloadNext: true,
    );

    if (result.success && result.newIndex != null) {
      setState(() {
        _currentCapIndex = result.newIndex!;
        selectedAccessoryId = result.selectedItem!.id;
        if (result.avatarUrl != null) {
          _avatarUrl = result.avatarUrl;
          profileImage = result.avatarUrl;
        }
      });
      _animateItemChange('accessory');
    }
  }

  Future<void> _generateAvatarFromSwipe(
      String category, String direction) async
  {
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
      showAppSnackBar(context, 'No shoes available in your wardrobe',
          backgroundColor: appcolor);

      return;
    }

    try {
      setState(() {
        _isSwipeGenerating = true;
      });

      // Show swipe feedback
      _showSwipeDirection(category, direction);

      // Use optimized avatar generation (5-30 seconds vs 3+ minutes!)
      // Automatically optimizes for mobile fitness app use case
      await _avatarController.generateOptimizedAvatar(
        shirtColor: '#FF6B6B', // Map shirt ID to color
        pantColor: '#4ECDC4',  // Map pant ID to color
        shoeColor: '#45B7D1',  // Map shoe ID to color
        skinTone: '#FFDBAC',
        hairColor: '#8B4513',
        qualityPreset: 'fitness_optimized', // Optimized for fitness app
        useCase: 'workout', // Optimized for workout scenarios
      );

      // Listen for avatar URL from new system
      if (_avatarController.avatarUrlNotifier.value != null) {
        await _loadAllUserAvatars();

        setState(() {
          _avatarUrl = _avatarController.avatarUrlNotifier.value!;
          profileImage = _avatarController.avatarUrlNotifier.value!;
          _isSwipeGenerating = false;
        });
      } else {
        setState(() {
          _isSwipeGenerating = false;
        });
        showAppSnackBar(context, 'Failed to generate avatar - much faster now!',
            backgroundColor: appcolor);
      }
    } catch (e) {
      setState(() {
        _isSwipeGenerating = false;
      });
      showAppSnackBar(context, 'Error generating avatar: ${e.toString()}',
          backgroundColor: appcolor);
    }
  }

  // Updated image container without emojis
  Widget _buildImageWithLoadingEnhanced(
      String category, List<WardrobeItem> items)
  {
    WardrobeItem? selectedItem = _getSelectedItemForCategory(category, items);

    if (selectedItem != null) {
      return GestureDetector(
        onLongPress: () {
          _showFullImageDialog(context, selectedItem.imageUrl!);
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl:selectedItem.imageUrl ?? '',
              fit: BoxFit.cover,

              placeholder: (context, url) => Center(
                child: Container(
                  child: LoadingAnimationWidget.fourRotatingDots(
                    color: appcolor,
                    size: 15,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Show first item if no selection
    if (items.isNotEmpty) {
      return GestureDetector(
        onLongPress: () {
          _showFullImageDialog(context, items.first.imageUrl!);
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              items.first.imageUrl ?? '',
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: LoadingAnimationWidget.fourRotatingDots(
                    color: appcolor,
                    size: 15,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(
                    _getIconForCategory(category),
                    color: Colors.grey,
                    size: MediaQuery.of(context).size.width * 0.05,
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    return Center(
      child: Icon(
        _getIconForCategory(category),
        color: Colors.grey,
        size: MediaQuery.of(context).size.width * 0.07,
      ),
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
      selectedAccessoryId =
          _wardrobeController.accessoriesNotifier.value.last.id;
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
      final outfit = await _outfitController.getOutfitByDate(
          token: token!,
          date: date,
          id: _profileController.profileNotifier.value!.id);
      print("coming ios ${outfit?.backgroundimage}");

      if (outfit?.success == true) {
        setState(() {
          _avatarUrl = outfit?.avatar_url; // Update the avatar URL state
          currenturl = outfit?.backgroundimage;
          // Also update profileImage for saving
        });
        _updateAvatarBasedOnOutfit(outfit?.avatar_url);

        // Show brief success message that an outfit was found
      } else {}

      setState(() {
        isLoadingItems = false;
        currenturl="";
        // Hide loading indicator
      });
    } catch (e) {
      print("Error checking existing outfit: $e");
      setState(() {
        isLoadingItems = false;
      });
    }
  }

  void _updateAvatarBasedOnOutfit(outfit) {
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
  Future<Uint8List> _loadImageBytes(String pathOrUrl, {bool isNetwork = false}) async {
    if (isNetwork) {
      final response = await http.get(Uri.parse(pathOrUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to load image from network: $pathOrUrl');
      }
    } else {
      return await rootBundle.load(pathOrUrl).then((bd) => bd.buffer.asUint8List());
    }
  }

// Main logic to merge two images and share them
  Future<File> mergeAndSaveStackedImage({
    required String backgroundUrl,
    required String avatarUrl,
  }) async {
    try {
      // Load image bytes
      final bgBytes = await _loadImageBytes(backgroundUrl, isNetwork: true);
      final avatarBytes = await _loadImageBytes(avatarUrl, isNetwork: true);

      // Decode both images
      final background = img.decodeImage(bgBytes);
      final avatar = img.decodeImage(avatarBytes);

      if (background == null || avatar == null) {
        throw Exception("One of the images could not be decoded.");
      }

      // Resize avatar (optional)
      final avatarResized = img.copyResize(
        avatar,
        width: (background.width * 0.6).toInt(),
      );

      // Copy background
      img.Image merged = img.copyResize(
        background,
        width: background.width,
        height: background.height,
      );

      // Center position
      final dx = ((background.width - avatarResized.width) / 2).toInt();
      final dy = ((background.height - avatarResized.height) / 2).toInt();

      // Composite avatar onto background
      img.compositeImage(merged, avatarResized, dstX: dx, dstY: dy);

      // Encode PNG
      final combinedBytes = img.encodePng(merged);

      // Save as stackimage.png
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/stackimage.png');
      await file.writeAsBytes(combinedBytes);

      return file;
    } catch (e) {
      print('❌ Error: $e');
      rethrow;
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
      File? mergedFile= await mergeAndSaveStackedImage(
        backgroundUrl: currenturl!,
        avatarUrl: staticurl!,
      );
      // Get the current avatar URL being displayed
      // final currentAvatarUrl =
      // _getCurrentAvatarImage(_profileController.profileNotifier.value);

      // if (currentAvatarUrl == null || currentAvatarUrl.isEmpty) {
      //   setState(() {
      //     isSavingOutfit = false;
      //   });
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text('No avatar available to save'),
      //       backgroundColor: appcolor,
      //     ),
      //   );
      //   return;
      // }
      // if (selectedShirtId == null ||
      //     selectedPantId == null ||
      //     selectedShoeId == null ||
      //     selectedAccessoryId == null) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text("Please select item first,missing item"),
      //       backgroundColor: appcolor,
      //     ),
      //   );
      //   setState(() {
      //     isSavingOutfit = false;
      //   });
      //
      //   return;
      // }

      final result = await _outfitController.saveOutfit(
        token: token!,
        shirtId:  "681e413544c5377f3cdb4575",
        pantId:  "68247bacab8a78ba02e03623",
        shoeId:  "682c271bf00363d7967c29fe",
        accessoryId: "6828e27c408e9791407522c2",
        backgroundimageurl: currenturl,
        message: outfitMessage,
        // accessoryId: selectedAccessoryId ?? "",
        avatarurl: staticurl!,
        file:mergedFile,
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

  // Future<void> _saveOutfit(BuildContext context) async {
  //   // Show confirmation dialog
  //   bool hasInternet = await checkInternetAndShowDialog(context);
  //   if (!hasInternet) {
  //     return;
  //   }
  //   bool confirmed = await _showSaveOutfitConfirmationDialog();
  //   if (!confirmed) return;
  //
  //   setState(() {
  //     isSavingOutfit = true;
  //   });
  //
  //   try {
  //     // Get the current avatar URL being displayed
  //     final currentAvatarUrl =
  //         _getCurrentAvatarImage(_profileController.profileNotifier.value);
  //
  //     if (currentAvatarUrl == null || currentAvatarUrl.isEmpty) {
  //       setState(() {
  //         isSavingOutfit = false;
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('No avatar available to save'),
  //           backgroundColor: appcolor,
  //         ),
  //       );
  //       return;
  //     }
  //     if (selectedShirtId == null ||
  //         selectedPantId == null ||
  //         selectedShoeId == null ||
  //         selectedAccessoryId == null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text("Please select item first,missing item"),
  //           backgroundColor: appcolor,
  //         ),
  //       );
  //       setState(() {
  //         isSavingOutfit = false;
  //       });
  //
  //       return;
  //     }
  //
  //     final result = await _outfitController.saveOutfit(
  //       token: token!,
  //       shirtId: selectedShirtId ?? "",
  //       pantId: selectedPantId ?? "",
  //       shoeId: selectedShoeId ?? "",
  //       accessoryId: selectedAccessoryId,
  //       backgroundimageurl: currenturl,
  //       message: outfitMessage,
  //       // accessoryId: selectedAccessoryId ?? "",
  //       avatarurl: currentAvatarUrl,
  //       date: _selectedDay ?? _focusedDay,
  //     );
  //
  //     setState(() {
  //       isSavingOutfit = false;
  //     });
  //
  //     if (result) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             'Outfit saved successfully for ${_getFormattedDate(_selectedDay ?? _focusedDay)}',
  //             style: GoogleFonts.poppins(
  //               fontSize: 12,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //           backgroundColor: appcolor,
  //           duration: Duration(seconds: 1),
  //           behavior: SnackBarBehavior.floating,
  //           margin: EdgeInsets.all(10),
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //         ),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             'Failed to save outfit',
  //             style: GoogleFonts.poppins(
  //               fontSize: 12,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //           backgroundColor: appcolor,
  //           duration: Duration(seconds: 1),
  //           behavior: SnackBarBehavior.floating,
  //           margin: EdgeInsets.all(10),
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     setState(() {
  //       isSavingOutfit = false;
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           'Error: ${e.toString()}',
  //           style: GoogleFonts.poppins(
  //             fontSize: 12,
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //         backgroundColor: appcolor,
  //         duration: Duration(seconds: 1),
  //         behavior: SnackBarBehavior.floating,
  //         margin: EdgeInsets.all(10),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //       ),
  //     );
  //   }
  // }

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
            currenturl="";
            _currentBackgroundPath = backgroundPath;
          });
          print("haseeb is coming");
          print(_currentBackgroundPath);


          // Reload background images to get the updated status
          await _loadBackgroundImages();

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
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    _backgroundService.dispose();

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
        // await _loadBackgroundImages(); // Added this line
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
                  child: _buildCalendarSection(),
                ),
                SizedBox(
                  height: Responsive.height(40),
                )
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showBackgroundSelectionSheet,
          backgroundColor: appcolor.withOpacity(0.8),
          shape: CircleBorder(),
          child: Image.asset(
            'assets/Icons/home_icon.png',
            scale: 4,
            color: Colors.white,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildBackgroundImage() {
    if (_isLoadingBackgrounds) {
      return Container();
    }

    // Priority 1: Use currenturl if set
    if (currenturl != null && currenturl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: currenturl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: Center(
            child: Icon(
              Icons.broken_image,
              color: Colors.grey,
              size: 50,
            ),
          ),
        ),
        memCacheWidth: (MediaQuery.of(context).size.width * 2).toInt(),
        memCacheHeight: (MediaQuery.of(context).size.height * 2).toInt(),
      );
    }

    // Priority 2: Check API backgrounds
    if (_apiBackgrounds.isEmpty) {
      return Image.asset("assets/Images/new.jpg");
    }

    // Priority 3: Find selected background
    try {
      final selectedBackground = _apiBackgrounds.firstWhere((bg) => bg.status == true);
      currenturl = selectedBackground.imageUrl;

      return CachedNetworkImage(
        imageUrl: selectedBackground.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: Center(
            child: Icon(
              Icons.broken_image,
              color: Colors.grey,
              size: 50,
            ),
          ),
        ),
      );
    } catch (e) {
      // Priority 4: Show first available background
      if (_apiBackgrounds.isNotEmpty) {
        return CachedNetworkImage(
          imageUrl: _apiBackgrounds.first.imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: appcolor,
                size: 20,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: Center(
              child: Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 50,
              ),
            ),
          ),
        );
      }

      // Fallback
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
                      color: appcolor,
                      size: 20
                  );
                }

                return ClipOval(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: userProfile.profileImage.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: userProfile.profileImage,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      placeholder: (context, url) => Center(
                        child: LoadingAnimationWidget.fourRotatingDots(
                          color: appcolor,
                          size: 20,
                        ),
                      ),
                      errorWidget: (context, url, error) => Image.asset(
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
        SizedBox(width: Responsive.width(10)),
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
        SizedBox(width: Responsive.width(40)),
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
                color: appcolor,
                size: 20,
              ),
            )
                : Text(
              localizations.save,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
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
            child: _buildAvatarColumn2(),
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
          return ValueListenableBuilder<Map<String, UploadProgress>>(
            valueListenable: _wardrobeController.uploadProgressNotifier,
            builder: (context, uploadProgress, child) {
              // Check if there's an active upload for this category
              List<UploadProgress> categoryUploads =
                  _getCategoryUploads(category, uploadProgress);
              bool hasActiveUpload = categoryUploads.isNotEmpty;

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
                  // Enhanced border for selected items or active uploads
                  border: _isItemSelected(category)
                      ? Border.all(color: appcolor, width: 3)
                      : hasActiveUpload
                          ? Border.all(
                              color: appcolor.withOpacity(0.7), width: 2)
                          : Border.all(
                              color: Colors.grey.withOpacity(0.3), width: 1),
                ),
                child: Stack(
                  children: [
                    // Main content
                    if (items.isEmpty)
                      Center(
                        child: Icon(
                          _getIconForCategory(category),
                          color: Colors.grey,
                          size: MediaQuery.of(context).size.width * 0.07,
                        ),
                      )
                    else
                      _buildImageWithLoadingEnhanced(category, items),

                    // Upload indicator badge
                    if (hasActiveUpload)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: appcolor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.cloud_upload,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
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

  List<UploadProgress> _getCategoryUploads(
      String category, Map<String, UploadProgress> uploadProgress)
  {
    List<UploadProgress> categoryUploads = [];

    for (var progress in uploadProgress.values) {
      if (!progress.isCompleted &&
          !progress.isError &&
          _matchesCategory(progress.subCategory, category)) {
        categoryUploads.add(progress);
      }
    }

    return categoryUploads;
  }

  bool _matchesCategory(String subCategory, String category) {
    switch (category.toLowerCase()) {
      case 'shirt':
        return subCategory.toLowerCase().contains('shirt') ||
            subCategory.toLowerCase().contains('top') ||
            subCategory.toLowerCase().contains('t-shirt');
      case 'pant':
        return subCategory.toLowerCase().contains('pant') ||
            subCategory.toLowerCase().contains('trouser') ||
            subCategory.toLowerCase().contains('jean');
      case 'shoes':
        return subCategory.toLowerCase().contains('shoe') ||
            subCategory.toLowerCase().contains('sneaker') ||
            subCategory.toLowerCase().contains('boot');
      case 'accessories':
        return subCategory.toLowerCase().contains('accessory') ||
            subCategory.toLowerCase().contains('watch') ||
            subCategory.toLowerCase().contains('belt') ||
            subCategory.toLowerCase().contains('hat');
      default:
        return false;
    }
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
      case 'accessories': // Changed from 'accessory' to 'accessories'
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
                child: ValueListenableBuilder<Map<String, UploadProgress>>(
                  valueListenable: _wardrobeController.uploadProgressNotifier,
                  builder: (context, uploadProgress, child) {
                    // Get active uploads for this category
                    List<UploadProgress> categoryUploads =
                        _getCategoryUploads(category, uploadProgress);

                    // Calculate total grid items (existing items + uploading items)
                    int totalItems =
                        notifier.value.length + categoryUploads.length;

                    if (totalItems == 0) {
                      return Container(
                        height: 100,
                        child: Center(
                          child: Text(
                            'No ${category} available in your wardrobe',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: totalItems,
                      itemBuilder: (context, index) {
                        // First show uploading items
                        if (index < categoryUploads.length) {
                          return _buildUploadingGridItem(
                              categoryUploads[index]);
                        }

                        // Then show existing items
                        final itemIndex = index - categoryUploads.length;
                        final item = notifier.value[itemIndex];
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
                                    _showFullImageDialog(
                                        context, item.imageUrl!);
                                  },
                                  child: Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: CachedNetworkImage(
                                     imageUrl:    item.imageUrl ?? '',
                                        fit: BoxFit.contain


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
                    );
                  },
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

  Widget _buildUploadingGridItem(UploadProgress progress) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: appcolor.withOpacity(0.5), width: 1),
        color: appcolor.withOpacity(0.05),
      ),
      child: Stack(
        children: [
          // Main uploading content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingAnimationWidget.fourRotatingDots(
                  color: appcolor,
                  size: 25,
                ),
                SizedBox(height: 4),
                Text(
                  '${progress.progress?.toInt()}%',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: appcolor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Progress bar at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                child: LinearProgressIndicator(
                  value: progress.progress! / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(appcolor),
                ),
              ),
            ),
          ),

          // Upload icon in top right corner
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: appcolor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_upload,
                color: Colors.white,
                size: 10,
              ),
            ),
          ),
        ],
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
      showAppSnackBar(context, 'Please wait, avatar is being generated...',
          backgroundColor: appcolor);

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
      case 'glasses':
        _handleGlassesSwipe(direction);
        break;
      case 'cap':
        _handleCapSwipe(direction);
        break;
    }
  }
  void _handleSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity;
    if (velocity == null) return;

    // Swipe left - go to next avatar
    if (velocity < -100) {
      _goToNext();

    }
    // Swipe right - go to previous avatar
    else if (velocity > 100) {
      _goToPrevious();
      showAppSnackBar(context, 'The Feature is in Progress',
          backgroundColor: appcolor);
    }
  }
  double _startX = 0.0;

  void _handlePanStart(DragStartDetails details) {
    _startX = details.localPosition.dx;
  }

  void _handlePanEnd(DragEndDetails details) {
    final endX = details.localPosition.dx;
    final deltaX = endX - _startX;

    // Minimum swipe distance to trigger action
    const minSwipeDistance = 50.0;

    if (deltaX.abs() > minSwipeDistance) {
      if (deltaX > 0) {
        _goToPrevious();

        showAppSnackBar(context, 'The Feature is in Progress',
            backgroundColor: appcolor);

      } else {
        _goToNext();
        // Swiped left - go to next
        showAppSnackBar(context, 'The Feature is in Progress',
            backgroundColor: appcolor);

      }
    }
  }


  Widget _buildAvatarColumn2() {
    return Container(
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Avatar image container
          Container(
            width: 350,
            height: 350,
            child: GestureDetector(
              onPanStart: _handlePanStart,
              onPanEnd: _handlePanEnd,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: ClipRRect(
                  key: ValueKey(currentIndexx),
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: avatarUrls[currentIndexx],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) => Center(
                      child: LoadingAnimationWidget.fourRotatingDots(
                        color: appcolor,
                        size: 15,
                      )),
                    // loadingBuilder: (context, child, loadingProgress) {
                    //   if (loadingProgress == null) return child;
                    //   return Center(
                    //     child: LoadingAnimationWidget.fourRotatingDots(color: appcolor, size: 15)
                    //   );
                    // },
                    // errorBuilder: (context, error, stackTrace) {
                    //   return Center(
                    //     child: Column(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         Icon(
                    //           Icons.error,
                    //           color: Colors.grey,
                    //           size: 50,
                    //         ),
                    //         SizedBox(height: 8),
                    //         Text(
                    //           'Failed to load image',
                    //           style: TextStyle(color: Colors.grey),
                    //         ),
                    //       ],
                    //     ),
                    //   );
                    // },
                  ),
                ),
              ),
            ),
          ),
          // Overlay swipe regions mapped to body parts
          // Head region (swipe to change cap)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 350 * 0.18,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanEnd: (details) => _handleRegionSwipe('cap', details),
            ),
          ),
          // Eyes region (swipe to change glasses)
          Positioned(
            top: 350 * 0.18,
            left: 0,
            right: 0,
            height: 350 * 0.08,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanEnd: (details) => _handleRegionSwipe('glasses', details),
            ),
          ),
          // Chest/torso region (swipe to change shirt)
          Positioned(
            top: 350 * 0.26,
            left: 0,
            right: 0,
            height: 350 * 0.30,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanEnd: (details) => _handleRegionSwipe('shirt', details),
            ),
          ),
          // Legs region (swipe to change pant)
          Positioned(
            top: 350 * 0.56,
            left: 0,
            right: 0,
            height: 350 * 0.20,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanEnd: (details) => _handleRegionSwipe('pant', details),
            ),
          ),
          // Feet region (swipe to change shoes)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 350 * 0.14,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanEnd: (details) => _handleRegionSwipe('shoes', details),
            ),
          ),
        ],
      ),
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
                    },
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
                            color: Colors.white, size: 20),
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
                          ? localizations.generating
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
        // Remove or comment out the upload progress button
        // _buildUploadProgressButton(),
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
      BuildContext context, String category) {
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
                      color: appcolor, size: 20),
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

  Widget _buildUploadProgressButton() {
    return ValueListenableBuilder<Map<String, UploadProgress>>(
      valueListenable: _wardrobeController.uploadProgressNotifier,
      builder: (context, uploads, child) {
        // Show button only if there are active uploads
        if (uploads.isEmpty) return SizedBox.shrink();

        int activeUploads = uploads.values.where((p) => p.isInProgress).length;
        int completedUploads =
            uploads.values.where((p) => p.isCompleted).length;

        return Container(
          margin: EdgeInsets.all(8),
          child: ElevatedButton.icon(
            onPressed: () => _showUploadProgressDialog(),
            icon: activeUploads > 0
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(Icons.check_circle, color: Colors.white),
            label: Text(
              activeUploads > 0
                  ? 'Uploading ($activeUploads)...'
                  : 'View Completed ($completedUploads)',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 7,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: activeUploads > 0 ? appcolor : Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        );
      },
    );
  }

  void _showUploadProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  Icon(Icons.cloud_upload, color: appcolor, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Upload Progress',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: appcolor,
                    ),
                  ),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: ValueListenableBuilder<Map<String, UploadProgress>>(
                  valueListenable: _wardrobeController.uploadProgressNotifier,
                  builder: (context, uploads, child) {
                    if (uploads.isEmpty) {
                      return Container(
                        height: 100,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox, color: Colors.grey, size: 48),
                              SizedBox(height: 8),
                              Text(
                                'No uploads found',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Sort uploads: active first, then completed, then failed
                    final sortedUploads = uploads.entries.toList()
                      ..sort((a, b) {
                        if (a.value.isInProgress && !b.value.isInProgress)
                          return -1;
                        if (!a.value.isInProgress && b.value.isInProgress)
                          return 1;
                        if (a.value.isCompleted && !b.value.isCompleted)
                          return -1;
                        if (!a.value.isCompleted && b.value.isCompleted)
                          return 1;
                        return 0;
                      });

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: sortedUploads.length,
                      itemBuilder: (context, index) {
                        final progress = sortedUploads[index].value;
                        return _buildEnhancedUploadProgressItem(progress);
                      },
                    );
                  },
                ),
              ),
              actions: [
                ValueListenableBuilder<Map<String, UploadProgress>>(
                  valueListenable: _wardrobeController.uploadProgressNotifier,
                  builder: (context, uploads, child) {
                    int completedCount =
                        uploads.values.where((p) => p.isCompleted).length;

                    return Row(
                      children: [
                        if (completedCount > 0)
                          TextButton.icon(
                            onPressed: () {
                              _clearCompletedUploads();
                            },
                            icon: Icon(Icons.clear_all, size: 18),
                            label: Text('Clear Completed'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey[600],
                            ),
                          ),
                        Spacer(),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Close',
                            style: GoogleFonts.poppins(color: appcolor),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _clearCompletedUploads() {
    final currentUploads = Map<String, UploadProgress>.from(
        _wardrobeController.uploadProgressNotifier.value);

    currentUploads.removeWhere((key, value) => value.isCompleted);

    _wardrobeController.uploadProgressNotifier.value = currentUploads;
  }

  Widget _buildEnhancedUploadProgressItem(UploadProgress progress) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (progress.status) {
      case UploadStatus.completed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Completed';
        break;
      case UploadStatus.error:
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusText = 'Failed';
        break;
      case UploadStatus.uploading:
        statusColor = appcolor;
        statusIcon = Icons.cloud_upload;
        statusText = 'Uploading';
        break;
      case UploadStatus.processing:
        statusColor = Colors.orange;
        statusIcon = Icons.settings;
        statusText = 'Processing';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.hourglass_empty;
        statusText = 'Waiting';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: progress.isCompleted
            ? Colors.green.shade50
            : progress.isError
                ? Colors.red.shade50
                : Colors.grey.shade50,
        border: Border.all(
          color: progress.isCompleted
              ? Colors.green.shade200
              : progress.isError
                  ? Colors.red.shade200
                  : Colors.grey.shade300,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${progress.category.toUpperCase()} - ${progress.subCategory}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      statusText,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (progress.progress != null && progress.isInProgress)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(progress.progress! * 100).toInt()}%',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 12),

          // Message
          Text(
            progress.message,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.3,
            ),
          ),

          // Progress bar
          if (progress.progress != null && progress.isInProgress) ...[
            SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.progress,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 6,
              ),
            ),
          ],

          // Error details
          if (progress.isError && progress.error != null) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      color: Colors.red.shade700, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      progress.error!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.red.shade700,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Timestamp
          SizedBox(height: 8),
          Text(
            'Started: ${_formatTimestamp(progress.startTime)}',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showImageCapturedDialog(
      String category, String subcategory, File imageFile) {
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            loc.itemCaptured,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: appcolor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                loc.cancel,
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog immediately
                await _startBackgroundUpload(category, subcategory, imageFile);
              },
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
  }

  Widget _buildCalendarSection() {
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
          valueListenable: _wardrobeController.selectedDayNotifier,
          builder: (context, DateTime selectedDay, _) {
            return ValueListenableBuilder<DateTime>(
              valueListenable: _wardrobeController.focusedDayNotifier,
              builder: (context, DateTime focusedDay, _) {
                return ValueListenableBuilder<CalendarFormat>(
                  valueListenable: _wardrobeController.calendarFormatNotifier,
                  builder: (context, CalendarFormat calendarFormat, _) {
                    return ValueListenableBuilder<List<AvatarData>>(
                      valueListenable: _outfitController.avatarDatesNotifier,
                      builder: (context, List<AvatarData> avatarDates, _) {
                        print(_outfitController.avatarDatesNotifier.value);
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(Responsive.radius(16)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child:
                          TableCalendar(
                            availableGestures: AvailableGestures.all, // Allow long-press
                            // Or at least enable long-press:
                            onDayLongPressed: (selectedDay, _) {
                              print('Long-pressed: $selectedDay');
                              _showAvatarMessage(selectedDay);
                            },

                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: focusedDay,
                            calendarFormat: calendarFormat,
                            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                            onDaySelected: (selectedDay, focusedDay) {
                              _wardrobeController.selectedDayNotifier.value = selectedDay;
                              _wardrobeController.focusedDayNotifier.value = focusedDay;
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                              _checkExistingOutfit(selectedDay);
                            },
                            eventLoader: (day) {
                              return _outfitController.hasAvatarForDate(day) ? ['outfit'] : [];
                            },
                            calendarStyle: CalendarStyle(
                              markersMaxCount: 1,
                              outsideDaysVisible: false,
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
                              leftChevronIcon: Icon(Icons.chevron_left, color: appcolor),
                              rightChevronIcon: Icon(Icons.chevron_right, color: appcolor),
                            ),
                            calendarBuilders: CalendarBuilders(
                              markerBuilder: (context, day, events) {
                                if (events.isEmpty || isSameDay(day, DateTime.now())) {
                                  return const SizedBox();
                                }
                                return Positioned(
                                  right: 20,
                                  top: 10,
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: appcolor,
                                      shape: BoxShape.circle,
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
