// background_image_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/background_image_model.dart';

class BackgroundImageService {
  static const String baseUrl = 'https://nnl056zh-3099.inc1.devtunnels.ms';

  // Timeout duration for requests
  static const Duration timeoutDuration = Duration(seconds: 120);

  // Headers helper method
  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Headers helper method for multipart requests
  Map<String, String> _getAuthHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
    };
  }

  // 1. Generate image from prompt
  Future<GenerateImageResponse> generateFromPrompt({
    required String token,
    required String prompt,
  }) async {
    try {
      if (token.isEmpty) {
        return GenerateImageResponse(
          success: false,
          message: 'Token is required',
        );
      }

      if (prompt.trim().isEmpty) {
        return GenerateImageResponse(
          success: false,
          message: 'Prompt is required',
        );
      }

      final url = Uri.parse('$baseUrl/background-images/generate');

      final body = jsonEncode({
        'prompt': prompt.trim(),
      });

      print('Generating image from prompt: $prompt');

      final response = await http.post(
        url,
        headers: _getHeaders(token),
        body: body,
      );

      print('Generate from prompt response status: ${response.statusCode}');
      print('Generate from prompt response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return GenerateImageResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        return GenerateImageResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to generate image from prompt',
        );
      }
    } catch (e) {
      print('Error in generateFromPrompt: $e');
      return GenerateImageResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // 2. Generate image from image file
  Future<GenerateImageResponse> generateFromImage({
    required String token,
    required File imageFile,
  }) async {
    try {
      if (token.isEmpty) {
        return GenerateImageResponse(
          success: false,
          message: 'Token is required',
        );
      }

      if (!await imageFile.exists()) {
        return GenerateImageResponse(
          success: false,
          message: 'Image file does not exist',
        );
      }

      final url = Uri.parse('$baseUrl/background-images/generate');

      print('Generating image from file: ${imageFile.path}');

      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(_getAuthHeaders(token));

      // Add file to request
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // This should match your API's expected field name
          imageFile.path,
        ),
      );

      final streamedResponse = await request.send().timeout(timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);

      print('Generate from image response status: ${response.statusCode}');
      print('Generate from image response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return GenerateImageResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        return GenerateImageResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to generate image from file',
        );
      }
    } catch (e) {
      print('Error in generateFromImage: $e');
      return GenerateImageResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // 3. Get all background images
  Future<BackgroundImagesResponse> getAllBackgroundImages({
    required String token,
  }) async {
    try {
      if (token.isEmpty) {
        return BackgroundImagesResponse(
          success: false,
          images: [],
          message: 'Token is required',
        );
      }

      final url = Uri.parse('$baseUrl/background-images');

      print('Fetching all background images');

      final response = await http.get(
        url,
        headers: _getHeaders(token),
      ).timeout(timeoutDuration);

      print('Get all images response status: ${response.statusCode}');
      print('Get all images response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return BackgroundImagesResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        return BackgroundImagesResponse(
          success: false,
          images: [],
          message: errorData['message'] ?? 'Failed to fetch background images',
        );
      }
    } catch (e) {
      print('Error in getAllBackgroundImages: $e');
      return BackgroundImagesResponse(
        success: false,
        images: [],
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // 4. Change image status
  Future<ChangeStatusResponse> changeImageStatus({
    required String token,
    required String backgroundImageId,
  }) async {
    try {
      if (token.isEmpty) {
        return ChangeStatusResponse(
          success: false,
          message: 'Token is required',
        );
      }

      if (backgroundImageId.trim().isEmpty) {
        return ChangeStatusResponse(
          success: false,
          message: 'Background image ID is required',
        );
      }

      final url = Uri.parse('$baseUrl/background-images/change-status');

      final body = jsonEncode({
        'background_image_id': backgroundImageId.trim(),
      });

      print('Changing status for image ID: $backgroundImageId');

      final response = await http.post(
        url,
        headers: _getHeaders(token),
        body: body,
      );

      print('Change status response status: ${response.statusCode}');
      print('Change status response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return ChangeStatusResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        return ChangeStatusResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to change image status',
        );
      }
    } catch (e) {
      print('Error in changeImageStatus: $e');
      return ChangeStatusResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}