class OutfitResponse {
  final bool success;
  final String? message;
  final OutfitModel? data;
  final String? avatar_url;


  OutfitResponse({
    required this.success,
    this.message,
    this.data,
    this.avatar_url
  });

  factory OutfitResponse.fromJson(Map<String, dynamic> json) {
    return OutfitResponse(
      success: json['success'] ?? false,
      message: json['message'],
      avatar_url: json['avatar'],
      data: json['data'] != null ? OutfitModel.fromJson(json['data']) : null,
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