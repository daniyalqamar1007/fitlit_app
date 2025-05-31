class AvatarGenerationRequest {
  final String? shirtId;
  final String? acccessories_id;
  final String? pantId;
  final String? shoeId;
  final String? profile;

  AvatarGenerationRequest({
    this.shirtId,
    this.acccessories_id,
    this.pantId,
    this.shoeId, this.profile,
  });

  Map<String, dynamic> toJson() {
    return {
      if (shirtId != null) 'shirt_id': shirtId,
      if (acccessories_id != null) 'accessories_id': acccessories_id,
      if (pantId != null) 'pant_id': pantId,
      if (shoeId != null) 'shoe_id': shoeId,
      if (profile != null) 'profile_picture': profile,
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