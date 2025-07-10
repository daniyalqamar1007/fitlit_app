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
  WardrobeController controller = WardrobeController();
  DateTime? _selectedDay;
  final AvatarController _avatarController = AvatarController();
  bool _isGeneratingAvatar = false;
  final ImagePicker _picker = ImagePicker();
  String? _avatarUrl;
  final List<String> avatarUrls = [
    'https://fitlit-assets.s3.us-east-2.amazonaws.com/wardrobe/1747930630870-image.png',
    'https://fitlit-assets.s3.us-east-2.amazonaws.com/wardrobe/1747934549164-image.png',
    'https://fitlit-assets.s3.us-east-2.amazonaws.com/wardrobe/1747935456493-image.png',
    'https://fitlit-assets.s3.us-east-2.amazonaws.com/wardrobe/1747937370671-image.png',
    'https://fitlit-assets.s3.us-east-2.amazonaws.com/wardrobe/1747938354346-image.png',
    'https://fitlit-assets.s3.us-east-2.amazonaws.com/wardrobe/1747938907353-image.png',
  ];
  int currentIndexx = 0;
  String? staticurl="https://fitlit-assets.s3.us-east-2.amazonaws.com/wardrobe/1747930630870-image.png";
  bool _isLoadingg = false;

  // Responsive helper methods
  bool get isTablet {
    final data = MediaQuery.of(context);
    return data.size.shortestSide >= 600;
  }

  bool get isLargeTablet {
    final data = MediaQuery.of(context);
    return data.size.shortestSide >= 900;
  }

  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  double getResponsiveWidth(double mobileWidth) {
    if (isLargeTablet) {
      return mobileWidth * 1.8;
    } else if (isTablet) {
      return mobileWidth * 1.4;
    }
    return mobileWidth;
  }

  double getResponsiveHeight(double mobileHeight) {
    if (isLargeTablet) {
      return mobileHeight * 1.6;
    } else if (isTablet) {
      return mobileHeight * 1.3;
    }
    return mobileHeight;
  }

  double getResponsiveFontSize(double mobileFontSize) {
    if (isLargeTablet) {
      return mobileFontSize * 1.5;
    } else if (isTablet) {
      return mobileFontSize * 1.2;
    }
    return mobileFontSize;
  }

  double getResponsivePadding(double mobilePadding) {
    if (isLargeTablet) {
      return mobilePadding * 1.8;
    } else if (isTablet) {
      return mobilePadding * 1.4;
    }
    return mobilePadding;
  }

  EdgeInsets getResponsiveAllPadding(double mobilePadding) {
    return EdgeInsets.all(getResponsivePadding(mobilePadding));
  }

  void _goToNext() {
    setState(() {
      currentIndexx = (currentIndexx + 1) % avatarUrls.length;
      staticurl=avatarUrls[currentIndexx];
    });
  }

  void _goToPrevious() {
    setState(() {
      currentIndexx = (currentIndexx - 1 + avatarUrls.length) % avatarUrls.length;
      staticurl=avatarUrls[currentIndexx];
    });
  }

  SharedPreferences? _prefs;
  int _currentShirtIndex = 0;
  int _currentPantIndex = 0;
  int _currentShoeIndex = 0;
  bool _isSwipeGenerating = false;
  String? userProfileImage;
  String? profileImage;
  int _currentAvatarIndex = 0;
  String outfitMessage = "";
  String? currenturl;
  final WardrobeController _wardrobeController = WardrobeController();
  final OutfitController _outfitController = OutfitController();
  AnimationController? _avatarAnimationController;
  bool _isLoading = false;
  bool _isAnimatingIn = false;
  String loadingType = "";
  List<String> _userAvatars = [];
  bool _isLoadingAvatars = false;
  bool isLoadingItems = true;
  bool isSavingOutfit = false;
  String? leftMessage;
  String? rightMessage;
  TextEditingController messagecontroller = TextEditingController();
  String? selectedShirtId;
  String? selectedPantId;
  String? selectedShoeId;
  final BackgroundImageController _backgroundImageController =
      BackgroundImageController();
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
    _listenForUploadCompletion();
    _loadUserProfile();
    _getUserInfoAndLoadItems();
    _loadAllUserAvatars();
    _wardrobeController.statusNotifier.addListener(_handleStatusChange);
    _avatarController.statusNotifier.addListener(_handleAvatarStatusChange);
    _loadAvatarDates();
  }

  Future<void> _startBackgroundUpload(
      String category, String subcategory, File imageFile) async {
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
      showAppSnackBar(
        context,
        'Upload started! Processing in background...',
        backgroundColor: appcolor,
      );
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
          progress.hasShownNotification = true;
          showAppSnackBar(
            context,
            '${progress.subCategory} added to wardrobe successfully!',
            backgroundColor: appcolor,
          );
          Future.delayed(Duration(milliseconds: 500), () {
            if (mounted) {
              _getUserInfoAndLoadItems();
              setState(() {});
            }
          });
        } else if (progress.isError && !progress.hasShownNotification) {
          progress.hasShownNotification = true;
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
      if (token != null) {
        final success = await _backgroundImageController.getAllBackgroundImages(
            token: token!);
        if (success) {
          setState(() {
            _apiBackgrounds =
                _backgroundImageController.backgroundImagesNotifier.value;
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
    if (_userAvatars.isNotEmpty && _currentAvatarIndex < _userAvatars.length) {
      return _userAvatars[_currentAvatarIndex];
    }
    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      return _avatarUrl;
    }
    if (userProfile?.profileImage.isNotEmpty == true) {
      return userProfile!.profileImage;
    }
    return null;
  }

  void _handleShirtSwipe(String direction) {
    final shirts = _wardrobeController.shirtsNotifier.value;
    if (shirts.isEmpty) {
      showAppSnackBar(context, 'No shirts available in your wardrobe',
          backgroundColor: appcolor);
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
      showAppSnackBar(context, 'No pants available in your wardrobe',
          backgroundColor: appcolor);
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
      showAppSnackBar(context, 'No shoes available in your wardrobe',
          backgroundColor: appcolor);
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

  Future<void> _generateAvatarFromSwipe(
      String category, String direction) async {
    final localizations = AppLocalizations.of(context)!;
    bool hasInternet = await checkInternetAndShowDialog(context);
    if (!hasInternet) {
      return;
    }
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
        showAppSnackBar(context, 'Failed to generate avatar',
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

  Widget _buildImageWithLoadingEnhanced(
      String category, List<WardrobeItem> items) {
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
              imageUrl: selectedItem.imageUrl ?? '',
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

  void _updateSelectedItemsFromCurrentOutfit() {
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
    try {
      setState(() {
        isLoadingItems = true;
      });
      await _wardrobeController.loadWardrobeItems();
      _updateSelectedItemsFromCurrentOutfit();
    } catch (e) {
      print("Error getting user info: $e");
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

  Future<void> _checkExistingOutfit(DateTime date) async {
    try {
      setState(() {
        isLoadingItems = true;
      });
      final outfit = await _outfitController.getOutfitByDate(
          token: token!,
          date: date,
          id: _profileController.profileNotifier.value!.id);
      print("coming ios ${outfit?.backgroundimage}");
      if (outfit?.success == true) {
        setState(() {
          _avatarUrl = outfit?.avatar_url;
          currenturl = outfit?.backgroundimage;
        });
        _updateAvatarBasedOnOutfit(outfit?.avatar_url);
      } else {}
      setState(() {
        isLoadingItems = false;
        currenturl = "";
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
    if (outfit.shirtId != null && outfit.pantId != null) {
      setState(() {
        _avatarUrl = outfit;
        profileImage = outfit;
        _currentAvatarIndex = 0;
      });
    } else if (outfit.shirtId != null) {
      setState(() {
        _currentAvatarIndex = 1;
      });
    } else if (outfit.pantId != null) {
      setState(() {
        _currentAvatarIndex = 2;
      });
    } else {
      setState(() {
        _currentAvatarIndex = 5;
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

  Future<File> mergeAndSaveStackedImage({
    required String backgroundUrl,
    required String avatarUrl,
  }) async {
    try {
      final bgBytes = await _loadImageBytes(backgroundUrl, isNetwork: true);
      final avatarBytes = await _loadImageBytes(avatarUrl, isNetwork: true);
      final background = img.decodeImage(bgBytes);
      final avatar = img.decodeImage(avatarBytes);
      if (background == null || avatar == null) {
        throw Exception("One of the images could not be decoded.");
      }
      final avatarResized = img.copyResize(
        avatar,
        width: (background.width * 0.6).toInt(),
      );
      img.Image merged = img.copyResize(
        background,
        width: background.width,
        height: background.height,
      );
      final dx = ((background.width - avatarResized.width) / 2).toInt();
      final dy = ((background.height - avatarResized.height) / 2).toInt();
      img.compositeImage(merged, avatarResized, dstX: dx, dstY: dy);
      final combinedBytes = img.encodePng(merged);
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
      File? mergedFile = await mergeAndSaveStackedImage(
        backgroundUrl: currenturl!,
        avatarUrl: staticurl!,
      );
      final result = await _outfitController.saveOutfit(
        token: token!,
        shirtId: "681e413544c5377f3cdb4575",
        pantId: "68247bacab8a78ba02e03623",
        shoeId: "682c271bf00363d7967c29fe",
        accessoryId: "6828e27c408e9791407522c2",
        backgroundimageurl: currenturl,
        message: outfitMessage,
        avatarurl: staticurl!,
        file: mergedFile,
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
            currenturl = "";
            _currentBackgroundPath = backgroundPath;
          });
          print("haseeb is coming");
          print(_currentBackgroundPath);
          await _loadBackgroundImages();
          _showSuccessSnackBar("Background updated successfully!");
        },
      ),
    );
  }

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
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return RefreshIndicator(
      color: appcolor,
      backgroundColor: white,
      onRefresh: () async {
        await _getUserInfoAndLoadItems();
        await _loadUserProfile();
        await _loadAvatarDates();
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
                      padding: getResponsiveAllPadding(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTopRow(),
                          SizedBox(height: getResponsiveHeight(20)),
                          _buildThreeColumnSection(),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: getResponsiveAllPadding(16.0),
                  child: _buildCalendarSection(controller),
                ),
                SizedBox(
                  height: getResponsiveHeight(40),
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
            scale: isTablet ? 3 : 4,
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
    if (_apiBackgrounds.isEmpty) {
      return Image.asset("assets/Images/new.jpg", fit: BoxFit.cover);
    }
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
                      size: getResponsiveWidth(20)
                  );
                }
                return ClipOval(
                  child: Container(
                    width: getResponsiveWidth(50),
                    height: getResponsiveHeight(50),
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
                          size: getResponsiveWidth(20),
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
        SizedBox(width: getResponsiveWidth(10)),
        Expanded(
          flex: 3,
          child: Text(
            localizations.fitlit,
            style: GoogleFonts.playfairDisplay(
              color: appcolor,
              fontSize: getResponsiveFontSize(22),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(width: getResponsiveWidth(40)),
        GestureDetector(
          onTap: isSavingOutfit
              ? null
              : () async {
            await _saveOutfit(context);
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: getResponsivePadding(14), 
              vertical: getResponsivePadding(8)
            ),
            height: getResponsiveHeight(30),
            decoration: BoxDecoration(
              color: isSavingOutfit ? Colors.grey : appcolor.withOpacity(0.7),
              borderRadius: BorderRadius.circular(getResponsivePadding(30)),
            ),
            child: isSavingOutfit
                ? SizedBox(
              width: getResponsiveWidth(16),
              height: getResponsiveHeight(16),
              child: LoadingAnimationWidget.fourRotatingDots(
                color: appcolor,
                size: getResponsiveWidth(20),
              ),
            )
                : Text(
              localizations.save,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: getResponsiveFontSize(10),
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
          Expanded(
            flex: isTablet ? 5 : 4,
            child: _buildFirstColumn(),
          ),
          Expanded(
            flex: isTablet ? 6 : 8,
            child: _buildAvatarColumn2(),
          ),
          Expanded(
            flex: isTablet ? 5 : 4,
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
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: getResponsivePadding(10),
              vertical: getResponsivePadding(10)),
          decoration: BoxDecoration(
            color: appcolor.withOpacity(0.7),
            borderRadius: BorderRadius.circular(getResponsivePadding(30)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_month_sharp,
                color: Colors.white,
                size: getResponsiveFontSize(14),
              ),
              Text(" ${_focusedDay.day} ${_getMonthName(_focusedDay.month)}",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: getResponsiveFontSize(10),
                  )),
            ],
          ),
        ),
        SizedBox(height: getResponsiveHeight(10)),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: getResponsivePadding(14), 
              vertical: getResponsivePadding(8)),
          height: getResponsiveHeight(30),
          decoration: BoxDecoration(
            color: appcolor.withOpacity(0.7),
            borderRadius: BorderRadius.circular(getResponsivePadding(30)),
          ),
          child: Text(
            localizations.shirts,
            style: GoogleFonts.poppins(
              fontSize: getResponsiveFontSize(10),
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: getResponsiveHeight(10)),
        _buildWardrobeItemContainer('shirt'),
        SizedBox(height: getResponsiveHeight(7)),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: getResponsivePadding(12), 
              vertical: getResponsivePadding(8)),
          height: getResponsiveHeight(30),
          decoration: BoxDecoration(
            color: appcolor.withOpacity(0.7),
            borderRadius: BorderRadius.circular(getResponsivePadding(30)),
          ),
          child: Text(
            'Accessories',
            style: GoogleFonts.poppins(
              fontSize: getResponsiveFontSize(9),
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: getResponsiveHeight(7)),
        _buildWardrobeItemContainer('accessories'),
        SizedBox(height: getResponsiveHeight(7)),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: getResponsivePadding(14), 
              vertical: getResponsivePadding(8)),
          height: getResponsiveHeight(30),
          decoration: BoxDecoration(
            color: appcolor.withOpacity(0.7),
            borderRadius: BorderRadius.circular(getResponsivePadding(30)),
          ),
          child: Text(
            localizations.pants,
            style: GoogleFonts.poppins(
              fontSize: getResponsiveFontSize(10),
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: getResponsiveHeight(7)),
        _buildWardrobeItemContainer('pant'),
        SizedBox(height: getResponsiveHeight(7)),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: getResponsivePadding(14), 
              vertical: getResponsivePadding(8)),
          height: getResponsiveHeight(30),
          decoration: BoxDecoration(
            color: appcolor.withOpacity(0.7),
            borderRadius: BorderRadius.circular(getResponsivePadding(30)),
          ),
          child: Text(
            localizations.shoes,
            style: GoogleFonts.poppins(
              fontSize: getResponsiveFontSize(10),
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: getResponsiveHeight(7)),
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
              List<UploadProgress> categoryUploads =
                  _getCategoryUploads(category, uploadProgress);
              bool hasActiveUpload = categoryUploads.isNotEmpty;

              return Container(
                width: getResponsiveWidth(60),
                height: getResponsiveHeight(56),
                margin: EdgeInsets.only(bottom: getResponsivePadding(5)),
                decoration: BoxDecoration(
                  color: themeController.white,
                  borderRadius: BorderRadius.circular(getResponsivePadding(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
                    if (items.isEmpty)
                      Center(
                        child: Icon(
                          _getIconForCategory(category),
                          color: Colors.grey,
                          size: getResponsiveWidth(30),
                        ),
                      )
                    else
                      _buildImageWithLoadingEnhanced(category, items),
                    if (hasActiveUpload)
                      Positioned(
                        top: getResponsivePadding(4),
                        right: getResponsivePadding(4),
                        child: Container(
                          padding: EdgeInsets.all(getResponsivePadding(2)),
                          decoration: BoxDecoration(
                            color: appcolor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.cloud_upload,
                            color: Colors.white,
                            size: getResponsiveFontSize(12),
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
      String category, Map<String, UploadProgress> uploadProgress) {
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
    setState(() {});
    HapticFeedback.selectionClick();
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {});
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
      String category, List<WardrobeItem> items) {
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
      case 'accessories':
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
      String category, ValueNotifier<List<WardrobeItem>> notifier) {
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
                    List<UploadProgress> categoryUploads =
                        _getCategoryUploads(category, uploadProgress);
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
                        if (index < categoryUploads.length) {
                          return _buildUploadingGridItem(
                              categoryUploads[index]);
                        }
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
                                          imageUrl: item.imageUrl ?? '',
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
        return FontAwesomeIcons.shirt;
      case 'pant':
        return FontAwesomeIcons.personHalfDress;
      case 'shoes':
        return FontAwesomeIcons.shoePrints;
      case 'accessories':
        return FontAwesomeIcons.glasses;
      default:
        return FontAwesomeIcons.tag;
    }
  }

  void _handleRegionSwipe(String region, DragEndDetails details) {
    if (_isSwipeGenerating || _isGeneratingAvatar) {
      showAppSnackBar(context, 'Please wait, avatar is being generated...',
          backgroundColor: appcolor);
      return;
    }
    double horizontalVelocity = details.velocity.pixelsPerSecond.dx;
    const double minVelocity = 300.0;
    if (horizontalVelocity.abs() < minVelocity) return;
    String direction = horizontalVelocity > 0 ? 'previous' : 'next';
    HapticFeedback.selectionClick();
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

  void _handleSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity;
    if (velocity == null) return;
    if (velocity < -100) {
      _goToNext();
    } else if (velocity > 100) {
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
    const minSwipeDistance = 50.0;
    if (deltaX.abs() > minSwipeDistance) {
      if (deltaX > 0) {
        _goToPrevious();
        showAppSnackBar(context, 'The Feature is in Progress',
            backgroundColor: appcolor);
      } else {
        _goToNext();
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
          Container(
            width: getResponsiveWidth(350),
            height: getResponsiveHeight(350),
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
                  borderRadius: BorderRadius.circular(getResponsivePadding(10)),
                  child: CachedNetworkImage(
                    imageUrl: avatarUrls[currentIndexx],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) => Center(
                      child: LoadingAnimationWidget.fourRotatingDots(
                        color: appcolor,
                        size: getResponsiveWidth(15),
                      )),
                  ),
                ),
              ),
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
                    horizontal: getResponsivePadding(4),
                    vertical: getResponsivePadding(5)),
                height: getResponsiveHeight(30),
                decoration: BoxDecoration(
                  color: appcolor.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(getResponsivePadding(30)),
                ),
                child: Row(
                  children: [
                    if (_isGeneratingAvatar)
                      SizedBox(
                        width: getResponsiveWidth(14),
                        height: getResponsiveHeight(14),
                        child: LoadingAnimationWidget.fourRotatingDots(
                            color: Colors.white, size: getResponsiveWidth(20)),
                      )
                    else
                      Icon(
                        Icons.file_upload_outlined,
                        color: Colors.white,
                        size: getResponsiveFontSize(14),
                        weight: 10,
                      ),
                    SizedBox(width: getResponsiveWidth(2)),
                    Text(
                      _isGeneratingAvatar
                          ? localizations.generating
                          : localizations.upload,
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: getResponsiveFontSize(8)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: getResponsiveHeight(10)),
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
                  fontSize: getResponsiveFontSize(18),
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

  Widget _buildAnimatedCategoryButton(
      String category, String? selectedCategory, Function(String) onSelect) {
    bool isSelected = selectedCategory == category;
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(vertical: getResponsivePadding(4.0)),
      child: InkWell(
        onTap: () => onSelect(category),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: getResponsivePadding(12)),
          decoration: BoxDecoration(
            color: isSelected ? appcolor : Colors.white,
            borderRadius: BorderRadius.circular(getResponsivePadding(8)),
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
              padding: getResponsiveAllPadding(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(getResponsivePadding(10)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LoadingAnimationWidget.fourRotatingDots(
                      color: appcolor, size: getResponsiveWidth(20)),
                  SizedBox(height: getResponsiveHeight(16)),
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
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      Navigator.pop(context);
      if (image != null) {
        File imageFile = File(image.path);
        _showImageCapturedDialog(category, subcategory, imageFile);
      }
    } catch (e) {
      Navigator.pop(context);
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
          Text(
            progress.message,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.3,
            ),
          ),
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
                Navigator.pop(context);
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
            fontSize: getResponsiveFontSize(18),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: getResponsiveHeight(8)),
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
                            borderRadius: BorderRadius.circular(getResponsivePadding(16)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TableCalendar(
                            availableGestures: AvailableGestures.all,
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
                              controller.selectedDayNotifier.value = selectedDay;
                              controller.focusedDayNotifier.value = focusedDay;
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
                                fontSize: getResponsiveFontSize(16),
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
                                  right: getResponsivePadding(20),
                                  top: getResponsivePadding(10),
                                  child: Container(
                                    width: getResponsiveWidth(6),
                                    height: getResponsiveHeight(6),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No avatar message for this date'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _avatarAnimationController?.dispose();
    _wardrobeController.statusNotifier.removeListener(_handleStatusChange);
    _wardrobeController.dispose();
    _outfitController.dispose();
    _avatarController.statusNotifier.removeListener(_handleAvatarStatusChange);
    _avatarController.dispose();
    _backgroundImageController.dispose();
    super.dispose();
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