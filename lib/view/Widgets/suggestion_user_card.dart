import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../model/user_suggestion_model.dart';
import 'package:fitlip_app/view/Utils/Colors.dart';

import '../Screens/Dashboard/social_media/friend_user_profike.dart';
import '../Utils/responsivness.dart'; // assuming this is your responsive util

class UserSuggestionCard extends StatelessWidget {
  final UserSuggestionModel user;
  final VoidCallback onFollowTap;
  final bool isFollowLoading;


  const UserSuggestionCard({
    Key? key,
    required this.user,
    required this.onFollowTap,

    this.isFollowLoading = false,
  }) : super(key: key);

  void _navigateToProfile(BuildContext context) {
    // print(user);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserProfilePage(
          user: user,

          onFollowToggle: (updatedUser) {
            // Handle the updated user data
            // You can update your main list here
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Responsive.radius(12)),
      ),
      child: Container(
        width: Responsive.width(150),
        height: Responsive.height(200),
        margin: EdgeInsets.symmetric(
          horizontal: Responsive.width(10),
          vertical: Responsive.height(5),
        ),
        padding: EdgeInsets.all(Responsive.width(8)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Profile Photo - Now clickable
            GestureDetector(
              onTap: () => _navigateToProfile(context),
              child: Container(
                width: Responsive.width(90),
                height: Responsive.width(90),
                margin: EdgeInsets.only(top: Responsive.height(10)),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appcolor,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: user.profilePhoto?.isNotEmpty == true
                      ? CachedNetworkImage(
                    imageUrl: user.profilePhoto!,
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
                        Icons.person,
                        color: Colors.grey,
                        size: Responsive.height(40),
                      ),
                    ),
                  )
                      : Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.person,
                      color: Colors.grey,
                      size: Responsive.height(40),
                    ),
                  ),
                ),
              ),
            ),

            // User Name - Also clickable
            GestureDetector(
              onTap: () => _navigateToProfile(context),
              child: Text(
                user.name ?? 'Unknown',
                style: GoogleFonts.poppins(
                  fontSize: Responsive.fontSize(15),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Follow Button
            Container(
              margin: EdgeInsets.only(bottom: Responsive.height(10)),
              width: double.infinity,
              height: Responsive.height(36),
              child: ElevatedButton(
                onPressed: isFollowLoading ? null : onFollowTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: user.isFollowing ? Colors.grey[300] : appcolor,
                  foregroundColor: user.isFollowing ? Colors.black87 : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Responsive.radius(8)),
                  ),
                ),
                child: isFollowLoading
                    ? SizedBox(
                  width: Responsive.width(20),
                  height: Responsive.height(20),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      user.isFollowing ? Colors.black54 : Colors.white,
                    ),
                  ),
                )
                    : Text(
                  user.isFollowing ? 'Following' : 'Follow',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.fontSize(13),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
