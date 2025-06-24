// user_profile_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
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
        SnackBar(content: Text('Failed to ${currentUser.isFollowing
            ? 'unfollow'
            : 'follow'} user')),
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Section
            Container(
              padding: EdgeInsets.all(Responsive.width(20)),
              child: Column(
                children: [
                  // Profile Picture
           Row(children: [
             Container(
               width: Responsive.width(70),
               height: Responsive.width(70),
               decoration: BoxDecoration(
                 shape: BoxShape.circle,
                 border: Border.all(
                   color: appcolor,
                   width: 2,
                 ),
               ),
               child: ClipOval(
                 child: currentUser.profilePhoto?.isNotEmpty == true
                     ? CachedNetworkImage(
                   imageUrl: currentUser.profilePhoto!,
                   fit: BoxFit.contain,
                   placeholder: (context, url) => Container(
                     color: Colors.grey[200],
                     child: LoadingAnimationWidget.fourRotatingDots(
                       color: appcolor,
                       size: Responsive.height(30),
                     ),
                   ),
                   errorWidget: (context, url, error) => Container(
                     color: Colors.grey[200],
                     child: Icon(
                       Icons.person,
                       color: Colors.grey,
                       size: Responsive.height(60),
                     ),
                   ),
                 )
                     : Container(
                   color: Colors.grey[200],
                   child: Icon(
                     Icons.person,
                     color: Colors.grey,
                     size: Responsive.height(60),
                   ),
                 ),
               ),
             ),

             SizedBox(width: Responsive.width(24)),


             // Stats Row (Following, Followers, Avatars)
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children: [
                 _buildStatItem('Following', currentUser.following),
                 SizedBox(width: Responsive.width(20)),
                 _buildStatItem('Followers', currentUser.followers),
                 SizedBox(width: Responsive.width(20)),
                 _buildStatItem('Avatars', currentUser.avatars.length),
               ],
             ),
           ],),

                  SizedBox(height: Responsive.height(30)),

                  // Action Buttons Row (Follow/Unfollow and Message)
                  Row(
                    children: [
                      // Follow/Unfollow Button
                      Expanded(
                        child: Container(
                          height: Responsive.height(40),
                          child: ElevatedButton(
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
                                    Responsive.radius(12)),
                              ),
                            ),
                            child: isFollowLoading
                                ? SizedBox(
                              width: Responsive.width(20),
                              height: Responsive.height(20),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  currentUser.isFollowing
                                      ? Colors.black54
                                      : Colors.white,
                                ),
                              ),
                            )
                                : Text(
                              currentUser.isFollowing
                                  ? 'UnFollow'
                                  : 'Follow',
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
                        child: Container(
                          height: Responsive.height(40),
                          child: OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                    Text('Message feature coming soon!')),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: appcolor,
                              side: BorderSide(color: appcolor, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    Responsive.radius(12)),
                              ),
                            ),
                            child: Text(
                              'Message',
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.fontSize(14),
                                fontWeight: FontWeight.w600,
                              ),
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
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Avatars',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.fontSize(18),
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  textAlign:TextAlign.left

                ),
              ),
            ),
            // Avatars Section
            if (currentUser.avatars.isNotEmpty)
              Container(

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    SizedBox(height: Responsive.height(12)),

                    // Avatar Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        // crossAxisSpacing: Responsive.width(12),
                        // mainAxisSpacing: Responsive.height(12),
                        childAspectRatio: 0.5,
                      ),
                      itemCount: currentUser.avatars.length,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 150,
                          width: 70,
                          decoration: BoxDecoration(
                            // borderRadius: BorderRadius.circular(Responsive.radius(12)),
                            border: Border.all(
                              color: appcolor,
                              width: 0.3,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Responsive.radius(11)),
                            child: CachedNetworkImage(
                              imageUrl: currentUser.avatars[index],
                              fit: BoxFit.contain,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: LoadingAnimationWidget.fourRotatingDots(
                                  color: appcolor,
                                  size: Responsive.height(20),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: Responsive.height(30),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: Responsive.height(30)),
                  ],
                ),
              ),
            if (currentUser.avatars.isEmpty)
              Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.3, // Adjust as needed
                ),
                alignment: Alignment.center,
                child: Text(
                  "No Avatar Saved yet",
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: Responsive.fontSize(15),
                  ),
                  textAlign: TextAlign.center,
                ),
              )


            // Additional Profile Info Section (Gender and Phone only)

          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: GoogleFonts.poppins(
            fontSize: Responsive.fontSize(20),
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(height: Responsive.height(4)),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: Responsive.fontSize(12),
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.height(12)),
      child: Row(
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