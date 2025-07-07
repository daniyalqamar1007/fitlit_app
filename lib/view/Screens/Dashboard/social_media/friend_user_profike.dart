// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import '../../../../model/user_suggestion_model.dart';
// import '../../../Utils/Colors.dart';
// import '../../../Utils/responsivness.dart';

// class UserProfilePage extends StatefulWidget {
//   final UserSuggestionModel user;
//   final Function(UserSuggestionModel)? onFollowToggle;

//   const UserProfilePage({
//     Key? key,
//     required this.user,
//     this.onFollowToggle,
//   }) : super(key: key);

//   @override
//   State<UserProfilePage> createState() => _UserProfilePageState();
// }

// class _UserProfilePageState extends State<UserProfilePage> {
//   late UserSuggestionModel currentUser;
//   bool isFollowLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     currentUser = widget.user;
//     print(currentUser);
//   }

//   Future<void> _toggleFollow() async {
//     if (isFollowLoading) return;

//     setState(() {
//       isFollowLoading = true;
//     });

//     try {
//       final success = await _performFollowAction();
//       if (success) {
//         setState(() {
//           currentUser = currentUser.copyWith(
//             isFollowing: !currentUser.isFollowing,
//             followers: currentUser.isFollowing
//                 ? currentUser.followers - 1
//                 : currentUser.followers + 1,
//           );
//         });

//         if (widget.onFollowToggle != null) {
//           widget.onFollowToggle!(currentUser);
//         }
//       }
//     } catch (e) {
//       print('Follow error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to ${currentUser.isFollowing ? 'unfollow' : 'follow'} user'),
//         ),
//       );
//     } finally {
//       setState(() {
//         isFollowLoading = false;
//       });
//     }
//   }

//   Future<bool> _performFollowAction() async {
//     await Future.delayed(Duration(seconds: 1));
//     return true;
//   }

//   void _showAvatarDialog(String imageUrl) {
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (BuildContext context) {
//         return Dialog(
//           backgroundColor: Colors.transparent,
//           child: GestureDetector(
//             onTap: () => Navigator.of(context).pop(),
//             child: Container(
//               width: double.infinity,
//               height: MediaQuery.of(context).size.height * 0.8,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: CachedNetworkImage(
//                   imageUrl: imageUrl,
//                   fit: BoxFit.contain,
//                   placeholder: (context, url) => Container(
//                     color: Colors.black26,
//                     child: Center(
//                       child: LoadingAnimationWidget.fourRotatingDots(
//                         color: Colors.white,
//                         size: 40,
//                       ),
//                     ),
//                   ),
//                   errorWidget: (context, url, error) => Container(
//                     color: Colors.black26,
//                     child: Center(
//                       child: Icon(
//                         Icons.error,
//                         color: Colors.white,
//                         size: 50,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         surfaceTintColor: Colors.white,
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: appcolor),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Text(
//           currentUser.name ?? 'User Profile',
//           style: GoogleFonts.poppins(
//             color: appcolor,
//             fontSize: Responsive.fontSize(18),
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: false,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Profile Header Section
//             Container(
//               width: double.infinity,
//               padding: EdgeInsets.all(Responsive.width(20)),
//               child: Column(
//                 children: [
//                   // Profile Picture and Stats Row
//                   Row(
//                     children: [
//                       // Profile Picture
//                       Container(
//                         width: Responsive.width(90),
//                         height: Responsive.width(90),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: appcolor,
//                             width: 3,
//                           ),
//                         ),
//                         child: ClipOval(
//                           child: currentUser.profilePhoto?.isNotEmpty == true
//                               ? CachedNetworkImage(
//                                   imageUrl: currentUser.profilePhoto!,
//                                   fit: BoxFit.cover,
//                                   alignment: Alignment.topCenter,
//                                   placeholder: (context, url) => Container(
//                                     color: Colors.grey[200],
//                                     child: Center(
//                                       child: LoadingAnimationWidget.fourRotatingDots(
//                                         color: appcolor,
//                                         size: Responsive.height(25),
//                                       ),
//                                     ),
//                                   ),
//                                   errorWidget: (context, url, error) => Container(
//                                     color: Colors.grey[200],
//                                     child: Center(
//                                       child: Icon(
//                                         Icons.person,
//                                         color: Colors.grey,
//                                         size: Responsive.height(45),
//                                       ),
//                                     ),
//                                   ),
//                                 )
//                               : Container(
//                                   color: Colors.grey[200],
//                                   child: Center(
//                                     child: Icon(
//                                       Icons.person,
//                                       color: Colors.grey,
//                                       size: Responsive.height(45),
//                                     ),
//                                   ),
//                                 ),
//                         ),
//                       ),
                      
//                       SizedBox(width: Responsive.width(30)),
                      
//                       // Stats Section
//                       Expanded(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             _buildStatItem('Following', currentUser.following),
//                             _buildStatItem('Followers', currentUser.followers),
//                             _buildStatItem('Avatars', currentUser.avatars.length),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
                  
//                   SizedBox(height: Responsive.height(30)),
                  
//                   // Action Buttons Row - Fixed alignment and added icons
//                   Row(
//                     children: [
//                       // Follow/Unfollow Button
//                       Expanded(
//                         flex: 2,
//                         child: SizedBox(
//                           height: Responsive.height(48),
//                           child: ElevatedButton.icon(
//                             onPressed: isFollowLoading ? null : _toggleFollow,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: currentUser.isFollowing
//                                   ? Colors.grey[300]
//                                   : appcolor,
//                               foregroundColor: currentUser.isFollowing
//                                   ? Colors.black87
//                                   : Colors.white,
//                               elevation: 0,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(
//                                   Responsive.radius(12),
//                                 ),
//                               ),
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: Responsive.width(16),
//                                 vertical: Responsive.height(12),
//                               ),
//                             ),
//                             icon: isFollowLoading
//                                 ? SizedBox(
//                                     width: Responsive.width(16),
//                                     height: Responsive.height(16),
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 2,
//                                       valueColor: AlwaysStoppedAnimation<Color>(
//                                         currentUser.isFollowing
//                                             ? Colors.black54
//                                             : Colors.white,
//                                       ),
//                                     ),
//                                   )
//                                 : Icon(
//                                     currentUser.isFollowing 
//                                         ? Icons.person_remove 
//                                         : Icons.person_add,
//                                     size: Responsive.height(18),
//                                   ),
//                             label: Text(
//                               currentUser.isFollowing ? 'Unfollow' : 'Follow',
//                               style: GoogleFonts.poppins(
//                                 fontSize: Responsive.fontSize(14),
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
                      
//                       SizedBox(width: Responsive.width(12)),
                      
//                       // Message Button
//                       Expanded(
//                         flex: 2,
//                         child: SizedBox(
//                           height: Responsive.height(48),
//                           child: OutlinedButton.icon(
//                             onPressed: () {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text('Message feature coming soon!'),
//                                 ),
//                               );
//                             },
//                             style: OutlinedButton.styleFrom(
//                               foregroundColor: appcolor,
//                               side: BorderSide(color: appcolor, width: 1.5),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(
//                                   Responsive.radius(12),
//                                 ),
//                               ),
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: Responsive.width(12),
//                                 vertical: Responsive.height(12),
//                               ),
//                             ),
//                             icon: Icon(
//                               Icons.message,
//                               size: Responsive.height(18),
//                             ),
//                             label: Text(
//                               'Message',
//                               style: GoogleFonts.poppins(
//                                 fontSize: Responsive.fontSize(14),
//                                 fontWeight: FontWeight.w600,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
            
//             SizedBox(height: Responsive.height(20)),
            
//             // Avatars Section Header
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: Responsive.width(20)),
//               child: Text(
//                 'Avatars',
//                 style: GoogleFonts.poppins(
//                   fontSize: Responsive.fontSize(18),
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
            
//             SizedBox(height: Responsive.height(16)),
            
//             // Avatars Grid Section
//             if (currentUser.avatars.isNotEmpty)
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: Responsive.width(20)),
//                 child: GridView.builder(
//                   shrinkWrap: true,
//                   physics: NeverScrollableScrollPhysics(),
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     crossAxisSpacing: Responsive.width(8),
//                     mainAxisSpacing: Responsive.height(8),
//                     childAspectRatio: 0.6,
//                   ),
//                   itemCount: currentUser.avatars.length,
//                   // print()
//                   itemBuilder: (context, index) {
//                     return GestureDetector(
//                       onTap: () => _showAvatarDialog(currentUser.avatars[index]),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(Responsive.radius(12)),
//                           border: Border.all(
//                             color: appcolor.withOpacity(0.3),
//                             width: 1,
//                           ),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.05),
//                               blurRadius: 4,
//                               offset: Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(Responsive.radius(11)),
//                           child: CachedNetworkImage(
//                             imageUrl: currentUser.avatars[index],
//                             fit: BoxFit.contain,
//                             placeholder: (context, url) => Container(
//                               color: Colors.grey[200],
//                               child: Center(
//                                 child: LoadingAnimationWidget.fourRotatingDots(
//                                   color: appcolor,
//                                   size: Responsive.height(20),
//                                 ),
//                               ),
//                             ),
//                             errorWidget: (context, url, error) => Container(
//                               color: Colors.grey[200],
//                               child: Center(
//                                 child: Icon(
//                                   Icons.image_not_supported,
//                                   color: Colors.grey,
//                                   size: Responsive.height(30),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
            
//             // Empty State for Avatars
//             if (currentUser.avatars.isEmpty)
//               Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.symmetric(
//                   horizontal: Responsive.width(20),
//                   vertical: Responsive.height(60),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.photo_library_outlined,
//                       size: Responsive.height(48),
//                       color: Colors.grey[400],
//                     ),
//                     SizedBox(height: Responsive.height(16)),
//                     Text(
//                       "No Avatars Saved Yet",
//                       style: GoogleFonts.poppins(
//                         color: Colors.grey.shade600,
//                         fontSize: Responsive.fontSize(16),
//                         fontWeight: FontWeight.w500,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     SizedBox(height: Responsive.height(8)),
//                     Text(
//                       "Avatars will appear here once they're added",
//                       style: GoogleFonts.poppins(
//                         color: Colors.grey.shade500,
//                         fontSize: Responsive.fontSize(14),
//                         fontWeight: FontWeight.w400,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
            
//             SizedBox(height: Responsive.height(30)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatItem(String label, int count) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           count.toString(),
//           style: GoogleFonts.poppins(
//             fontSize: Responsive.fontSize(24),
//             fontWeight: FontWeight.w700,
//             color: Colors.black,
//           ),
//         ),
//         SizedBox(height: Responsive.height(4)),
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//             fontSize: Responsive.fontSize(12),
//             fontWeight: FontWeight.w500,
//             color: Colors.grey[600],
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: Responsive.height(12)),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(
//             icon,
//             color: appcolor,
//             size: Responsive.height(20),
//           ),
//           SizedBox(width: Responsive.width(12)),
//           Text(
//             '$label: ',
//             style: GoogleFonts.poppins(
//               fontSize: Responsive.fontSize(14),
//               fontWeight: FontWeight.w500,
//               color: Colors.grey[700],
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: GoogleFonts.poppins(
//                 fontSize: Responsive.fontSize(14),
//                 fontWeight: FontWeight.w400,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:fitlip_app/view/Utils/globle_variable/globle.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../model/user_suggestion_model.dart';
import '../../../Utils/Colors.dart';
import '../../../Utils/responsivness.dart';

class UserProfilePage extends StatefulWidget {
  final UserSuggestionModel user;
  final Function(UserSuggestionModel)? onFollowToggle;

  const UserProfilePage({
    Key? key,
    required this.user,
    this.onFollowToggle,
  }) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late UserSuggestionModel currentUser;
  bool isFollowLoading = false;
  bool isAvatarsLoading = true;
  List<String> userAvatars = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
    print(currentUser);
    _fetchUserAvatars();
  }

  Future<void> _fetchUserAvatars() async {
    if (currentUser.userId == null) {
      setState(() {
        isAvatarsLoading = false;
        errorMessage = 'User ID not available';
      });
      return;
    }

    try {
      setState(() {
        isAvatarsLoading = true;
        errorMessage = null;
      });

      String? token = await _getAuthToken();
      final response = await _getUserAvatarsListWithBackground(
        widget.user.userId.toString(),
        token,
      );

      if (response['success'] == true && response['avatars'] != null) {
        List<dynamic> avatarData = response['avatars'] as List<dynamic>;
        setState(() {
          userAvatars = avatarData
              .where((item) => item != null && item.toString().isNotEmpty)
              .map((item) => item.toString())
              .toList();
          isAvatarsLoading = false;
        });
        print('Fetched ${userAvatars.length} avatars');
        print('Avatar URLs: $userAvatars');
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Failed to load avatars';
          isAvatarsLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching avatars: $e');
      setState(() {
        errorMessage = 'Failed to load avatars: ${e.toString()}';
        isAvatarsLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _getUserAvatarsListWithBackground(
    String userId,
    String? token,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/avatar/user-avatars-with-bg?userId=$userId');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      print('Making API call to: $uri');
      print('Headers: $headers');

      final response = await http.get(uri, headers: headers);
      print("Avatar API Response Code: ${response.statusCode}");
      print("Avatar API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print("HTTP Exception: $e");
      throw Exception('Network error: $e');
    }
  }

  Future<String?> _getAuthToken() async {
    return null; // Replace with actual token retrieval
  }

  Future<void> _toggleFollow() async {
    if (isFollowLoading) return;

    setState(() {
      isFollowLoading = true;
    });

    try {
      final success = await _performFollowAction();
      if (success) {
        setState(() {
          currentUser = currentUser.copyWith(
            isFollowing: !currentUser.isFollowing,
            followers: currentUser.isFollowing
                ? currentUser.followers - 1
                : currentUser.followers + 1,
          );
        });

        if (widget.onFollowToggle != null) {
          widget.onFollowToggle!(currentUser);
        }
      }
    } catch (e) {
      print('Follow error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to ${currentUser.isFollowing ? 'unfollow' : 'follow'} user'),
        ),
      );
    } finally {
      setState(() {
        isFollowLoading = false;
      });
    }
  }

  Future<bool> _performFollowAction() async {
    await Future.delayed(Duration(seconds: 1));
    return true;
  }

  void _showAvatarDialog(String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.black26,
                      child: Center(
                        child: LoadingAnimationWidget.fourRotatingDots(
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.black26,
                      child: Center(
                        child: Icon(
                          Icons.error,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appcolor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          currentUser.name ?? 'User Profile',
          style: GoogleFonts.poppins(
            color: appcolor,
            fontSize: Responsive.fontSize(18),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          // IconButton(
          //   icon: Icon(Icons.refresh, color: appcolor),
          //   onPressed: _fetchUserAvatars,
          //   tooltip: 'Refresh Avatars',
          // ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchUserAvatars,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(Responsive.width(20)),
                child: Column(
                  children: [
                    // Profile Picture and Stats Row
                    Row(
                      children: [
                        // Profile Picture
                        Container(
                          width: Responsive.width(90),
                          height: Responsive.width(90),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: appcolor,
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: currentUser.profilePhoto?.isNotEmpty == true
                                ? Image.network(
                                    currentUser.profilePhoto!,
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                    height: double.infinity,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: LoadingAnimationWidget.fourRotatingDots(
                                            color: appcolor,
                                            size: Responsive.height(25),
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.grey,
                                            size: Responsive.height(45),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                        size: Responsive.height(45),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(width: Responsive.width(30)),
                        // Stats Section
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatItem('Following', currentUser.following),
                              _buildStatItem('Followers', currentUser.followers),
                              _buildStatItem('Avatars', userAvatars.length),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.height(30)),
                    // Action Buttons Row
                    Row(
                      children: [
                        // Follow/Unfollow Button
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: Responsive.height(48),
                            child: ElevatedButton.icon(
                              onPressed: isFollowLoading ? null : _toggleFollow,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: currentUser.isFollowing
                                    ? Colors.grey[300]
                                    : appcolor,
                                foregroundColor: currentUser.isFollowing
                                    ? Colors.black87
                                    : Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    Responsive.radius(12),
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: Responsive.width(16),
                                  vertical: Responsive.height(12),
                                ),
                              ),
                              icon: isFollowLoading
                                  ? SizedBox(
                                      width: Responsive.width(16),
                                      height: Responsive.height(16),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          currentUser.isFollowing
                                              ? Colors.black54
                                              : Colors.white,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      currentUser.isFollowing
                                          ? Icons.person_remove
                                          : Icons.person_add,
                                      size: Responsive.height(18),
                                    ),
                              label: Text(
                                currentUser.isFollowing ? 'Unfollow' : 'Follow',
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.fontSize(14),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: Responsive.width(12)),
                        // Message Button
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: Responsive.height(48),
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Message feature coming soon!'),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: appcolor,
                                side: BorderSide(color: appcolor, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    Responsive.radius(12),
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: Responsive.width(12),
                                  vertical: Responsive.height(12),
                                ),
                              ),
                              icon: Icon(
                                Icons.message,
                                size: Responsive.height(18),
                              ),
                              label: Text(
                                'Message',
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.fontSize(14),
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.height(20)),
              // Avatars Section Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Responsive.width(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Avatars',
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.fontSize(18),
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    // if (isAvatarsLoading)
                    //   SizedBox(
                    //     width: Responsive.width(20),
                    //     height: Responsive.height(20),
                    //     child: CircularProgressIndicator(
                    //       strokeWidth: 2,
                    //       valueColor: AlwaysStoppedAnimation<Color>(appcolor),
                    //     ),
                    //   ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.height(16)),
              // Avatars Loading State
              if (isAvatarsLoading)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.width(20),
                    vertical: Responsive.height(60),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        LoadingAnimationWidget.fourRotatingDots(
                          color: appcolor,
                          size: Responsive.height(40),
                        ),
                        SizedBox(height: Responsive.height(16)),
                        Text(
                          'Loading avatars...',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                            fontSize: Responsive.fontSize(14),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Error State
              if (!isAvatarsLoading && errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.width(20),
                    vertical: Responsive.height(60),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: Responsive.height(48),
                        color: Colors.red[400],
                      ),
                      SizedBox(height: Responsive.height(16)),
                      Text(
                        "Failed to Load Avatars",
                        style: GoogleFonts.poppins(
                          color: Colors.red.shade600,
                          fontSize: Responsive.fontSize(16),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: Responsive.height(8)),
                      Text(
                        errorMessage!,
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade500,
                          fontSize: Responsive.fontSize(14),
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: Responsive.height(16)),
                      ElevatedButton.icon(
                        onPressed: _fetchUserAvatars,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appcolor,
                          foregroundColor: Colors.white,
                        ),
                        icon: Icon(Icons.refresh),
                        label: Text('Retry'),
                      ),
                    ],
                  ),
                ),
              // Avatars Grid Section
              if (!isAvatarsLoading && errorMessage == null && userAvatars.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.width(20)),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: Responsive.width(8),
                      mainAxisSpacing: Responsive.height(8),
                      childAspectRatio: 0.6,
                    ),
                    itemCount: userAvatars.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _showAvatarDialog(userAvatars[index]),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Responsive.radius(12)),
                            border: Border.all(
                              color: appcolor.withOpacity(0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Responsive.radius(11)),
                            child: Image.network(
                              userAvatars[index],
                              fit: BoxFit.cover, // Changed to cover for complete height
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: LoadingAnimationWidget.fourRotatingDots(
                                      color: appcolor,
                                      size: Responsive.height(20),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                      size: Responsive.height(30),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              // Empty State for Avatars
              if (!isAvatarsLoading && errorMessage == null && userAvatars.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.width(20),
                    vertical: Responsive.height(60),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: Responsive.height(48),
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: Responsive.height(16)),
                      Text(
                        "No Avatars Found",
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade600,
                          fontSize: Responsive.fontSize(16),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: Responsive.height(8)),
                      Text(
                        "This user hasn't created any avatars yet",
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade500,
                          fontSize: Responsive.fontSize(14),
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              SizedBox(height: Responsive.height(30)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count.toString(),
          style: GoogleFonts.poppins(
            fontSize: Responsive.fontSize(24),
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(height: Responsive.height(4)),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: Responsive.fontSize(12),
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.height(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: appcolor,
            size: Responsive.height(20),
          ),
          SizedBox(width: Responsive.width(12)),
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: Responsive.fontSize(14),
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: Responsive.fontSize(14),
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
