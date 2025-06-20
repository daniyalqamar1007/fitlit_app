import 'package:flutter/material.dart';
import '../model/user_suggestion_model.dart';
import '../services/user_suggestion_service.dart';

enum UserSuggestionStatus { initial, loading, loaded, loadingMore, error }

class UserSuggestionController {
  final ValueNotifier<UserSuggestionStatus> statusNotifier =
  ValueNotifier(UserSuggestionStatus.initial);
  final ValueNotifier<List<UserSuggestionModel>> usersNotifier =
  ValueNotifier([]);
  final ValueNotifier<String?> errorNotifier = ValueNotifier(null);
  final ValueNotifier<bool> hasMoreNotifier = ValueNotifier(true);
  final ValueNotifier<Set<int>> followLoadingNotifier = ValueNotifier({}); // Track loading states

  int _currentPage = 1;
  static const int _limit = 10;
  bool _isDisposed = false;
  String? _currentUserEmail; // Store current user's email

  // Method to set current user email
  void setCurrentUserEmail(String? email) {
    _currentUserEmail = email;
  }

  // Filter users to exclude current user
  List<UserSuggestionModel> _filterUsers(List<UserSuggestionModel> users) {
    if (_currentUserEmail == null) return users;

    return users.where((user) => user.email != _currentUserEmail).toList();
  }

  Future<void> loadUsers({required String token, String? currentUserEmail}) async {
    if (_isDisposed) return;

    // Set current user email if provided
    if (currentUserEmail != null) {
      _currentUserEmail = currentUserEmail;
    }

    _setStatus(UserSuggestionStatus.loading);
    _currentPage = 1;

    try {
      final response = await UserSuggestionService.fetchUsers(
        token: token,
        page: _currentPage,
        limit: _limit,
      );

      if (_isDisposed) return;

      if (response.success) {
        // Filter out current user before setting the value
        final filteredUsers = _filterUsers(response.users);
        usersNotifier.value = filteredUsers;
        hasMoreNotifier.value = response.hasMore;
        _setStatus(UserSuggestionStatus.loaded);
      } else {
        _setError(response.message ?? 'Failed to load users');
      }
    } catch (e) {
      _setError('Error loading users: $e');
    }
  }

  Future<void> loadMoreUsers({required String token}) async {
    if (_isDisposed || !hasMoreNotifier.value) return;

    _setStatus(UserSuggestionStatus.loadingMore);
    _currentPage++;

    try {
      final response = await UserSuggestionService.fetchUsers(
        token: token,
        page: _currentPage,
        limit: _limit,
      );

      if (_isDisposed) return;

      if (response.success) {
        final currentUsers = [...usersNotifier.value];
        // Filter new users before adding them
        final filteredNewUsers = _filterUsers(response.users);
        currentUsers.addAll(filteredNewUsers);
        usersNotifier.value = currentUsers;
        hasMoreNotifier.value = response.hasMore;
        _setStatus(UserSuggestionStatus.loaded);
      } else {
        _currentPage--;
        _setError(response.message ?? 'Failed to load more users');
      }
    } catch (e) {
      _currentPage--;
      _setError('Error loading more users: $e');
    }
  }

  Future<void> toggleFollowUser({
    required String token,
    required int userId,
  }) async {
    final userIndex = usersNotifier.value.indexWhere((u) => u.userId == userId);
    if (userIndex == -1) return;

    final user = usersNotifier.value[userIndex];
    final wasFollowing = user.isFollowing;

    // Add to loading set
    final currentLoading = {...followLoadingNotifier.value};
    currentLoading.add(userId);
    followLoadingNotifier.value = currentLoading;

    try {
      final success = await UserSuggestionService.toggleFollowUser(
        token: token,
        userId: userId,
        action: wasFollowing ? 'unfollow' : 'follow',
      );

      if (success && !_isDisposed) {
        // Update the user in the list
        final updatedUsers = [...usersNotifier.value];
        updatedUsers[userIndex] = user.copyWith(
          isFollowing: !wasFollowing,
          followers: wasFollowing ? user.followers - 1 : user.followers + 1,
        );
        usersNotifier.value = updatedUsers;
      }
    } catch (e) {
      print('Follow error: $e');
    } finally {
      // Remove from loading set
      if (!_isDisposed) {
        final currentLoading = {...followLoadingNotifier.value};
        currentLoading.remove(userId);
        followLoadingNotifier.value = currentLoading;
      }
    }
  }

  bool isFollowLoading(int userId) {
    return followLoadingNotifier.value.contains(userId);
  }

  // Helper methods
  void _setStatus(UserSuggestionStatus status) {
    if (!_isDisposed) statusNotifier.value = status;
  }

  void _setError(String error) {
    if (!_isDisposed) {
      errorNotifier.value = error;
      statusNotifier.value = UserSuggestionStatus.error;
    }
  }

  void dispose() {
    _isDisposed = true;
    statusNotifier.dispose();
    usersNotifier.dispose();
    errorNotifier.dispose();
    hasMoreNotifier.dispose();
    followLoadingNotifier.dispose();
  }
}