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
  final ValueNotifier<Set<int>> followLoadingNotifier = ValueNotifier({});

  int _currentPage = 1;
  static const int _limit = 10;
  bool _isDisposed = false;
  String? _currentUserEmail;

  // Track loaded user IDs to prevent duplicates
  final Set<int> _loadedUserIds = {};

  void setCurrentUserEmail(String? email) {
    _currentUserEmail = email;
  }

  List<UserSuggestionModel> _filterUsers(List<UserSuggestionModel> users) {
    if (_currentUserEmail == null) return users;

    return users.where((user) =>
    user.email != _currentUserEmail &&
        user.userId != null).toList();
  }

  List<UserSuggestionModel> _removeDuplicates(List<UserSuggestionModel> users) {
    final uniqueUsers = <UserSuggestionModel>[];
    final seenIds = <int>{};

    for (final user in users) {
      if (user.userId != null && !seenIds.contains(user.userId)) {
        seenIds.add(user.userId!);
        uniqueUsers.add(user);
      }
    }

    return uniqueUsers;
  }

  Future<void> loadUsers({required String token, String? currentUserEmail}) async {
    if (_isDisposed) return;

    if (currentUserEmail != null) {
      _currentUserEmail = currentUserEmail;
    }

    _setStatus(UserSuggestionStatus.loading);
    _currentPage = 1;
    _loadedUserIds.clear();

    try {
      final response = await UserSuggestionService.fetchUsers(
        token: token,
        page: _currentPage,
        limit: _limit,
      );

      if (_isDisposed) return;

      if (response.success) {
        final filteredUsers = _filterUsers(response.users);

        for (final user in filteredUsers) {
          if (user.userId != null) {
            _loadedUserIds.add(user.userId!);
          }
        }

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
        final filteredNewUsers = _filterUsers(response.users);
        final newUniqueUsers = filteredNewUsers.where((user) =>
        user.userId != null && !_loadedUserIds.contains(user.userId!)).toList();

        for (final user in newUniqueUsers) {
          if (user.userId != null) {
            _loadedUserIds.add(user.userId!);
          }
        }

        final currentUsers = [...usersNotifier.value];
        currentUsers.addAll(newUniqueUsers);
        final uniqueUsers = _removeDuplicates(currentUsers);

        usersNotifier.value = uniqueUsers;
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

  Future<void> refreshUsers({required String token}) async {
    _currentPage = 1;
    _loadedUserIds.clear();
    await loadUsers(token: token, currentUserEmail: _currentUserEmail);
  }

  Future<bool> toggleFollowUser({
    required String token,
    required int userId,
  }) async {
    try {
      // Add user to loading set
      final currentLoadingSet = Set<int>.from(followLoadingNotifier.value);
      currentLoadingSet.add(userId);
      followLoadingNotifier.value = currentLoadingSet;

      // Find the user in the current list
      final users = usersNotifier.value;
      final userIndex = users.indexWhere((u) => u.userId == userId);
      if (userIndex == -1) return false;

      final currentUser = users[userIndex];

      // Make API call
      final success = await UserSuggestionService.toggleFollowUser(
        token: token,
        userId: userId,
        isCurrentlyFollowing: currentUser.isFollowing,
      );

      if (success) {
        // Update the user in the list
        final updatedUser = currentUser.copyWith(
          isFollowing: !currentUser.isFollowing,
          followers: currentUser.isFollowing
              ? currentUser.followers - 1
              : currentUser.followers + 1,
        );

        final updatedUsers = List<UserSuggestionModel>.from(users);
        updatedUsers[userIndex] = updatedUser;
        usersNotifier.value = updatedUsers;
      }

      return success;
    } catch (e) {
      print('Error toggling follow status: $e');
      return false;
    } finally {
      // Remove from loading set in any case
      final updatedLoadingSet = Set<int>.from(followLoadingNotifier.value);
      updatedLoadingSet.remove(userId);
      _updateUserFollowStatus(userId);
      followLoadingNotifier.value = updatedLoadingSet;
    }
  }
  void _updateUserFollowStatus(int userId) {
    final currentUsers = List<UserSuggestionModel>.from(usersNotifier.value);
    final userIndex = currentUsers.indexWhere((user) => user.userId == userId);

    if (userIndex != -1) {
      final user = currentUsers[userIndex];
      final updatedUser = user.copyWith(
        isFollowing: !user.isFollowing,
        followers: user.isFollowing ? user.followers - 1 : user.followers + 1,
      );
      currentUsers[userIndex] = updatedUser;
      usersNotifier.value = currentUsers;
    }
  }

  UserSuggestionModel? getUserById(int userId) {
    try {
      return usersNotifier.value.firstWhere((user) => user.userId == userId);
    } catch (e) {
      return null;
    }
  }

  void updateUser(UserSuggestionModel updatedUser) {
    final currentUsers = List<UserSuggestionModel>.from(usersNotifier.value);
    final userIndex = currentUsers.indexWhere((user) => user.userId == updatedUser.userId);

    if (userIndex != -1) {
      currentUsers[userIndex] = updatedUser;
      usersNotifier.value = currentUsers;
    }
  }

  bool isFollowLoading(int userId) {
    return followLoadingNotifier.value.contains(userId);
  }

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
    _loadedUserIds.clear();
    statusNotifier.dispose();
    usersNotifier.dispose();
    errorNotifier.dispose();
    hasMoreNotifier.dispose();
    followLoadingNotifier.dispose();
  }
}