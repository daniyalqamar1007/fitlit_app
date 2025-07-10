import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../model/user_suggestion_model.dart';
import 'package:fitlip_app/view/Utils/Colors.dart';
import '../Screens/Dashboard/social_media/friend_user_profike.dart';
import '../Utils/responsivness.dart';

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

  // Responsive helper methods
  bool isTablet(BuildContext context) {
    final data = MediaQuery.of(context);
    return data.size.shortestSide >= 600;
  }

  bool isLargeTablet(BuildContext context) {
    final data = MediaQuery.of(context);
    return data.size.shortestSide >= 900;
  }

  double getResponsiveWidth(BuildContext context, double mobileWidth) {
    if (isLargeTablet(context)) {
      return mobileWidth * 1.8;
    } else if (isTablet(context)) {
      return mobileWidth * 1.4;
    }
    return mobileWidth;
  }

  double getResponsiveHeight(BuildContext context, double mobileHeight) {
    if (isLargeTablet(context)) {
      return mobileHeight * 1.6;
    } else if (isTablet(context)) {
      return mobileHeight * 1.3;
    }
    return mobileHeight;
  }

  double getResponsiveFontSize(BuildContext context, double mobileFontSize) {
    if (isLargeTablet(context)) {
      return mobileFontSize * 1.5;
    } else if (isTablet(context)) {
      return mobileFontSize * 1.2;
    }
    return mobileFontSize;
  }

  double getResponsivePadding(BuildContext context, double mobilePadding) {
    if (isLargeTablet(context)) {
      return mobilePadding * 1.8;
    } else if (isTablet(context)) {
      return mobilePadding * 1.4;
    }
    return mobilePadding;
  }

  double getResponsiveRadius(BuildContext context, double mobileRadius) {
    if (isLargeTablet(context)) {
      return mobileRadius * 1.6;
    } else if (isTablet(context)) {
      return mobileRadius * 1.3;
    }
    return mobileRadius;
  }

  EdgeInsets getResponsiveAllPadding(BuildContext context, double mobilePadding) {
    return EdgeInsets.all(getResponsivePadding(context, mobilePadding));
  }

  EdgeInsets getResponsiveSymmetricPadding(BuildContext context, double horizontal, double vertical) {
    return EdgeInsets.symmetric(
      horizontal: getResponsivePadding(context, horizontal),
      vertical: getResponsivePadding(context, vertical),
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserProfilePage(
          user: user,
          onFollowToggle: (updatedUser) {
            // Handle the updated user data
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
        borderRadius: BorderRadius.circular(getResponsiveRadius(context, 12)),
      ),
      child: Container(
        width: getResponsiveWidth(context, 150),
        height: getResponsiveHeight(context, 220), // Increased height to prevent overflow
        margin: getResponsiveSymmetricPadding(context, 10, 5),
        padding: EdgeInsets.symmetric(
          horizontal: getResponsivePadding(context, 8),
          vertical: getResponsivePadding(context, 12), // Increased vertical padding
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Profile Photo - Now clickable
            GestureDetector(
              onTap: () => _navigateToProfile(context),
              child: Container(
                width: getResponsiveWidth(context, 80), // Slightly reduced size
                height: getResponsiveWidth(context, 80), // Slightly reduced size
                margin: EdgeInsets.only(top: getResponsiveHeight(context, 4)), // Reduced top margin
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appcolor,
                    width: isTablet(context) ? 3 : 2,
                  ),
                ),
                child: ClipOval(
                  child: user.profilePhoto?.isNotEmpty == true
                      ? CachedNetworkImage(
                          imageUrl: user.profilePhoto!,
                          fit: BoxFit.contain, // Changed from contain to cover for better image display
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: LoadingAnimationWidget.fourRotatingDots(
                              color: appcolor,
                              size: getResponsiveHeight(context, 16), // Reduced size
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: getResponsiveHeight(context, 32), // Reduced size
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: getResponsiveHeight(context, 32), // Reduced size
                          ),
                        ),
                ),
              ),
            ),
            
            // Spacer to push content apart
            SizedBox(height: getResponsiveHeight(context, 8)),
            
            // User Name - Also clickable
            Flexible(
              child: GestureDetector(
                onTap: () => _navigateToProfile(context),
                child: Text(
                  user.name ?? 'Unknown',
                  style: GoogleFonts.poppins(
                    fontSize: getResponsiveFontSize(context, 14), // Slightly reduced font size
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2, // Allow 2 lines for longer names
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            
            // Spacer
            SizedBox(height: getResponsiveHeight(context, 8)),
            
            // Follow Button
            Container(
              width: double.infinity,
              height: getResponsiveHeight(context, 32), // Slightly reduced height
              child: ElevatedButton(
                onPressed: isFollowLoading ? null : onFollowTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: user.isFollowing ? Colors.grey[300] : appcolor,
                  foregroundColor: user.isFollowing ? Colors.black87 : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(getResponsiveRadius(context, 8)),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: getResponsivePadding(context, 8),
                    vertical: getResponsivePadding(context, 4),
                  ),
                ),
                child: isFollowLoading
                    ? SizedBox(
                        width: getResponsiveWidth(context, 16), // Reduced size
                        height: getResponsiveHeight(context, 16), // Reduced size
                        child: CircularProgressIndicator(
                          strokeWidth: isTablet(context) ? 2.5 : 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            user.isFollowing ? Colors.black54 : Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        user.isFollowing ? 'Following' : 'Follow',
                        style: GoogleFonts.poppins(
                          fontSize: getResponsiveFontSize(context, 12), // Slightly reduced font size
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