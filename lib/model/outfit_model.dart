// class OutfitResponse {
//   final bool success;
//   final String? message;
//   final OutfitModel? data;
//   final String? avatar_url;
//
//
//   OutfitResponse({
//     required this.success,
//     this.message,
//     this.data,
//     this.avatar_url
//   });
//
//   factory OutfitResponse.fromJson(Map<String, dynamic> json) {
//     return OutfitResponse(
//       success: json['success'] ?? false,
//       message: json['message'],
//       avatar_url: json['avatar'],
//       data: json['data'] != null ? OutfitModel.fromJson(json['data']) : null,
//     );
//   }
// }
//
// class OutfitModel {
//   final String? id;
//   final String? shirtId;
//   final String? pantId;
//   final String? shoeId;
//   final String? accessoryId;
//   final DateTime? date;
//
//   OutfitModel({
//     this.id,
//     this.shirtId,
//     this.pantId,
//     this.shoeId,
//     this.accessoryId,
//     this.date,
//   });
//
//   factory OutfitModel.fromJson(Map<String, dynamic> json) {
//     return OutfitModel(
//       id: json['id'],
//       shirtId: json['shirt_id'],
//       pantId: json['pant_id'],
//       shoeId: json['shoe_id'],
//       accessoryId: json['accessory_id'],
//       date: json['date'] != null ? DateTime.parse(json['date']) : null,
//     );
//   }
// }
//outfit_model.dart
class OutfitResponse {
  final bool success;
  final String? message;
  final OutfitModel? data;
  final String? avatar_url;
  final String? backgroundimage;
  final String? stackimage;

  OutfitResponse({
    required this.success,
    this.message,
    this.data,
    this.avatar_url,
    this.backgroundimage,
    this.stackimage
  });

  factory OutfitResponse.fromJson(Map<String, dynamic> json) {
    return OutfitResponse(
      success: json['success'] ?? false,
      message: json['message'],
      avatar_url: json['avatarUrl'],
      backgroundimage: json['backgroundimageurl'],
      data: json['data'] != null ? OutfitModel.fromJson(json['data']) : null,
      stackimage: json['stackimage']
    );
  }
}

class OutfitModel {
  final String? id;
  final String? shirtId;
  final String? pantId;
  final String? shoeId;
  final String? accessoryId;
  final DateTime? date;

  OutfitModel({
    this.id,
    this.shirtId,
    this.pantId,
    this.shoeId,
    this.accessoryId,
    this.date,
  });

  factory OutfitModel.fromJson(Map<String, dynamic> json) {
    return OutfitModel(
      id: json['id'],
      shirtId: json['shirt_id'],
      pantId: json['pant_id'],
      shoeId: json['shoe_id'],
      accessoryId: json['accessory_id'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }
}

// New model for avatar data
class AvatarData {
  final String date;
  final String avatarUrl;
  final String? storedMessage;
  final String backgroundimageurl;
  final String? stackimage;

  AvatarData({
    required this.date,
    required this.avatarUrl,
     this.storedMessage,
    required this.backgroundimageurl,
     this.stackimage
  });

  factory AvatarData.fromJson(Map<String, dynamic> json) {
    return AvatarData(
      date: json['date'],
      avatarUrl: json['avatarUrl'],
      storedMessage: json['stored_message'],
      backgroundimageurl: json['backgroundimageurl'],
      stackimage: json['stackimage']

    );
  }

  // Helper method to convert date string to DateTime
  DateTime get dateTime {
    final parts = date.split('/');
    return DateTime(
      int.parse(parts[2]), // year
      int.parse(parts[1]), // month
      int.parse(parts[0]), // day
    );
  }
}

class AvatarListResponse {
  final bool success;
  final List<AvatarData> data;

  AvatarListResponse({
    required this.success,
    required this.data,
  });

  factory AvatarListResponse.fromJson(Map<String, dynamic> json) {
    return AvatarListResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>)
          .map((item) => AvatarData.fromJson(item))
          .toList(),
    );
  }
}