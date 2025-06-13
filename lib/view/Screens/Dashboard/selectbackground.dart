import  'dart:core';
import 'dart:io';
import 'dart:async';

import 'package:fitlip_app/view/Utils/Colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../controllers/background_image_controller.dart';
import '../../../controllers/outfit_controller.dart';
import '../../../controllers/wardrobe_controller.dart';
import '../../../model/background_image_model.dart';
import '../../../model/wardrobe_model.dart';
import '../../Utils/globle_variable/globle.dart';
import '../../Utils/responsivness.dart';
import '../../Widgets/custom_message.dart';

class BackgroundSelectionSheet extends StatefulWidget {
  final Function(String) onBackgroundSelected;
  final String currentBackgroundPath;
  final Color appColor;

  const BackgroundSelectionSheet({
    Key? key,
    required this.onBackgroundSelected,
    required this.currentBackgroundPath,
    required this.appColor,
  }) : super(key: key);

  @override
  State<BackgroundSelectionSheet> createState() =>
      _BackgroundSelectionSheetState();
}

class _BackgroundSelectionSheetState extends State<BackgroundSelectionSheet>
    with TickerProviderStateMixin {
  List<BackgroundImageModel> _apiBackgrounds = [];
  bool _isLoadingBackgrounds = false;
  final BackgroundImageController _backgroundImageController = BackgroundImageController();
// Update your initState method
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _getUserInfoAndLoadItems();
    _loadBackgroundImages(); // Add this line
  }

// Add this method to load background images from API
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

// Add this method to get auth token (implement according to your auth system)

  final ImagePicker _picker = ImagePicker();
  bool _isGenerating = false;
  String _generatePrompt = "";
  final WardrobeController _wardrobeController = WardrobeController();
  late TabController _tabController;
  bool isLoadingItems = true;
  String? profileImage;
  // Upload progress variables
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  Timer? _uploadProgressTimer;



  Future<void> _getUserInfoAndLoadItems() async {
    try {
      setState(() {
        isLoadingItems = true;
      });
      await _wardrobeController.loadWardrobeItems();
      setState(() {
        isLoadingItems = false;
      });
    } catch (e) {
      print("Error getting user info: $e");
      setState(() {
        isLoadingItems = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _uploadProgressTimer?.cancel();
    _backgroundImageController.dispose();
    super.dispose();
  }

  // Updated backgrounds list with unique identifiers
  final List<Map<String, String>> backgrounds = [
    {
      'id': 'back2_winter',
      'path': 'assets/Images/back2.png',
      'name': 'Winter Scene'
    },
    {
      'id': 'back1_mountain',
      'path': 'assets/Images/back1.png',
      'name': 'Mountain View'
    },
    {
      'id': 'back3_forest',
      'path': 'assets/Images/back3.png',
      'name': 'Forest Path'
    },
  ];

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        await _generateFromImageFile(File(image.path));
      }
    } catch (e) {
      _showErrorSnackBar("Failed to capture image: $e");
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        await _generateFromImageFile(File(image.path));
      }
    } catch (e) {
      _showErrorSnackBar("Failed to select image: $e");
    }
  }

  Future<void> _generateFromImageFile(File imageFile) async {

    if (token == null) {
      _showErrorSnackBar("Authentication required");
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final success = await _backgroundImageController.generateFromImage(
        token: token!,
        imageFile: imageFile,
      );

      if (success) {
        showAppSnackBar(context,'Background generated successfully!', backgroundColor: appcolor);
        await _loadBackgroundImages();

        Navigator.pop(context); // Close the bottom sheet

      } else {
        final error = _backgroundImageController.errorNotifier.value;
        _showErrorSnackBar(error ?? "Failed to generate background from image");
      }
    } catch (e) {
      _showErrorSnackBar("Error generating background: $e");
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }
  Future<void> _selectApiBackground(BackgroundImageModel background) async {
    if (token == null) {
      _showErrorSnackBar("Authentication required");
      return;
    }

    try {
      final success = await _backgroundImageController.changeImageStatus(
        token: token!,
        backgroundImageId: background.id,
      );

      if (success) {
        // Set as current background
        widget.onBackgroundSelected(background.imageUrl);

        showAppSnackBar(context, 'Background selected successfully!', backgroundColor: appcolor);

        // Refresh the background images list
        await _loadBackgroundImages();

        Navigator.pop(context);
      } else {
        final error = _backgroundImageController.errorNotifier.value;
        _showErrorSnackBar(error ?? "Failed to select background");
      }
    } catch (e) {
      _showErrorSnackBar("Error selecting background: $e");
    }
  }
  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(20),
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.photo_camera, color: appcolor),
                  title: const Text("Take a Photo"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library, color: appcolor),
                  title: const Text("Choose from Gallery"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Category selection dialog for wardrobe items
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
              backgroundColor: Colors.white,
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
                      style: GoogleFonts.poppins(color: Colors.black),
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
        _showImageCapturedDialog(category, subcategory, imageFile);
      }
    } catch (e) {
      // Close loading dialog in case of error
      Navigator.pop(context);
      _showErrorSnackBar("Failed to open camera: $e");
    }
  }

  void _showImageCapturedDialog(
      String category, String subcategory, File imageFile) {
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
                  ? []
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
                    setState(() {
                      _isUploading = true;
                      _uploadProgress = 0.0;
                    });

                    _startUploadProgressAnimation(setState);

                    try {
                      await _wardrobeController.uploadWardrobeItem(
                          category: category,
                          subCategory: subcategory,
                          imageFile: imageFile,
                          avatarurl: profileImage!,
                          context: context,
                          token: token);

                      _completeUploadProgress(setState);
                      await Future.delayed(Duration(milliseconds: 5000));
                      await _getUserInfoAndLoadItems();

                      _uploadProgressTimer?.cancel();
                      Navigator.pop(context);
                    } catch (e) {
                      await _completeUploadProgress(setState);
                      await Future.delayed(Duration(milliseconds: 500));

                      if (context.mounted) {
                        _uploadProgressTimer?.cancel();
                        Navigator.pop(context);
                        _showErrorSnackBar('Failed to save image: ${e.toString()}');
                      }
                      await _getUserInfoAndLoadItems();
                    }
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
      },
    );
  }

  void _startUploadProgressAnimation(StateSetter setState) {
    _uploadProgressTimer?.cancel();

    const totalDuration = 3000;
    const interval = 50;
    const steps = totalDuration ~/ interval;
    const incrementPerStep = 0.95 / steps;

    _uploadProgressTimer = Timer.periodic(Duration(milliseconds: interval), (timer) {
      if (_uploadProgress >= 0.95) {
        timer.cancel();
      } else {
        setState(() {
          _uploadProgress += incrementPerStep;
          if (_uploadProgress > 0.95) _uploadProgress = 0.95;
        });
      }
    });
  }

  Future<void> _completeUploadProgress(StateSetter setState) async {
    _uploadProgressTimer?.cancel();

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

  Future<void> _generateFromPrompt() async {
    if (_generatePrompt.trim().isEmpty) {
      _showErrorSnackBar("Please enter a prompt");
      return;
    }


    if (token == null) {
      _showErrorSnackBar("Authentication required");
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final success = await _backgroundImageController.generateFromPrompt(
        token: token!,
        prompt: _generatePrompt,
      );

      if (success) {
        showAppSnackBar(context,'Background generated successfully!', backgroundColor: appcolor);

        await _loadBackgroundImages();
        Navigator.pop(context);
        // _showSuccessSnackBar("");
        // Refresh the backgrounds list

      } else {
        final error = _backgroundImageController.errorNotifier.value;
        _showErrorSnackBar(error ?? "Failed to generate background");
      }
    } catch (e) {
      _showErrorSnackBar("Error generating background: $e");
    } finally {
      setState(() {
        _isGenerating = false;
        _generatePrompt = "";
      });
    }
  }


  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: Responsive.fontSize(12)),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: Responsive.allPadding(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Responsive.radius(8)),
        ),
      ),
    );
  }

  Widget _buildBackgroundTab() {
    return Padding(
      padding: Responsive.allPadding(16),
      child: Stack(
        children: [
          Column(
            children: [
              // AI Generation Section
              Card(
                child: Container(
                  padding: Responsive.allPadding(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Responsive.radius(12)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.amber,
                        size: Responsive.fontSize(20),
                      ),
                      SizedBox(width: Responsive.width(8)),
                      Expanded(
                        child: TextField(
                          onChanged: (value) => _generatePrompt = value,
                          decoration: InputDecoration(
                            hintText: "Generate From any Prompt",
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.grey[500],
                              fontSize: Responsive.fontSize(12),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: GoogleFonts.poppins(fontSize: Responsive.fontSize(12)),
                        ),
                      ),
                      SizedBox(width: Responsive.width(8)),
                      Container(
                        height: Responsive.height(32),
                        child: ElevatedButton(
                          onPressed: _isGenerating ? null : _generateFromPrompt,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appcolor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Responsive.radius(16)),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: Responsive.width(16)),
                          ),
                          child: _isGenerating
                              ? SizedBox(
                            height: Responsive.height(16),
                            width: Responsive.width(16),
                            child: LoadingAnimationWidget.fourRotatingDots(
                                color:appcolor,size:20
                            ),
                          )
                              : Text(
                            "Send",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: Responsive.fontSize(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: Responsive.height(16)),

              // Background Grid - Only API Backgrounds
              Expanded(
                child: _isLoadingBackgrounds
                    ? Center(
                  child: LoadingAnimationWidget.fourRotatingDots(
                      color:appcolor,size:20
                  ),
                )
                    : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: Responsive.width(8),
                    mainAxisSpacing: Responsive.height(8),
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _apiBackgrounds.length,
                  itemBuilder: (context, index) {
                    final apiBackground = _apiBackgrounds[index];
                    final isSelected = widget.currentBackgroundPath == apiBackground.imageUrl ||
                        apiBackground.status;

                    return GestureDetector(
                      onTap: () => _selectApiBackground(apiBackground),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Responsive.radius(14)),
                          border: Border.all(
                            color: isSelected ? widget.appColor : Colors.grey[300]!,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Responsive.radius(11)),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                apiBackground.imageUrl,
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
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                        size: Responsive.fontSize(20),
                                      ),
                                    ),
                              ),
                              // Selection overlay
                              if (isSelected)
                                Container(
                                  color: widget.appColor.withOpacity(0.3),
                                  child: Center(
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: Responsive.fontSize(24),
                                    ),
                                  ),
                                ),
                              // Status indicator for active backgrounds
                              if (apiBackground.status)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.star,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: Responsive.height(16)),

              // Bottom Container
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border(
                        top: BorderSide(
                          color: widget.appColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: SizedBox(height: 40, width: double.infinity),
                  ),
                ],
              )
            ],
          ),
          Positioned(
            bottom: Responsive.height(10),
            right: Responsive.width(130),
            child: Container(
              width: Responsive.width(60),
              height: Responsive.height(60),
              decoration: BoxDecoration(
                color: widget.appColor,
                shape: BoxShape.circle,
              ),
              child: GestureDetector(
                onTap: _showImagePickerBottomSheet,
                child: Image.asset('assets/Icons/camera.png', scale: 3),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildWardrobeTab() {
    return Padding(
      padding: Responsive.allPadding(16),
      child: Stack(
        children: [
          Column(
            children: [



              // Wardrobe Items
              Expanded(
                child: isLoadingItems
                    ? Center(child: LoadingAnimationWidget.fourRotatingDots(        color:appcolor,size:20))
                    : _buildWardrobeItems(),
              ),

              // Bottom Container
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border(
                        top: BorderSide(
                          color: appcolor,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: SizedBox(height: 40, width: double.infinity),
                  ),
                ],
              ),
            ],
          ),

          // Camera Button - Updated to show category dialog
          Positioned(
            bottom: Responsive.height(10),
            right: Responsive.width(130),
            child: Container(
              width: Responsive.width(60),
              height: Responsive.height(60),
              decoration: BoxDecoration(
                color: appcolor,
                shape: BoxShape.circle,
              ),
              child: GestureDetector(
                onTap: () => _showAnimatedCategoryDialog(context),
                child: Image.asset('assets/Icons/camera.png', scale: 3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWardrobeItems() {
    return ValueListenableBuilder<List<WardrobeItem>>(
      valueListenable: _wardrobeController.shirtsNotifier,
      builder: (context, shirts, _) {
        return ValueListenableBuilder<List<WardrobeItem>>(
          valueListenable: _wardrobeController.pantsNotifier,
          builder: (context, pants, _) {
            return ValueListenableBuilder<List<WardrobeItem>>(
              valueListenable: _wardrobeController.shoesNotifier,
              builder: (context, shoes, _) {
                return ValueListenableBuilder<List<WardrobeItem>>(
                  valueListenable: _wardrobeController.accessoriesNotifier,
                  builder: (context, accessories, _) {
                    // Check if all categories are empty
                    if (shirts.isEmpty && pants.isEmpty && shoes.isEmpty && accessories.isEmpty) {
                      return _buildAllCategoriesEmptyState();
                    }

                    return ListView(
                      children: [
                        if (shirts.isNotEmpty)
                          _buildWardrobeCategorySection('Shirts', shirts)
                        else
                          _buildEmptyCategoryState('shirts'),

                        if (pants.isNotEmpty)
                          _buildWardrobeCategorySection('Pants', pants)
                        else
                          _buildEmptyCategoryState('pants'),

                        if (shoes.isNotEmpty)
                          _buildWardrobeCategorySection('Shoes', shoes)
                        else
                          _buildEmptyCategoryState('shoes'),

                        if (accessories.isNotEmpty)
                          _buildWardrobeCategorySection('Accessories', accessories)
                        else
                          _buildEmptyCategoryState('accessories'),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
  Widget _buildEmptyCategoryState(String category) {
    String categoryName = category[0].toUpperCase() + category.substring(1);
    String message = 'No $category available in your wardrobe';

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: Responsive.height(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Category Header
          Text(
          categoryName,
          style: GoogleFonts.poppins(
            fontSize: Responsive.fontSize(16),
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: Responsive.height(8)),

        // Empty state message
        Card(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(Responsive.width(16)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Responsive.radius(12)),
            ),
            child: Column(
                children: [
                Icon(
                _getIconForCategory(category),
            size: Responsive.fontSize(24),
            color: Colors.grey[400],
          ),
          SizedBox(height: Responsive.height(8)),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: Responsive.fontSize(12),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          // SizedBox(height: Responsive.height(8)),
          // ElevatedButton(
          //   onPressed: () => _showAnimatedCategoryDialog(context),
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: appcolor,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(Responsive.radius(20)),
          //     ),
          //     padding: EdgeInsets.symmetric(
          //         horizontal: Responsive.width(16),
          //         vertical: Responsive.height(8)),
          //   ),
          //
          // child: Text(
          //   'Add $categoryName',
          //   style: GoogleFonts.poppins(
          //     color: Colors.white,
          //     fontSize: Responsive.fontSize(12),
          //   ),
          // ),
          //       ),
                ],
              ),
              ),
        ),
    ],
    ),
    );
  }
  Widget _buildWardrobeCategorySection(String categoryName, List<WardrobeItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Header
        Text(
          categoryName,
          style: GoogleFonts.poppins(
            fontSize: Responsive.fontSize(16),
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: Responsive.height(8)),

        // Items Grid
        SizedBox(
          height: Responsive.height(120),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildWardrobeItemCard(item, categoryName.toLowerCase());
            },
          ),
        ),

        SizedBox(height: Responsive.height(16)),
      ],
    );
  }

  Widget _buildWardrobeItemCard(WardrobeItem item, String category) {
    bool isSelected = _isItemSelectedInCategory(item.id!, category);

    return GestureDetector(
      onTap: () => _selectWardrobeItem(item.id!, category),
      child: Container(
        width: Responsive.width(80),
        margin: EdgeInsets.only(right: Responsive.width(8)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Responsive.radius(12)),
          border: Border.all(
            color: isSelected ? appcolor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: appcolor.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ]
              : [],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(Responsive.radius(11)),
              child: Image.network(
                item.imageUrl ?? '',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: Icon(
                    _getIconForCategory(category),
                    color: Colors.grey,
                    size: Responsive.fontSize(20),
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[100],
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: LoadingAnimationWidget.fourRotatingDots(
                            color:appcolor,size:20
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Selection indicator
            if (isSelected)
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
                    Icons.check,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),

            // Item name overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.width(4),
                  vertical: Responsive.height(2),
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(Responsive.radius(11)),
                    bottomRight: Radius.circular(Responsive.radius(11)),
                  ),
                ),
                child: Text(
                  item.category ?? 'Item',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: Responsive.fontSize(8),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllCategoriesEmptyState() {
    return Container(
      height: Responsive.height(200),
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.width(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Your wardrobe is empty',
            style: GoogleFonts.poppins(
              fontSize: Responsive.fontSize(16),
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: Responsive.height(8)),
          Text(
            'Add items to get started',
            style: GoogleFonts.poppins(
              fontSize: Responsive.fontSize(12),
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: Responsive.height(16)),
          ElevatedButton(
            onPressed: _pickImageFromGallery,
            style: ElevatedButton.styleFrom(
              backgroundColor: appcolor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Responsive.radius(20)),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.width(24),
                vertical: Responsive.height(12),
              ),
            ),
            child: Text(
              'Add First Item',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: Responsive.fontSize(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isItemSelectedInCategory(String itemId, String category) {
    switch (category) {
      case 'shirts':
        return selectedShirtId == itemId;
      case 'pants':
        return selectedPantId == itemId;
      case 'shoes':
        return selectedShoeId == itemId;
      case 'accessories':
        return selectedAccessoryId == itemId;
      default:
        return false;
    }
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'shirts':
        return FontAwesomeIcons.shirt;
      case 'pants':
        return FontAwesomeIcons.personHalfDress;
      case 'shoes':
        return FontAwesomeIcons.shoePrints;
      case 'accessories':
        return FontAwesomeIcons.glasses;
      default:
        return FontAwesomeIcons.tag;
    }
  }

  void _selectWardrobeItem(String itemId, String category) {
    setState(() {
      switch (category) {
        case 'shirts':
          selectedShirtId = itemId;
          break;
        case 'pants':
          selectedPantId = itemId;
          break;
        case 'shoes':
          selectedShoeId = itemId;
          break;
        case 'accessories':
          selectedAccessoryId = itemId;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Responsive.height(600),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Responsive.radius(20)),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: Responsive.verticalPadding(10),
            width: Responsive.width(50),
            height: Responsive.height(5),
            decoration: BoxDecoration(
              color: appcolor,
              borderRadius: BorderRadius.circular(Responsive.radius(10)),
            ),
          ),

          Container(
            margin: Responsive.horizontalPadding(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Responsive.radius(25)),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Responsive.radius(25)),
              ),
              labelColor: appcolor,
              unselectedLabelColor: appcolor,
              labelStyle: GoogleFonts.poppins(
                fontSize: Responsive.fontSize(14),
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontSize: Responsive.fontSize(14),
                fontWeight: FontWeight.normal,
              ),
              tabs: [
                Tab(text: "Backgrounds"),
                Tab(text: "Wardrobe"),
              ],
            ),
          ),

          SizedBox(height: Responsive.height(16)),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBackgroundTab(),
                _buildWardrobeTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}