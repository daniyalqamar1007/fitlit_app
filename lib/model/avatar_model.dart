class AvatarGenerationRequest {
  final String? shirtId;
  final String? pantId;
  final String? shoeId;

  AvatarGenerationRequest({
    this.shirtId,
    this.pantId,
    this.shoeId,
  });

  Map<String, dynamic> toJson() {
    return {
      if (shirtId != null) 'shirt_id': shirtId,
      if (pantId != null) 'pant_id': pantId,
      if (shoeId != null) 'shoe_id': shoeId,
    };
  }
}

class AvatarGenerationResponse {
  final String? avatar;

  AvatarGenerationResponse({
    this.avatar,
  });

  factory AvatarGenerationResponse.fromJson(Map<String, dynamic> json) {
    return AvatarGenerationResponse(
      avatar: json['avatar'],
    );
  }
}