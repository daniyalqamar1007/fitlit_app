import 'package:flutter/material.dart';

import '../../Utils/Colors.dart';
import '../../Widgets/Custom_buttons.dart';

class SocialMediaProfile extends StatefulWidget {
  const SocialMediaProfile({Key? key}) : super(key: key);

  @override
  _SocialMediaProfileState createState() => _SocialMediaProfileState();
}

class _SocialMediaProfileState extends State<SocialMediaProfile> {
  bool isLiked = false;
  int likeCount = 42;

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

  void _showCommentsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Social Media Page',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: appcolor,
                    ),
                  ),
                  // CustomButton(
                  //   text: '+ Add Friends',
                  //   onPressed: ()async {  },
                  // ),
                ],
              ),
            ),



            // Profile Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
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
                      const Text(
                        '  Johnny Cage',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Johnycage@gmail.com',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                ],
              ),
            ),

            // Post Content - Wrap with Expanded to prevent overflow
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Card(
                        color: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Positioned.fill(child:ClipRRect(
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(12),topRight: Radius.circular(12)),
                                    child: Opacity(
                                        opacity: 0.7,
                                        child: Image.asset('assets/Images/new.jpg',fit: BoxFit.cover,)))),
                                Container(
                                  margin: EdgeInsets.only(top: 15),
                                  child: ClipRRect(

                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: Image.asset(
                                      "assets/Icons/avatar.png",
                                       height: 350,
                                      scale: 99,
                                      width: double.infinity,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 16,
                                  left: 16,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFB8860B),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Column(
                                          children: [
                                            Text(
                                              '11',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'July',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Padding(
                                      //   padding: const EdgeInsets.all(8.0),
                                      //   child: Text(
                                      //     'x $likeCount',
                                      //     style: const TextStyle(
                                      //       color: Colors.white,
                                      //       fontSize: 14,
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
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
                      // const SizedBox(height: 24),
                      // SizedBox(
                      //   width: double.infinity,
                      //   child: ElevatedButton(
                      //     onPressed: () {},
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: appcolor,
                      //       padding: const EdgeInsets.symmetric(vertical: 16),
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(8),
                      //       ),
                      //     ),
                      //     child: const Text(
                      //       'Share to Facebook',
                      //       style: TextStyle(
                      //         fontSize: 16,
                      //         fontWeight: FontWeight.bold,
                      //         color: Colors.white,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.only(bottom: 16.0),
      //   child: ElevatedButton(
      //     onPressed: () {},
      //     style: ElevatedButton.styleFrom(
      //       backgroundColor: Colors.white,
      //       foregroundColor: appcolor,
      //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(8),
      //         side: BorderSide(color: appcolor, width: 2),
      //       ),
      //       elevation: 2,
      //     ),
      //     child: const Text(
      //       'Take Photos',
      //       style: TextStyle(fontWeight: FontWeight.bold),
      //     ),
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(text, style: TextStyle(color: color)),
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
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
              padding: const EdgeInsets.all(16),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return CommentTile(comment: comment);
              },
            ),
          ),

          // Comment Input
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //   decoration: const BoxDecoration(
          //     color: Colors.white,
          //     border: Border(
          //       top: BorderSide(color: Colors.grey, width: 0.5),
          //     ),
          //   ),
          //   child: Row(
          //     children: [
          //       ClipOval(
          //         child: Image.network(
          //             'assets/Images/circle_image.png',
          //           width: 32,
          //           height: 32,
          //         ),
          //       ),
          //       const SizedBox(width: 8),
          //       Expanded(
          //         child: TextField(
          //           decoration: InputDecoration(
          //             hintText: 'Write a comment...',
          //             border: OutlineInputBorder(
          //               borderRadius: BorderRadius.circular(20),
          //               borderSide: BorderSide.none,
          //             ),
          //             filled: true,
          //             fillColor: Colors.grey[200],
          //             contentPadding: const EdgeInsets.symmetric(
          //               horizontal: 16,
          //               vertical: 8,
          //             ),
          //           ),
          //         ),
          //       ),
          //       const SizedBox(width: 8),
          //       IconButton(
          //         icon: const Icon(Icons.send),
          //         color: const Color(0xFFB8860B),
          //         onPressed: () {},
          //       ),
          //     ],
          //   ),
          // ),
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
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: Image.asset(
              comment.avatar,
              width: 32,
              height: 32,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        comment.author,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        comment.time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(comment.content),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.thumb_up_outlined,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${comment.likes}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Reply',
                        style: TextStyle(
                          fontSize: 12,
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