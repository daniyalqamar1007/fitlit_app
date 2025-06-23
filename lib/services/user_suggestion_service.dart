import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/user_suggestion_model.dart';
import '../view/Utils/globle_variable/globle.dart';

class UserSuggestionService {
  static const String endpoint = '/user/all';
  static const String followEndpoint = '/user/follow-action';

  static Future<UserSuggestionResponse> fetchUsers({
    required String token,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final Uri uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final rawUsers = List<Map<String, dynamic>>.from(jsonData['data'] ?? []);

        // Transform API data to match your model
        final users = rawUsers.map((user) => UserSuggestionModel(
          userId: user['id'],
          name: user['name'],
          email: user['email'],
          phoneNumber: user['phoneNumber'],
          profilePhoto: user['profilePicture'],
          gender: user['gender'],
          isFollowing: user['isFollowing'] ?? false,
          followers: user['followers'] ?? 0,
          following: user['following'] ?? 0,
          avatars: List<String>.from(user['avatars'] ?? []),
        )).toList();

        // FIXED: Better pagination detection
        // If we got fewer users than requested, we've reached the end
        bool hasMore = users.length == limit;

        // Alternative: If your API provides total count, use this instead:
        // int totalCount = jsonData['totalCount'] ?? 0;
        // int totalPages = (totalCount / limit).ceil();
        // bool hasMore = page < totalPages;

        return UserSuggestionResponse(
          success: true,
          users: users,
          hasMore: hasMore,
          currentPage: page,
          // totalCount: totalCount, // if available from API
        );
      } else {
        return UserSuggestionResponse.error(
            'Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      return UserSuggestionResponse.error('Network error: ${e.toString()}');
    }
  }

  static Future<bool> toggleFollowUser({
    required String token,
    required int userId,
    required bool isCurrentlyFollowing, // Add this parameter
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$followEndpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': userId,
          'action': isCurrentlyFollowing ? 'unfollow' : 'follow', // Determine action
        }),
      );
      print(response.body);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Follow error: $e');
      return false;
    }
  }
}