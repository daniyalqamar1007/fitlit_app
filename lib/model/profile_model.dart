class UserProfileModel {
  final String id;
  final String name;
  final String email;
  final String gender;
  final String profileImage;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.gender,
    required this.profileImage,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'] ?? '',
      profileImage: json['profilePicture'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'gender': gender,
      'profilePicture': profileImage,
    };
  }

  // Create a copy of this UserProfileModel with modified fields
  UserProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? gender,
    String? profileImage,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}