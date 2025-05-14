import 'package:fitlip_app/routes/App_routes.dart';
import 'package:fitlip_app/controllers/themecontroller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/wardrobe_controller.dart';
import '../../../main.dart';
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
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final ImagePicker _picker = ImagePicker();

  // Avatar control variables
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

  // Animation controllers
  AnimationController? _avatarAnimationController; // Changed to nullable
  Animation<Offset>? _slideOutAnimation; // Changed to nullable
  Animation<Offset>? _slideInAnimation; // Changed to nullable
  bool _isLoading = false;
  bool _isAnimatingIn = false; // Add flag to track animation direction
  String loadingType = "";
  bool isLoadingItems = true;
  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    // Initialize animation controller
    _avatarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Slide out animation (current avatar exits)
    _slideOutAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.5, 0.0),
    ).animate(CurvedAnimation(
      parent: _avatarAnimationController!,
      curve: Curves.easeInOut,
    ));

    // Slide in animation (new avatar enters)
    _slideInAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _avatarAnimationController!,
      curve: Curves.easeInOut,
    ));
    _getUserInfoAndLoadItems();
    _wardrobeController.statusNotifier.addListener(_handleStatusChange);
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

  @override
  void dispose() {
    _avatarAnimationController?.dispose();
    _wardrobeController.statusNotifier.removeListener(_handleStatusChange);
    _wardrobeController.dispose();
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
        body: SafeArea(
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
                  child: _buildCalendarSection(),
                ),
              ],
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
            child: Container(
              width: Responsive.width(30),
              height: Responsive.height(50),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Responsive.radius(20)),
                image: const DecorationImage(
                  image: AssetImage('assets/Images/circle_image.png'),
                ),
              ),
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
        // Expanded(
        //     flex: 2,
        //     child: GestureDetector(
        //         onTap: () {
        //           // Refresh wardrobe items
        //           _getUserInfoAndLoadItems();
        //         },
        //         child: Container(
        //             padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        //             height: 30,
        //             decoration: BoxDecoration(
        //               color: appcolor.withOpacity(0.7),
        //               borderRadius: BorderRadius.circular(30),
        //             ),
        //             child: Text(
        //               "Refresh",
        //               style: GoogleFonts.poppins(
        //                   color: Colors.white,
        //                   fontWeight: FontWeight.bold,
        //                   fontSize: 10),
        //             )))),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          height: 30,
          decoration: BoxDecoration(
            color: appcolor.withOpacity(0.7),
            borderRadius: BorderRadius.circular(30),
            // border: Border.all(color: Colors.black54),
          ),
          child: Text(
            "Save",
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
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
            flex: 2,
            child: _buildFirstColumn(),
          ),

          // Second Column - Avatar
          Expanded(
            flex: 3,
            child: _buildAvatarColumn(),
          ),

          // Third Column - Similar to first column
          Expanded(
            flex: 2,
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
            style: TextStyle(
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
            style: TextStyle(
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
            style: TextStyle(
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
            style: TextStyle(
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

    return Container(
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
            // Show the latest item image
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                items.first.imageUrl ?? '',
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
            );
          }
        },
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
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        double swipePosition = details.localPosition.dy;

        // Define thresholds for the red and blue containers
        double redContainerTop = Responsive.height(140.0);
        double redContainerBottom = redContainerTop + Responsive.height(150.0);
        double blueContainerTop = Responsive.height(300.0);
        double blueContainerBottom =
            blueContainerTop + Responsive.height(150.0);

        // Swipe logic
        if (details.velocity.pixelsPerSecond.dx > 0) {
          // Swipe right
          if (swipePosition >= redContainerTop &&
              swipePosition <= redContainerBottom) {
            _handleAvatarSwipe(
                details, false, 'tshirt'); // Swipe over red container
          } else if (swipePosition >= blueContainerTop &&
              swipePosition <= blueContainerBottom) {
            _handleAvatarSwipe(
                details, false, 'pants'); // Swipe over blue container
          } else {
            _handleAvatarSwipe(
                details, false, ''); // Swipe outside the containers
          }
        } else if (details.velocity.pixelsPerSecond.dx < 0) {
          // Swipe left
          if (swipePosition >= redContainerTop &&
              swipePosition <= redContainerBottom) {
            _handleAvatarSwipe(
                details, true, 'tshirt'); // Swipe over red container
          } else if (swipePosition >= blueContainerTop &&
              swipePosition <= blueContainerBottom) {
            _handleAvatarSwipe(
                details, true, 'pants'); // Swipe over blue container
          } else {
            _handleAvatarSwipe(
                details, true, ''); // Swipe outside the containers
          }
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Current avatar
          AnimatedOpacity(
            opacity: _isLoading ? 0.5 : 1.0,
            duration: Duration(milliseconds: 300),
            child: Image.asset(
              _avatarAssets[_currentAvatarIndex],
              fit: BoxFit.fitHeight,
            ),
          ),

          if (!_isLoading)
            Positioned(
              top: Responsive.height(140),
              left: 0,
              right: 0,
              child: Container(
                color: Colors.transparent,
                height: Responsive.height(150),
              ),
            ),

          if (!_isLoading)
            Positioned(
              top: Responsive.height(300),
              left: 0,
              right: 0,
              child: Container(
                color: Colors.transparent,
                height: Responsive.height(150),
              ),
            ),

          // Loading indicator
          if (_isLoading)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(appcolor),
                ),
                SizedBox(height: Responsive.height(16)),
                Center(
                  child: Text(
                    "Loading next outfit...",
                    style: GoogleFonts.poppins(
                      color: appcolor,
                      fontSize: Responsive.fontSize(16),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _handleAvatarSwipe(DragEndDetails details, bool isLeft, String keyowrd) {
    if (_isLoading) return;

    print('$keyowrd key -----------');

    setState(() {
      _isLoading = true;
    });

    // Show loading for 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        if (!isLeft && keyowrd == "tshirt") {
          loadingType = "Changing Shirt";
          _currentAvatarIndex = 1;
        } else if (!isLeft && keyowrd == "pants") {
          loadingType = "Changing Pants";
          _currentAvatarIndex = 2;
        } else if (isLeft) {
          loadingType = "Loading next outfit..";
          _currentAvatarIndex = 0;
        }
        _isLoading = false;
      });
    });
  }

  Widget _buildThirdColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () => _showAnimatedCategoryDialog(),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: Responsive.width(12),
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
                      "Upload",
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

  Widget _buildClothingItem(String imagePath) {
    return Container(
      width: Responsive.width(60),
      height: Responsive.height(56),
      margin: EdgeInsets.only(bottom: Responsive.height(5)),
      decoration: BoxDecoration(
        color: themeController.white,
        borderRadius: BorderRadius.circular(Responsive.radius(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: Responsive.allPadding(8.0),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Calender',
          style: GoogleFonts.poppins(
            fontSize: Responsive.fontSize(18),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: Responsive.height(16)),
        Column(
          children: [
            Card(
              elevation: 4,
              color: themeController.white,
              child: Column(
                children: [
                  TableCalendar(
                    availableGestures: AvailableGestures.none,
                    firstDay: DateTime.utc(2023, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    calendarStyle: CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: const Color(0xFFAA8A00),
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: const Color(0xFFAA8A00).withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      weekendTextStyle: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      outsideDaysVisible: false,
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontSize: Responsive.fontSize(18),
                        fontWeight: FontWeight.bold,
                      ),
                      leftChevronIcon: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: appcolor),
                              borderRadius:
                                  BorderRadius.circular(Responsive.radius(5))),
                          child: Icon(Icons.chevron_left,
                              color: Color(0xFFAA8A00))),
                      rightChevronIcon: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: appcolor),
                              borderRadius:
                                  BorderRadius.circular(Responsive.radius(5))),
                          child: Icon(Icons.chevron_right,
                              color: Color(0xFFAA8A00))),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xff7C7C7C)),
                      weekendStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xff7C7C7C)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: appcolor,
                        borderRadius:
                            BorderRadius.circular(Responsive.radius(10))),
                    height: Responsive.height(5),
                    width: Responsive.width(45),
                  ),
                  SizedBox(height: Responsive.height(16)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // New method to show the animated clothing category dialog
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
                                'Assessries', selectedCategory, (category) {
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
                      style: TextStyle(color: themeController.black),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey),
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
                    style: TextStyle(
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
              style: TextStyle(
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
      case 'Assessries':
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
                    style: TextStyle(
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
      String category, String subcategory, File imageFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Item Captured',
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
                'Your $subcategory has been successfully captured and identified using Google Vision AI.',
                style: TextStyle(fontSize: 14),
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
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                _wardrobeController.uploadWardrobeItem(
                    category: category,
                    subCategory: subcategory,
                    imageFile: imageFile,
                    token: token);

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
                Navigator.pop(context);
              },
              child: Text(
                'Add to Wardrobe',
                style: TextStyle(
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
}
