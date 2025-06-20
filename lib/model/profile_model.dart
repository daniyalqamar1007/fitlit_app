class UserProfileModel {
  final int id;
  final String name;
  final String email;
  final String gender;
  final String profileImage;
  final int following;
  final int followers;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.gender,
    required this.profileImage,
    required this.following,
    required this.followers,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['userId'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'] ?? '',
      profileImage: json['profilePicture'] ?? '',
      following: json['following'] ?? 0,
      followers: json['followers'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': id,
      'name': name,
      'email': email,
      'gender': gender,
      'profilePicture': profileImage,
      'following': following,
      'followers': followers,
    };
  }

  // Create a copy of this UserProfileModel with modified fields
  UserProfileModel copyWith({
    int? id,
    String? name,
    String? email,
    String? gender,
    String? profileImage,
    int? following,
    int? followers,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      profileImage: profileImage ?? this.profileImage,
      following: following ?? this.following,
      followers: followers ?? this.followers,
    );
  }
}