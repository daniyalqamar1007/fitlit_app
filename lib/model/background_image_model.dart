// background_image_model.dart

class BackgroundImageModel {
  final String id;
  final String imageUrl;
  final bool status;

  BackgroundImageModel({
    required this.id,
    required this.imageUrl,
    required this.status,
  });

  factory BackgroundImageModel.fromJson(Map<String, dynamic> json) {
    return BackgroundImageModel(
      id: json['id'] ?? '',
      imageUrl: json['image_url'] ?? '',
      status: json['status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'status': status,
    };
  }

  BackgroundImageModel copyWith({
    String? id,
    String? imageUrl,
    bool? status,
  }) {
    return BackgroundImageModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'BackgroundImageModel(id: $id, imageUrl: $imageUrl, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BackgroundImageModel &&
        other.id == id &&
        other.imageUrl == imageUrl &&
        other.status == status;
  }

  @override
  int get hashCode => id.hashCode ^ imageUrl.hashCode ^ status.hashCode;
}

// Response models for API responses
class GenerateImageResponse {
  final bool success;
  final String? imageUrl;
  final String? message;

  GenerateImageResponse({
    required this.success,
    this.imageUrl,
    this.message,
  });

  factory GenerateImageResponse.fromJson(Map<String, dynamic> json) {
    return GenerateImageResponse(
      success: json['success'] ?? false,
      imageUrl: json['image_url'],
      message: json['message'],
    );
  }
}

class BackgroundImagesResponse {
  final bool success;
  final List<BackgroundImageModel> images;
  final String? message;

  BackgroundImagesResponse({
    required this.success,
    required this.images,
    this.message,
  });

  factory BackgroundImagesResponse.fromJson(Map<String, dynamic> json) {
    return BackgroundImagesResponse(
      success: json['success'] ?? false,
      images: json['images'] != null
          ? (json['images'] as List)
          .map((item) => BackgroundImageModel.fromJson(item))
          .toList()
          : [],
      message: json['message'],
    );
  }
}

class ChangeStatusResponse {
  final bool success;
  final String? message;
  final BackgroundImageModel? image;

  ChangeStatusResponse({
    required this.success,
    this.message,
    this.image,
  });

  factory ChangeStatusResponse.fromJson(Map<String, dynamic> json) {
    return ChangeStatusResponse(
      success: json['success'] ?? false,
      message: json['message'],
      image: json['image'] != null
          ? BackgroundImageModel.fromJson(json['image'])
          : null,
    );
  }
}