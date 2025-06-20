class UserSuggestionModel {
  final int? userId;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? profilePhoto;
  final String? gender;
  final bool isFollowing;
  final int followers;
  final int following;
  final List<String> avatars; // Added avatars list

  UserSuggestionModel({
    this.userId,
    this.name,
    this.email,
    this.phoneNumber,
    this.profilePhoto,
    this.gender,
    this.isFollowing = false,
    this.followers = 0,
    this.following = 0,
    this.avatars = const [], // Default empty list
  });

  factory UserSuggestionModel.fromJson(Map<String, dynamic> json) {
    return UserSuggestionModel(
      userId: json['id'] ?? json['userId'], // Handle both 'id' and 'userId'
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profilePhoto: json['profilePicture'],
      gender: json['gender'],
      isFollowing: json['isFollowing'] ?? false,
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      avatars: (json['avatars'] as List<dynamic>?)
          ?.map((avatar) => avatar.toString())
          .toList() ?? [], // Parse avatars array
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePhoto,
      'gender': gender,
      'isFollowing': isFollowing,
      'followers': followers,
      'following': following,
      'avatars': avatars,
    };
  }

  UserSuggestionModel copyWith({
    int? userId,
    String? name,
    String? email,
    String? phoneNumber,
    String? profilePhoto,
    String? gender,
    bool? isFollowing,
    int? followers,
    int? following,
    List<String>? avatars,
  }) {
    return UserSuggestionModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      gender: gender ?? this.gender,
      isFollowing: isFollowing ?? this.isFollowing,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      avatars: avatars ?? this.avatars,
    );
  }
}

class UserSuggestionResponse {
  final List<UserSuggestionModel> users;
  final bool hasMore;
  final int currentPage;
  final int totalPages;
  final String? message;
  final bool success;

  UserSuggestionResponse({
    required this.users,
    this.hasMore = false,
    this.currentPage = 1,
    this.totalPages = 1,
    this.message,
    this.success = true,
  });

  factory UserSuggestionResponse.fromJson(Map<String, dynamic> json) {
    return UserSuggestionResponse(
      users: (json['users'] as List?)
          ?.map((user) => UserSuggestionModel.fromJson(user))
          .toList() ?? [],
      hasMore: json['hasMore'] ?? false,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      message: json['message'],
      success: json['success'] ?? true,
    );
  }

  factory UserSuggestionResponse.error(String errorMessage) {
    return UserSuggestionResponse(
      users: [],
      hasMore: false,
      message: errorMessage,
      success: false,
    );
  }
}