import 'package:fitlip_app/view/Utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../controllers/outfit_controller.dart';
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
  int likeCount = 42;
  String? avatarUrl = "assets/Icons/avatar3.png";
  final OutfitController _outfitController = OutfitController();
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;
  final List<Comment> dummyComments = [
    Comment(
      id: 1,
      author: "Sarah Johnson",
      avatar: "assets/Images/circle_image.png",
      content: "This looks amazing! I love the colors.",
      likes: 12,
      time: "2h ago",
    ),
    Comment(
      id: 2,
      author: "Mike Peters",
      avatar: "assets/Images/circle_image.png",
      content: "Great work, keep it up buddy!",
      likes: 5,
      time: "3h ago",
    ),
    Comment(
      id: 3,
      author: "Emily Richards",
      avatar: "assets/Images/circle_image.png",
      content: "This is exactly what I was looking for. Mind sharing how you made this?",
      likes: 8,
      time: "5h ago",
    ),
    Comment(
      id: 4,
      author: "David Wong",
      avatar: "assets/Images/circle_image.png",
      content: "Inspiring work as always!",
      likes: 3,
      time: "7h ago",
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Set up listeners for avatar URL
    _outfitController.avatarUrlNotifier.addListener(_updateAvatarUrl);
    _outfitController.statusNotifier.addListener(_updateLoadingStatus);
  }

  @override
  void dispose() {
    _outfitController.avatarUrlNotifier.removeListener(_updateAvatarUrl);
    _outfitController.statusNotifier.removeListener(_updateLoadingStatus);
    _outfitController.dispose();
    super.dispose();
  }

  void _updateAvatarUrl() {
    if (_outfitController.avatarUrlNotifier.value != null) {
      setState(() {
        avatarUrl = _outfitController.avatarUrlNotifier.value;
      });
    }
  }

  void _updateLoadingStatus() {
    setState(() {
      isLoading = _outfitController.statusNotifier.value == OutfitStatus.loading;
    });
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

  // Function to fetch the avatar based on date
  Future<void> _fetchAvatarByDate(DateTime date) async {
    // Get user token - you might need to retrieve this from shared preferences or another state management solution
     // Replace with actual token retrieval

    try {
      final response = await _outfitController.getOutfitByDate(
        token: token!,
        date: date,
      );

      // If URL is returned and not null, update the state
      if (response != null) {
        setState(() {
          avatarUrl = response;
          selectedDate = date;
        });
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch avatar: ${e.toString()}')),
      );
    }
  }

  // Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    // Set lastDate to at least a year from now to avoid date errors
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
      // Call API with the selected date
      _fetchAvatarByDate(picked);
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
                    'Social Media Page',
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
            Padding(
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
                      child: Image.asset(
                        'assets/Images/circle_image.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '  Johnny Cage',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.fontSize(24),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Johnycage@gmail.com',
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
            ),

            // Post Content - Wrap with Expanded to prevent overflow
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
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(Responsive.radius(12)),
                                      topRight: Radius.circular(Responsive.radius(12)),
                                    ),
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
                                  child: isLoading
                                      ? Center(
                                    child: CircularProgressIndicator(
                                      color: appcolor,
                                    ),
                                  )
                                      : ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(Responsive.radius(12)),
                                    ),
                                    child: avatarUrl!.startsWith('http')
                                        ? Image.network(
                                      avatarUrl!,
                                      height: Responsive.height(300),
                                      width: double.infinity,
                                      fit: BoxFit.contain,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Image.asset(
                                          "assets/Icons/avatar3.png",
                                          height: Responsive.height(300),
                                          width: double.infinity,
                                          fit: BoxFit.contain,
                                        );
                                      },
                                    )
                                        : Image.asset(
                                      avatarUrl!,
                                      height: Responsive.height(300),
                                      width: double.infinity,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
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
                            const Divider(height: 1),
                            Row(
                              children: [
                                Expanded(
                                  child: ActionButton(
                                    icon: isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    text: 'Like',
                                    color: isLiked ? Colors.red : Colors.grey,
                                    onPressed: _handleLike,
                                  ),
                                ),
                                Expanded(
                                  child: ActionButton(
                                    icon: Icons.comment_outlined,
                                    text: 'Comment',
                                    onPressed: _showCommentsBottomSheet,
                                  ),
                                ),
                                Expanded(
                                  child: ActionButton(
                                    icon: Icons.share_outlined,
                                    text: 'Share',
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
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
                    fontSize: Responsive.fontSize(14)
                )
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
                  'Comments',
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
                        'Reply',
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