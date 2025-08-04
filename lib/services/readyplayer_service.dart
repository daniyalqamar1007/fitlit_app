import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ReadyPlayerService {
  late final Dio _dio;
  static const String baseUrl = 'https://api.readyplayer.me';
  static const String subdomain = 'demo'; // Replace with your subdomain
  
  ReadyPlayerService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10), // Much faster than 3 minutes!
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': 'YOUR_API_KEY', // Add your ReadyPlayer.me API key
      },
    ));
  }

  /// Generate avatar URL instantly with customization options
  /// This is MUCH faster than the current 3+ minute avatar generation
  Future<String> generateAvatarUrl({
    String? bodyType = 'fullbody', // 'fullbody' or 'halfbody'
    Map<String, dynamic>? customization,
  }) async {
    try {
      // ReadyPlayer.me provides instant avatar URLs
      // No polling or waiting required!
      
      final avatarId = await _createAvatar(customization: customization);
      
      // Generate the avatar URL instantly
      final avatarUrl = '$baseUrl/v1/avatars/$avatarId.glb';
      
      print('✅ Avatar generated instantly: $avatarUrl');
      return avatarUrl;
      
    } catch (e) {
      print('❌ ReadyPlayer.me error: $e');
      throw Exception('Failed to generate avatar: $e');
    }
  }

  /// Create customized avatar with clothing options
  Future<String> createCustomizedAvatar({
    String? shirtColor,
    String? pantColor,
    String? shoeColor,
    String? skinTone,
    String? hairColor,
    String? hairStyle,
    bool? glasses,
  }) async {
    try {
      final customization = {
        if (shirtColor != null) 'outfit-shirt-color': shirtColor,
        if (pantColor != null) 'outfit-pants-color': pantColor,
        if (shoeColor != null) 'outfit-shoes-color': shoeColor,
        if (skinTone != null) 'skin-tone': skinTone,
        if (hairColor != null) 'hair-color': hairColor,
        if (hairStyle != null) 'hair-style': hairStyle,
        if (glasses != null) 'glasses': glasses,
      };

      final response = await _dio.post(
        '/v1/avatars',
        data: {
          'partner': subdomain,
          'bodyType': 'fullbody',
          'assets': customization,
        },
      );

      final avatarId = response.data['id'];
      final avatarUrl = '$baseUrl/v1/avatars/$avatarId.glb';
      
      print('✅ Customized avatar created instantly: $avatarUrl');
      return avatarUrl;
      
    } catch (e) {
      print('❌ Failed to create customized avatar: $e');
      throw Exception('Failed to create avatar: $e');
    }
  }

  /// Create avatar from photo (much faster than current AI generation)
  Future<String> createAvatarFromPhoto(String photoBase64) async {
    try {
      final response = await _dio.post(
        '/v1/avatars/from-photo',
        data: {
          'partner': subdomain,
          'photo': photoBase64,
          'bodyType': 'fullbody',
        },
      );

      final avatarId = response.data['id'];
      final avatarUrl = '$baseUrl/v1/avatars/$avatarId.glb';
      
      print('✅ Photo-based avatar created: $avatarUrl');
      return avatarUrl;
      
    } catch (e) {
      print('❌ Failed to create avatar from photo: $e');
      throw Exception('Failed to create avatar from photo: $e');
    }
  }

  /// Get avatar customization options
  Future<Map<String, dynamic>> getCustomizationOptions() async {
    try {
      final response = await _dio.get('/v1/assets');
      return response.data;
    } catch (e) {
      print('❌ Failed to get customization options: $e');
      throw Exception('Failed to get customization options: $e');
    }
  }

  /// Private helper to create avatar
  Future<String> _createAvatar({Map<String, dynamic>? customization}) async {
    final response = await _dio.post(
      '/v1/avatars',
      data: {
        'partner': subdomain,
        'bodyType': 'fullbody',
        if (customization != null) 'assets': customization,
      },
    );
    
    return response.data['id'];
  }

  /// Update avatar with new clothing items
  Future<String> updateAvatarClothing({
    required String avatarId,
    String? shirtId,
    String? pantId,
    String? shoeId,
    String? accessoryId,
  }) async {
    try {
      final updates = <String, dynamic>{};
      
      if (shirtId != null) updates['outfit-shirt'] = shirtId;
      if (pantId != null) updates['outfit-pants'] = pantId;
      if (shoeId != null) updates['outfit-shoes'] = shoeId;
      if (accessoryId != null) updates['accessories'] = accessoryId;

      await _dio.patch(
        '/v1/avatars/$avatarId',
        data: {'assets': updates},
      );

      final updatedUrl = '$baseUrl/v1/avatars/$avatarId.glb';
      print('✅ Avatar updated instantly: $updatedUrl');
      return updatedUrl;
      
    } catch (e) {
      print('❌ Failed to update avatar: $e');
      throw Exception('Failed to update avatar: $e');
    }
  }
}

/// Fast avatar response model
class FastAvatarResponse {
  final String avatarUrl;
  final String avatarId;
  final bool success;
  final String? message;

  FastAvatarResponse({
    required this.avatarUrl,
    required this.avatarId,
    required this.success,
    this.message,
  });

  factory FastAvatarResponse.fromJson(Map<String, dynamic> json) {
    return FastAvatarResponse(
      avatarUrl: json['avatarUrl'] ?? '',
      avatarId: json['avatarId'] ?? '',
      success: json['success'] ?? false,
      message: json['message'],
    );
  }
}
