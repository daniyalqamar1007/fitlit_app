
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitlip_app/controllers/profile_controller.dart';
import 'package:fitlip_app/view/Utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../controllers/outfit_controller.dart';
import '../../../model/profile_model.dart';
import '../../Utils/Colors.dart';
import '../../Utils/globle_variable/globle.dart';
import '../../Utils/responsivness.dart';
import '../../Widgets/Custom_buttons.dart';

class SocialMediaProfile extends StatefulWidget {
  const SocialMediaProfile({Key? key}) : super(key: key);

  @override
  _SocialMediaProfileState createState() => _SocialMediaProfileState();
}

class _SocialMediaProfileState extends State<SocialMediaProfile> {
  bool isLiked = false;
  bool status = true;
  int likeCount = 42;
  final OutfitController _outfitController = OutfitController();
  final ProfileController _profileController = ProfileController();
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;
  String? outfitImageUrl; // To store the fetched outfit image URL
  final List<Comment> dummyComments = [
    Comment(
      id: 1,
      author: "Sarah Johnson",
      avatar: "assets/Images/circle_image.png",
      content: "Love this outfit! Where did you get that jacket?",
      likes: 12,
      time: "2h ago",
    ),
    Comment(
      id: 2,
      author: "Mike Chen",
      avatar: "assets/Images/circle_image.png",
      content: "Perfect color combination! 👌",
      likes: 8,
      time: "4h ago",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _outfitController.statusNotifier.addListener(_updateLoadingStatus);
    _fetchOutfitForSelectedDate(); // Initial fetch
  }

  @override
  void dispose() {
    _outfitController.statusNotifier.removeListener(_updateLoadingStatus);
    _outfitController.dispose();
    super.dispose();
  }

  void _updateLoadingStatus() {
    setState(() {
      isLoading = _outfitController.statusNotifier.value == OutfitStatus.loading;
    });
  }

  Future<void> _fetchOutfitForSelectedDate() async {
    try {
      setState(() {
        isLoading = true;
        outfitImageUrl = null; // Clear previous image while loading
      });
      print(token);
      print(selectedDate);

      final response = await _outfitController.getOutfitByDate(
        token: token!,
        date: selectedDate,
      );

      setState(() {
        outfitImageUrl = response;
        isLoading = false;
      });

      if (response != null) {
        setState(() {
          status = true;
        });
      }

      if (response == null || response.isEmpty) {
        setState(() {
          status = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.noOutfitAvailable),
            backgroundColor: appcolor,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.errorFetchingOutfit}: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleLike() {
    setState(() {
      if (isLiked) {
        likeCount--;
      } else {
        likeCount++;
      }
      isLiked = !isLiked;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: appcolor,
            colorScheme: ColorScheme.light(primary: appcolor),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _fetchOutfitForSelectedDate(); // Fetch outfit for new date
    }
  }

  void _showCommentsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Responsive.radius(20))),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return CommentsBottomSheet(
            comments: dummyComments,
            scrollController: scrollController,
          );
        },
      ),
    );
  }

  Widget _buildNoOutfitAvailable() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: appcolor.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () => _selectDate(context),
            child: Text(
              AppLocalizations.of(context)!.noOutfitAvailable,
              style: GoogleFonts.poppins(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: Responsive.allPadding(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.socialMediaPage,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.fontSize(20),
                      fontWeight: FontWeight.w600,
                      color: appcolor,
                    ),
                  ),
                ],
              ),
            ),

            // Profile Info
            ValueListenableBuilder<UserProfileModel?>(
              valueListenable: _profileController.profileNotifier,
              builder: (context, userProfile, _) {
                return Padding(
                  padding: Responsive.allPadding(16),
                  child: Row(
                    children: [
                      Container(
                        width: Responsive.width(50),
                        height: Responsive.height(50),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFB8860B),
                            width: 1,
                          ),
                        ),
                        child: ClipOval(
                          child: userProfile?.profileImage.isNotEmpty == true
                              ? Padding(
                            padding: EdgeInsets.all(2),
                            child: CachedNetworkImage(
                              imageUrl: userProfile!.profileImage,
                              fit: BoxFit.cover,
                              scale: 2,
                              alignment: Alignment.topCenter,
                              placeholderFadeInDuration: Duration(milliseconds: 300),
                              placeholder: (context, url) => CircularProgressIndicator(),
                              errorWidget: (context, url, error) => Image.asset(
                                'assets/Images/circle_image.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                              : Image.asset(
                            'assets/Images/circle_image.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: Responsive.width(8)),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${userProfile?.name ?? AppLocalizations.of(context)!.loading}',
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.fontSize(24),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            userProfile?.email ?? '',
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: Responsive.fontSize(14),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.height(8)),
                    ],
                  ),
                );
              },
            ),

            // Post Content
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Padding(
                  padding: Responsive.horizontalPadding(12),
                  child: Column(
                    children: [
                      Card(
                        color: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Responsive.radius(12)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: status
                                        ? BorderRadius.only(
                                      topLeft: Radius.circular(Responsive.radius(12)),
                                      topRight: Radius.circular(Responsive.radius(12)),
                                    )
                                        : BorderRadius.circular(12),
                                    child: Opacity(
                                      opacity: 0.7,
                                      child: Image.asset(
                                        'assets/Images/new.jpg',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: Responsive.height(15)),
                                  height: Responsive.height(300),
                                  width: double.infinity,
                                  child: isLoading
                                      ? Center(
                                    child: CircularProgressIndicator(
                                      color: appcolor,
                                    ),
                                  )
                                      : outfitImageUrl != null && outfitImageUrl!.isNotEmpty
                                      ? ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(Responsive.radius(12)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CachedNetworkImage(
                                        imageUrl: outfitImageUrl!,
                                        scale: 4,
                                        width: double.infinity,
                                        fit: BoxFit.contain,
                                        placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(appcolor),
                                          ),
                                        ),
                                        errorWidget: (context, error, stackTrace) {
                                          return _buildNoOutfitAvailable();
                                        },
                                      ),
                                    ),
                                  )
                                      : _buildNoOutfitAvailable(),
                                ),
                                Positioned(
                                  top: Responsive.height(16),
                                  left: Responsive.width(16),
                                  child: GestureDetector(
                                    onTap: () => _selectDate(context),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: Responsive.height(4),
                                        horizontal: Responsive.width(12),
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFB8860B),
                                        borderRadius: BorderRadius.circular(Responsive.radius(8)),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            DateFormat('dd').format(selectedDate),
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: Responsive.fontSize(14),
                                            ),
                                          ),
                                          Text(
                                            DateFormat('MMM').format(selectedDate),
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: Responsive.fontSize(12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            status
                                ? Row(
                              children: [
                                Expanded(
                                  child: ActionButton(
                                    icon: isLiked ? Icons.favorite : Icons.favorite_border,
                                    text: AppLocalizations.of(context)!.like,
                                    color: isLiked ? Colors.red : Colors.grey,
                                    onPressed: _handleLike,
                                  ),
                                ),
                                Expanded(
                                  child: ActionButton(
                                    icon: Icons.comment_outlined,
                                    text: AppLocalizations.of(context)!.comment,
                                    onPressed: _showCommentsBottomSheet,
                                  ),
                                ),
                                Expanded(
                                  child: ActionButton(
                                    icon: Icons.share_outlined,
                                    text: AppLocalizations.of(context)!.share,
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            )
                                : SizedBox(),
                          ],
                        ),
                      ),
                      SizedBox(height: Responsive.height(80)),
                    ],
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

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const ActionButton({
    Key? key,
    required this.icon,
    required this.text,
    required this.onPressed,
    this.color = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Responsive.height(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: Responsive.fontSize(20)),
            SizedBox(width: Responsive.width(8)),
            Text(
              text,
              style: GoogleFonts.poppins(
                color: color,
                fontSize: Responsive.fontSize(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommentsBottomSheet extends StatelessWidget {
  final List<Comment> comments;
  final ScrollController scrollController;

  const CommentsBottomSheet({
    Key? key,
    required this.comments,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(Responsive.radius(20))),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: Responsive.allPadding(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.comments,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.fontSize(18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: Responsive.fontSize(24)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Comments List
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: Responsive.allPadding(16),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return CommentTile(comment: comment);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CommentTile extends StatelessWidget {
  final Comment comment;

  const CommentTile({
    Key? key,
    required this.comment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.height(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: Image.asset(
              comment.avatar,
              width: Responsive.width(32),
              height: Responsive.height(32),
            ),
          ),
          SizedBox(width: Responsive.width(8)),
          Expanded(
            child: Container(
              padding: Responsive.allPadding(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(Responsive.radius(12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        comment.author,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.fontSize(14),
                        ),
                      ),
                      Text(
                        comment.time,
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.fontSize(12),
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.height(4)),
                  Text(
                    comment.content,
                    style: GoogleFonts.poppins(fontSize: Responsive.fontSize(14)),
                  ),
                  SizedBox(height: Responsive.height(8)),
                  Row(
                    children: [
                      Icon(
                        Icons.thumb_up_outlined,
                        size: Responsive.fontSize(12),
                        color: Colors.grey,
                      ),
                      SizedBox(width: Responsive.width(4)),
                      Text(
                        '${comment.likes}',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.fontSize(12),
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: Responsive.width(16)),
                      Text(
                        AppLocalizations.of(context)!.reply,
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.fontSize(12),
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Comment {
  final int id;
  final String author;
  final String avatar;
  final String content;
  final int likes;
  final String time;

  const Comment({
    required this.id,
    required this.author,
    required this.avatar,
    required this.content,
    required this.likes,
    required this.time,
  });
}