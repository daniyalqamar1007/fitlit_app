
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitlip_app/routes/App_routes.dart';
import 'package:fitlip_app/controllers/themecontroller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/profile_controller.dart';
import '../../../controllers/wardrobe_controller.dart';
import '../../../controllers/outfit_controller.dart';
import '../../../main.dart';
import '../../../model/profile_model.dart';
import '../../../model/wardrobe_model.dart';
import '../../Utils/Colors.dart';
import 'dart:io';

import '../../Utils/globle_variable/globle.dart';
import '../../Utils/responsivness.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({Key? key}) : super(key: key);

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<UserProfileModel?> profileNotifier = ValueNotifier<UserProfileModel?>(null);
  final ProfileController _profileController = ProfileController();
  DateTime _focusedDay = DateTime.now();
  WardrobeController controller=WardrobeController();
  DateTime? _selectedDay;
  final ImagePicker _picker = ImagePicker();
  String? _avatarUrl;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  Timer? _uploadProgressTimer;

  String? userProfileImage;
  String? profileImage;
  int _currentAvatarIndex = 0;
  final List<String> _avatarAssets = [

    'assets/Icons/avatar3.png',
    'assets/Icons/black.png',
    'assets/Icons/red.png',
    'assets/Icons/avatar2.png',
    'assets/Icons/avatar.png',
    'assets/Icons/avatar2.png',
  ];
  final WardrobeController _wardrobeController = WardrobeController();
  final OutfitController _outfitController = OutfitController();
  AnimationController? _avatarAnimationController;
  Animation<Offset>? _slideOutAnimation;
  Animation<Offset>? _slideInAnimation;
  bool _isLoading = false;
  bool _isAnimatingIn = false;
  String loadingType = "";
  bool isLoadingItems = true;
  bool isSavingOutfit = false;

  String? selectedShirtId;
  String? selectedPantId;
  String? selectedShoeId;
  String? selectedAccessoryId;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

     _loadUserProfile();

    _getUserInfoAndLoadItems();
    _wardrobeController.statusNotifier.addListener(_handleStatusChange);

    // Check if there's an outfit for today
    _checkExistingOutfit(_focusedDay);
  }

  void _handleStatusChange() {
    if (mounted) {
      setState(() {
        isLoadingItems =
            _wardrobeController.statusNotifier.value == WardrobeStatus.loading;
      });
    }
  }

  Future<void> _getUserInfoAndLoadItems() async {
    try {
      setState(() {
        isLoadingItems = true;
      });

      await _wardrobeController.loadWardrobeItems();

      // After loading items, set default selections
      _updateSelectedItemsFromCurrentOutfit();

    } catch (e) {
      print("Error getting user info: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load wardrobe items'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  Future<void> _loadUserProfile() async {
    // Get user profile data
    await _profileController.getUserProfile();

    _getUserInfoAndLoadItems();
  }

  // Check if there's an existing outfit for the selected date
  Future<void> _checkExistingOutfit(DateTime date) async {
    try {
      setState(() {
        isLoadingItems = true; // Show loading indicator
      });

      final outfit = await _outfitController.getOutfitByDate(
        token: token!,
        date: date,
      );
      print("coming ios $outfit");
    if(url!=""){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Update available for this date',style: GoogleFonts.poppins(color: Colors.white),),
          backgroundColor: appcolor,
          duration: Duration(seconds: 1),
        ),
      );
     setState(() {
       _currentAvatarIndex=avatarindex;
     });
      _updateAvatarBasedOnOutfit(outfit);

      // Show brief success message that an outfit was found

    }
        else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No outfit available for this date',style: GoogleFonts.poppins(color: Colors.white),),
          backgroundColor: appcolor,
          duration: Duration(seconds: 1),
        ),
      );
    }


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
    _currentAvatarIndex=1;
    // Logic to update avatar based on outfit components
    // This is a simplified implementation
    if (outfit.shirtId != null && outfit.pantId != null) {
      setState(() {
        _currentAvatarIndex = 0; // Default complete outfit
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

  void _updateSelectedItemsFromCurrentOutfit() {
    // Update selected IDs based on first items in each category
    if (_wardrobeController.shirtsNotifier.value.isNotEmpty) {
      selectedShirtId = _wardrobeController.shirtsNotifier.value.last.id;
    }

    if (_wardrobeController.pantsNotifier.value.isNotEmpty) {
      selectedPantId = _wardrobeController.pantsNotifier.value.last.id;
    }

    if (_wardrobeController.shoesNotifier.value.isNotEmpty) {
      selectedShoeId = _wardrobeController.shoesNotifier.value.last.id;
    }

    if (_wardrobeController.accessoriesNotifier.value.isNotEmpty) {
      selectedAccessoryId = _wardrobeController.accessoriesNotifier.value.last.id;
    }
  }

  Future<void> _saveOutfit() async {
    // Show confirmation dialog
    bool confirmed = await _showSaveOutfitConfirmationDialog();

    if (!confirmed) return;

    setState(() {
      isSavingOutfit = true;
      storedindex=_currentAvatarIndex;
      print(_currentAvatarIndex);
    });

    try {
      if(profileImage==""){
        return;
      }
      final result = await _outfitController.saveOutfit(
        token: token!,

        shirtId: "1",
        pantId: "2",
        shoeId: "3",
        accessoryId: "4",
        avatarurl:profileImage!,

        date: _selectedDay ?? _focusedDay,

      );

      setState(() {
        isSavingOutfit = false;
      });

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Outfit saved successfully for ${_getFormattedDate(_selectedDay ?? _focusedDay)}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_outfitController.errorNotifier.value ?? 'Failed to save outfit'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isSavingOutfit = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  String _getFormattedDate(DateTime date) {
    return "${date.day} ${_getMonthName(date.month)} ${date.year}";
  }

  Future<bool> _showSaveOutfitConfirmationDialog() async {
    bool result = false;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Save Outfit',
          style: GoogleFonts.poppins(
            color: appcolor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Do you want to save this outfit for ${_getFormattedDate(_selectedDay ?? _focusedDay)}?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              result = false;
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              result = true;
            },
            child: Text(
              'Save',
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

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: appcolor,
      backgroundColor: white,
      onRefresh: () async {
        await _getUserInfoAndLoadItems();
      },
      child: Scaffold(
        backgroundColor: themeController.white,
        body:
        SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(children: [
                  Positioned.fill(
                      child: Opacity(
                          opacity: 0.7,
                          child: Image.asset(
                            'assets/Images/new.jpg',
                            fit: BoxFit.cover,
                          ))),
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
                ]),
                Padding(
                  padding: Responsive.allPadding(16.0),
                  child: _buildCalendarSection(controller),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: SizedBox(

          width: 75,
          height: 40,
          child: RawMaterialButton(
            onPressed: ()=>_showAnimatedCategoryDialog(),
            fillColor: appcolor, // Change this to your desired color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal:4.0),
              child: Row(
                children:[
                  Icon(Icons.file_upload_outlined,color: Colors.white,size: 20,),
                  Text(
                  "Upload",
                  style: TextStyle(color: Colors.white,fontSize: 12),
                ),

              ]),
            ),
          ),
        ),

      ),
    );
  }

  Widget _buildTopRow() {
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
              return const CircularProgressIndicator();
            }

            return ClipOval(
              child: Container(
                width: 40,
                height: 50,

                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: userProfile.profileImage.isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: userProfile.profileImage,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter, // Focus on the top part (face)
                  placeholderFadeInDuration: Duration(milliseconds: 300),
                  placeholder: (context, url) => CircularProgressIndicator(),
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

        SizedBox(
          width: Responsive.width(10),
        ),
        Expanded(
          flex: 3,
          child: Text(
            'FITLIT',
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
          onTap: isSavingOutfit ? null : _saveOutfit,
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
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Text(
              "Save",
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10
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
            flex: 6,
            child: _buildAvatarColumn(),
          ),

          // Third Column - Similar to first column
          Expanded(
            flex: 3,
            child: _buildThirdColumn(),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Date section
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: Responsive.width(14), vertical: Responsive.height(8)),
          height: Responsive.height(30),
          width: Responsive.width(85),
          decoration: BoxDecoration(
            color: appcolor.withOpacity(0.7),
            borderRadius: BorderRadius.circular(Responsive.radius(30)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_month_sharp,
                color: Colors.white,
                size: Responsive.fontSize(13),
              ),
              Text(

                  "  ${_focusedDay.day} ${_getMonthName(_focusedDay.month)}",

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
          height: Responsive.height(29),
          decoration: BoxDecoration(
            color: appcolor.withOpacity(0.7),
            borderRadius: BorderRadius.circular(Responsive.radius(30)),
          ),
          child: Text(
            'Shirts',
            style: GoogleFonts.poppins(
              fontSize: Responsive.fontSize(10),
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: Responsive.height(5),
        ),
        _buildWardrobeItemContainer('shirt'),
        const SizedBox(height: 5),

        Container(
          padding: EdgeInsets.symmetric(
              horizontal: Responsive.width(14), vertical: Responsive.height(8)),
          height: Responsive.height(30),
          decoration: BoxDecoration(
            color: appcolor.withOpacity(0.7),
            borderRadius: BorderRadius.circular(Responsive.radius(30)),
          ),
          child: Text(
            'Accessories',
            style: GoogleFonts.poppins(
              fontSize: Responsive.fontSize(10),
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: Responsive.height(5),
        ),
        _buildWardrobeItemContainer('accessory'),


        Container(
          padding: EdgeInsets.symmetric(
              horizontal: Responsive.width(14), vertical: Responsive.height(8)),
          height: Responsive.height(30),
          decoration: BoxDecoration(
            color: appcolor.withOpacity(0.7),
            borderRadius: BorderRadius.circular(Responsive.radius(30)),
          ),
          child: Text(
            'Pants',
            style: GoogleFonts.poppins(
              fontSize: Responsive.fontSize(10),
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: Responsive.height(5),
        ),

        _buildWardrobeItemContainer('pant'),


        Container(
          padding: EdgeInsets.symmetric(
              horizontal: Responsive.width(14), vertical: Responsive.height(8)),
          height: Responsive.height(30),
          decoration: BoxDecoration(
            color: appcolor.withOpacity(0.7),
            borderRadius: BorderRadius.circular(Responsive.radius(30)),
          ),
          child: Text(
            'Shoes',
            style: GoogleFonts.poppins(
              fontSize: Responsive.fontSize(10),
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: Responsive.height(5),
        ),
        _buildWardrobeItemContainer('shoe'),

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
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
  Widget _buildWardrobeItemContainer(String category) {
    // Get the right notifier based on category
    ValueNotifier<List<WardrobeItem>> notifier;
    switch (category) {
      case 'shirt':
        notifier = _wardrobeController.shirtsNotifier;
        break;
      case 'pant':
        notifier = _wardrobeController.pantsNotifier;
        break;
      case 'shoe':
        notifier = _wardrobeController.shoesNotifier;
        break;
      case 'accessory':
        notifier = _wardrobeController.accessoriesNotifier;
        break;
      default:
        notifier = _wardrobeController.shirtsNotifier;
    }

    return GestureDetector(
      onTap: () {

        // Show item selection dialog when container is tapped
        _showItemSelectionDialog(category, notifier);
      },

      child: Container(
        width: 60,
        height: 56,
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
          // Add highlight border if this item is selected
          border: _isItemSelected(category)
              ? Border.all(color: appcolor, width: 2)
              : null,
        ),
        child: ValueListenableBuilder<List<WardrobeItem>>(
          valueListenable: notifier,
          builder: (context, items, child) {
            if (isLoadingItems) {
              // Show loading animation
              return Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(appcolor),
                    strokeWidth: 2.0,
                  ),
                ),
              );
            } else if (items.isEmpty) {
              // Show placeholder if no items
              return Center(
                child: Icon(
                  _getIconForCategory(category),
                  color: Colors.grey,
                  size: 24,
                ),
              );
            } else {
              // Find the selected item for this category
              WardrobeItem? selectedItem = _getSelectedItemForCategory(category, items);

              // Show the selected item image or the first item if none selected
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
                        if (loadingProgress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(appcolor),
                              strokeWidth: 2.0,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_isItemSelected(category))
                    Positioned(
                      bottom: 2,
                      right: 2,
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
              );
            }
          },
        ),
      ),
    );
  }

  bool _isItemSelected(String category) {
    switch (category) {
      case 'shirt':
        return selectedShirtId != null;
      case 'pant':
        return selectedPantId != null;
      case 'shoe':
        return selectedShoeId != null;
      case 'accessory':
        return selectedAccessoryId != null;
      default:
        return false;
    }
  }

  WardrobeItem? _getSelectedItemForCategory(String category, List<WardrobeItem> items) {
    String? selectedId;

    switch (category) {
      case 'shirt':
        selectedId = selectedShirtId;
        break;
      case 'pant':
        selectedId = selectedPantId;
        break;
      case 'shoe':
        selectedId = selectedShoeId;
        break;
      case 'accessory':
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

  void _showItemSelectionDialog(String category, ValueNotifier<List<WardrobeItem>> notifier) {
    if (notifier.value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No ${category}s available. Please upload some first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
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
                      case 'shoe':
                        isSelected = selectedShoeId == item.id;
                        break;
                      case 'accessory':
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
                          case 'shoe':
                            setState(() {
                              selectedShoeId = item.id;
                            });
                            break;
                          case 'accessory':
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
                              onLongPress: (){
                                _showFullImageDialog(context, item.imageUrl!);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  item.imageUrl ?? '',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
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
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
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
    switch (category) {
      case 'shirt':
        return Icons.dry_cleaning;
      case 'pant':
        return Icons.work_outline;
      case 'shoe':
        return Icons.shop;
      case 'accessory':
        return Icons.watch;
      default:
        return Icons.category;
    }
  }
  Widget _buildAvatarColumn() {
    return ValueListenableBuilder<UserProfileModel?>(
      valueListenable: _profileController.profileNotifier,
      builder: (context, userProfile, _) {
        if(userProfile?.profileImage.isNotEmpty==true){
        profileImage=userProfile!.profileImage.toString();}
        // // Use profile image if available, otherwise use default avatar
        // final avatarImage = userProfile?.profileImage.isNotEmpty == true
        //     ? userProfile!.profileImage
        //     : _avatarAssets[_currentAvatarIndex];

        return GestureDetector(
          onHorizontalDragEnd: (details) {
            // Swipe logic remains the same for cycling through avatars
            if (details.velocity.pixelsPerSecond.dx > 0) {
              setState(() {
                if (_currentAvatarIndex > 0) {
                  _currentAvatarIndex--;
                  _animateAvatarChange();
                }
              });
            } else if (details.velocity.pixelsPerSecond.dx < 0) {
              setState(() {
                if (_currentAvatarIndex < _avatarAssets.length - 1) {
                  _currentAvatarIndex++;
                  _animateAvatarChange();
                }
              });
            }
          },
          child: Container(
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animated avatar
                AnimatedSwitcher(

                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(

                      scale: animation,
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: _isLoading
                      ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(appcolor),
                    ),
                  )
                      : userProfile?.profileImage.isNotEmpty == true
                      ? CachedNetworkImage(
                        imageUrl: userProfile!.profileImage,
                        fit: BoxFit.cover,
                        width: Responsive.height(350),
                        height: Responsive.height(350),
                        placeholder: (context, url) => Center(child: CircularProgressIndicator(color: appcolor,)),
                        errorWidget: (context, url, error) => Image.asset(
                          _avatarAssets[_currentAvatarIndex],
                          height: Responsive.height(350),
                          fit: BoxFit.contain,
                        ),
                      )
                      : CircularProgressIndicator(color: appcolor,)
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void _animateAvatarChange() {
    _avatarAnimationController?.reset();
    setState(() {
      _isAnimatingIn = true;
    });
    _avatarAnimationController?.forward().then((_) {
      setState(() {
        _isAnimatingIn = false;
      });
    });
  }
  Widget _buildThirdColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: (){},
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: Responsive.width(5.5),
                    vertical: Responsive.height(5)),
                height: Responsive.height(30),
                decoration: BoxDecoration(
                  color: appcolor.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(Responsive.radius(30)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.file_upload_outlined,
                      color: Colors.white,
                      size: Responsive.fontSize(14),
                      weight: 10,
                    ),
                    Text(
                      "Generate",
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.fontSize(10)),
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

  void _showAnimatedCategoryDialog() {
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
                    : 'Select Category',
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
                                subcategories =
                                    _getSubcategoriesForCategory(category);
                                selectedSubcategory = null;
                                Future.delayed(Duration(milliseconds: 100), () {
                                  setState(() {
                                    showSubcategories = true;
                                  });
                                });
                              });
                            }),
                            _buildAnimatedCategoryButton(
                                'Accessories', selectedCategory, (category) {
                              setState(() {
                                selectedCategory = category;
                                subcategories =
                                    _getSubcategoriesForCategory(category);
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
                                subcategories =
                                    _getSubcategoriesForCategory(category);
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
                                subcategories =
                                    _getSubcategoriesForCategory(category);
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
                      'Back',
                      style: GoogleFonts.poppins(color: themeController.black),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancel',
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
                    'Open Camera',
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
      String category, String? selectedCategory, Function(String) onSelect)
  {
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
  List<String> _getSubcategoriesForCategory(String category) {
    switch (category) {
      case 'Shirts':
        return [
          'T-Shirt',
          'Half Shirt',
          'Casual Shirt',
          'Dress Shirt',
          'Polo Shirt'
        ];
      case 'Accessories':
        return [
          'Necklace',
          'Bracelet',
          'Earring',
          'Watch',
          'Belt',
          'Hat',
          'Scarf'
        ];
      case 'Pants':
        return [
          'Jeans',
          'Trousers',
          'Shorts',
          'Cargo',
          'Track Pants',
          'Formal Pants'
        ];
      case 'Shoes':
        return [
          'Sneakers',
          'Formal Shoes',
          'Boots',
          'Loafers',
          'Sandals',
          'Sports Shoes'
        ];
      default:
        return [];
    }
  }

  // Method to open camera with Google Vision integration
  void _openCameraWithGoogleVision(String category, String subcategory) async {
    // Show loading dialog
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
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(appcolor),
                  ),
                  SizedBox(height: Responsive.height(16)),
                  Text(
                    'Opening camera...',
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
            title: Text('Error'),
            content: Text('Failed to open camera: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  // Method to show confirmation dialog after image capture
  void _showImageCapturedDialog(
      String category, String subcategory, File imageFile)
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                _isUploading ? 'Uploading Item' : 'Item Captured',
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
                      'Your $subcategory has been successfully captured and identified using Google Vision AI.',
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
                              child: CircularProgressIndicator(
                                value: _uploadProgress,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(appcolor),
                                strokeWidth: 5,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Adding to your wardrobe...',
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
                    'Cancel',
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

                    try {
                      await _wardrobeController.uploadWardrobeItem(
                          category: category,
                          subCategory: subcategory,
                          imageFile: imageFile,
                          avatarurl: profileImage!,
                          token: token);

                      // Complete the progress animation
                      _completeUploadProgress(setState);

                      // Slight delay to show 100% completion
                      await Future.delayed(Duration(milliseconds: 500));

                      _getUserInfoAndLoadItems();

                      if (context.mounted) {
                        _uploadProgressTimer?.cancel();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Image successfully saved to wardrobe under "$category > $subcategory".',
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    } catch (e) {
                      // Complete progress animation even on error
                      _completeUploadProgress(setState);

                      await Future.delayed(Duration(milliseconds: 500));

                      if (context.mounted) {
                        _uploadProgressTimer?.cancel();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to save image: ${e.toString()}',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    'Add to Wardrobe',
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

    _uploadProgressTimer = Timer.periodic(Duration(milliseconds: interval), (timer) {
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
  void _completeUploadProgress(StateSetter setState) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Calendar',
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
                        selectedDayPredicate: (day) {
                          return isSameDay(selectedDay, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          controller.selectedDayNotifier.value = selectedDay;
                          controller.focusedDayNotifier.value = focusedDay;
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                          _checkExistingOutfit(selectedDay);
                        },
                        // onFormatChanged: (format) {
                        //   controller.calendarFormatNotifier.value = format;
                        // },
                        onPageChanged: (focusedDay) {
                          controller.focusedDayNotifier.value = focusedDay;
                        },
                        calendarStyle: CalendarStyle(
                          markersMaxCount: 3,
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
                      ),
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
}