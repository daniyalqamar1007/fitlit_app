// lib/models/wardrobe_item_model.dart

class WardrobeItem {
  final String? id;
  final String? userId;
  final String category;
  final String subCategory;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WardrobeItem({
    this.id,
    this.userId,
    required this.category,
    required this.subCategory,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory WardrobeItem.fromJson(Map<String, dynamic> json) {
    return WardrobeItem(
      id: json['_id'],
      userId: json['user_id']?.toString(),
      category: json['category'],
      subCategory: json['sub_category'],
      imageUrl: json['image_url'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId.toString(),
      'category': category,
      'sub_category': subCategory,
      'image_url': imageUrl,
    };
  }
}

class WardrobeResponse {
  final bool success;
  final String message;
  final WardrobeItem? data;
  final List<WardrobeItem>? items;

  WardrobeResponse({
    required this.success,
    required this.message,
    this.data,
    this.items,
  });

  factory WardrobeResponse.fromJson(Map<String, dynamic> json) {
    return WardrobeResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? WardrobeItem.fromJson(json['data']) : null,
      items: json['items'] != null
          ? List<WardrobeItem>.from(
          json['items'].map((item) => WardrobeItem.fromJson(item)))
          : null,
    );
  }
}