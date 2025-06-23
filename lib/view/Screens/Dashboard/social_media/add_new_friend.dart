// add_friends_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../controllers/user_suggestion_controller.dart';
import '../../../../controllers/profile_controller.dart';
import '../../../../model/user_suggestion_model.dart';
import '../../../Utils/Colors.dart';
import '../../../Utils/globle_variable/globle.dart';
import '../../../Utils/responsivness.dart';
import 'friend_user_profike.dart';

class AddFriendsPage extends StatefulWidget {
  final String? currentUserEmail;

  const AddFriendsPage({
    Key? key,
    this.currentUserEmail,
  }) : super(key: key);

  @override
  State<AddFriendsPage> createState() => _AddFriendsPageState();
}

class _AddFriendsPageState extends State<AddFriendsPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late UserSuggestionController _controller;
  final ProfileController _profileController = ProfileController();

  @override
  void initState() {
    super.initState();
    _controller = UserSuggestionController();
    _controller.setCurrentUserEmail(widget.currentUserEmail);
    _loadUsers();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _controller.dispose();
    _profileController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // FIXED: Better scroll detection with threshold
    const threshold = 200.0; // Load more when 200px from bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - threshold) {
      if (_controller.hasMoreNotifier.value &&
          _controller.statusNotifier.value != UserSuggestionStatus.loadingMore) {
        _loadMoreUsers();
      }
    }
  }

  void _onSearchChanged() {
    // This will trigger rebuild for search functionality
    setState(() {});
  }

  Future<void> _loadUsers() async {
    await _controller.loadUsers(
      token: token!,
      currentUserEmail: widget.currentUserEmail,
    );
  }

  Future<void> _loadMoreUsers() async {
    await _controller.loadMoreUsers(token: token!);
  }

  // FIXED: Use the new refresh method instead of loadUsers for RefreshIndicator
  Future<void> _refreshUsers() async {
    await _controller.refreshUsers(token: token!);
  }

  // FIXED: Enhanced follow/unfollow method with proper state management
  Future<void> _toggleFollowUser(UserSuggestionModel user) async {
    if (user.userId == null) return;

    try {
      final success = await _controller.toggleFollowUser(
        token: token!,
        userId: user.userId!,
      );

      if (success && mounted) {
        // No need to call setState() here since ValueListenableBuilder will handle updates
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              user.isFollowing ? 'Unfollowed successfully' : 'Followed successfully',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            duration: Duration(seconds: 1),
            backgroundColor: appcolor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to ${user.isFollowing ? 'unfollow' : 'follow'} user',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  void _navigateToUserProfile(UserSuggestionModel user) async {
    // Navigate to profile and wait for result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfilePage(
          user: user,
          onFollowToggle: (updatedUser) {
            // Update the user in the list when follow status changes
            _updateUserInList(updatedUser);
          },
        ),
      ),
    );

    // If the profile page returned an updated user, update the list
    if (result != null && result is UserSuggestionModel) {
      _updateUserInList(result);
    }
  }

  // FIXED: Method to update user in the list when follow status changes
  void _updateUserInList(UserSuggestionModel updatedUser) {
    final currentUsers = _controller.usersNotifier.value;
    final userIndex = currentUsers.indexWhere((u) => u.userId == updatedUser.userId);

    if (userIndex != -1) {
      currentUsers[userIndex] = updatedUser;
      // Trigger rebuild
      setState(() {});
    }
  }

  // Helper method to filter users based on search query and exclude current user
  List<UserSuggestionModel> _getFilteredUsers(List<UserSuggestionModel> users) {
    // Get current user email from profile controller
    final currentEmail = _profileController.profileNotifier.value?.email;

    // First filter out the current user
    final filteredUsers = users.where((user) {
      return user.email != null && user.email != currentEmail;
    }).toList();

    // Then apply search filter if there's a search query
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      return filteredUsers;
    } else {
      return filteredUsers.where((user) {
        final name = user.name?.toLowerCase() ?? '';
        final email = user.email?.toLowerCase() ?? '';
        return name.contains(query) || email.contains(query);
      }).toList();
    }
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Friends',
          style: GoogleFonts.poppins(
            color: appcolor,
            fontSize: Responsive.fontSize(20),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: EdgeInsets.all(Responsive.width(16)),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(Responsive.radius(15)),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: AnimatedBuilder(
              animation: _searchController,
              builder: (context, child) {
                return TextField(
                  controller: _searchController,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.fontSize(14),
                    color: Colors.black87,
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    // Handle search submit if needed
                    FocusScope.of(context).unfocus();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by name or email...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: Responsive.fontSize(14),
                      color: Colors.grey[500],
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: appcolor,
                      size: Responsive.height(20),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        FocusScope.of(context).unfocus();
                      },
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey[500],
                        size: Responsive.height(18),
                      ),
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: Responsive.width(16),
                      vertical: Responsive.height(12),
                    ),
                  ),
                );
              },
            ),
          ),

          // Results Count
          ValueListenableBuilder<UserSuggestionStatus>(
            valueListenable: _controller.statusNotifier,
            builder: (context, status, child) {
              if (status == UserSuggestionStatus.loaded) {
                return AnimatedBuilder(
                  animation: _searchController,
                  builder: (context, child) {
                    return ValueListenableBuilder<List<UserSuggestionModel>>(
                      valueListenable: _controller.usersNotifier,
                      builder: (context, users, child) {
                        final filteredUsers = _getFilteredUsers(users);
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: Responsive.width(16)),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${filteredUsers.length} users found',
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.fontSize(12),
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }
              return SizedBox.shrink();
            },
          ),

          SizedBox(height: Responsive.height(10)),

          // Users List
          Expanded(
            child: _buildUsersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return ValueListenableBuilder<UserSuggestionStatus>(
      valueListenable: _controller.statusNotifier,
      builder: (context, status, child) {
        if (status == UserSuggestionStatus.loading) {
          return Center(
            child: LoadingAnimationWidget.fourRotatingDots(
              color: appcolor,
              size: Responsive.height(20),
            ),
          );
        }

        if (status == UserSuggestionStatus.error) {
          return ValueListenableBuilder<String?>(
            valueListenable: _controller.errorNotifier,
            builder: (context, errorMessage, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: Responsive.height(50),
                    ),
                    SizedBox(height: Responsive.height(16)),
                    Text(
                      errorMessage ?? 'Something went wrong',
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.fontSize(14),
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Responsive.height(16)),
                    ElevatedButton(
                      onPressed: _loadUsers,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appcolor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'Retry',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.fontSize(14),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }

        return ValueListenableBuilder<List<UserSuggestionModel>>(
          valueListenable: _controller.usersNotifier,
          builder: (context, users, child) {
            return AnimatedBuilder(
              animation: _searchController,
              builder: (context, child) {
                // Filter users based on search query
                final filteredUsers = _getFilteredUsers(users);

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          color: Colors.grey[400],
                          size: Responsive.height(60),
                        ),
                        SizedBox(height: Responsive.height(16)),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'No users found matching your search'
                              : 'No users available',
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.fontSize(16),
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_searchController.text.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: Responsive.height(8)),
                            child: Text(
                              'Try searching with different keywords',
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.fontSize(12),
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }

                return ValueListenableBuilder<bool>(
                  valueListenable: _controller.hasMoreNotifier,
                  builder: (context, hasMore, child) {
                    return RefreshIndicator(
                      // FIXED: Use the new refresh method
                      onRefresh: _refreshUsers,
                      color: appcolor,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(horizontal: Responsive.width(16)),
                        itemCount: filteredUsers.length + (hasMore && _searchController.text.isEmpty ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == filteredUsers.length) {
                            // Loading more indicator (only show if not searching)
                            return ValueListenableBuilder<UserSuggestionStatus>(
                              valueListenable: _controller.statusNotifier,
                              builder: (context, loadingStatus, child) {
                                if (loadingStatus == UserSuggestionStatus.loadingMore) {
                                  return Container(
                                    padding: EdgeInsets.all(Responsive.height(16)),
                                    alignment: Alignment.center,
                                    child: LoadingAnimationWidget.fourRotatingDots(
                                      color: appcolor,
                                      size: Responsive.height(20),
                                    ),
                                  );
                                }
                                return SizedBox.shrink();
                              },
                            );
                          }

                          final user = filteredUsers[index];
                          return _buildUserTile(user);
                        },
                      ),
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

  Widget _buildUserTile(UserSuggestionModel user) {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: _controller.followLoadingNotifier,
      builder: (context, followLoadingSet, child) {
        final isLoading = followLoadingSet.contains(user.userId);

        return Container(
          margin: EdgeInsets.only(bottom: Responsive.height(12)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Responsive.radius(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey[100]!, width: 1),
          ),
          child: InkWell(
            onTap: () => _navigateToUserProfile(user),
            borderRadius: BorderRadius.circular(Responsive.radius(16)),
            child: Padding(
              padding: EdgeInsets.all(Responsive.width(16)),
              child: Row(
                children: [
                  // Profile Picture
                  Container(
                    width: Responsive.width(55),
                    height: Responsive.width(55),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: appcolor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: user.profilePhoto?.isNotEmpty == true
                          ? CachedNetworkImage(
                        imageUrl: user.profilePhoto!,
                        fit: BoxFit.cover,
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
                            color: appcolor,
                            size: Responsive.height(30),
                          ),
                        ),
                      )
                          : Container(
                        color: appcolor.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          color: appcolor,
                          size: Responsive.height(30),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: Responsive.width(16)),

                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name ?? 'Unknown User',
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.fontSize(16),
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: Responsive.height(4)),
                        SizedBox(height: Responsive.height(6)),
                        Row(
                          children: [
                            _buildSmallStat('${user.followers}', 'followers'),
                            SizedBox(width: Responsive.width(12)),
                            _buildSmallStat('${user.following}', 'following'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // FIXED: Enhanced Follow Button with immediate state update
                  Container(
                    width: Responsive.width(80),
                    height: Responsive.height(36),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _toggleFollowUser(user),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: user.isFollowing ? Colors.grey[300] : appcolor,
                        foregroundColor: user.isFollowing ? Colors.black87 : Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Responsive.radius(10)),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: isLoading
                          ? SizedBox(
                        width: Responsive.width(16),
                        height: Responsive.height(16),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            user.isFollowing ? Colors.black54 : Colors.white,
                          ),
                        ),
                      )
                          : Text(
                        user.isFollowing ? 'Unfollow' : 'Follow',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.fontSize(11),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSmallStat(String count, String label) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: count,
            style: GoogleFonts.poppins(
              fontSize: Responsive.fontSize(11),
              fontWeight: FontWeight.w600,
              color: appcolor,
            ),
          ),
          TextSpan(
            text: ' $label',
            style: GoogleFonts.poppins(
              fontSize: Responsive.fontSize(10),
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}