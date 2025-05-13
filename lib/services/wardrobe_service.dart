import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fitlip_app/view/Utils/globle_variable/globle.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../model/wardrobe_model.dart';

class WardrobeService {
  final String baseUrl = "http://localhost:3000";
  final http.Client _client = http.Client();

  Future<List<WardrobeItem>> getWardrobeItems() async {
    try {
      final String correctedUrl = baseUrl.replaceAll(
          'localhost', '192.168.43.63'); // Replace with your actual IP
      print("coming");
      final response = await _client.get(
        Uri.parse('$correctedUrl/wardrobe-items'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is List) {
          return responseData
              .map((item) => WardrobeItem.fromJson(item))
              .toList();
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception(
            'Failed to load wardrobe items. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error retrieving wardrobe items: $e');
    }
  }

  // Get wardrobe items by category
  Future<List<WardrobeItem>> getWardrobeItemsByCategory(
      String userId, String category, String? token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/wardrobe-items?user_id=$userId&category=$category'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['items'] != null) {
          return List<WardrobeItem>.from(
              responseData['items'].map((item) => WardrobeItem.fromJson(item)));
        }
        return [];
      } else {
        throw Exception(
            'Failed to load wardrobe items by category: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error retrieving wardrobe items by category: $e');
    }
  }

  Future<WardrobeItem> uploadWardrobeItem({
    required String category,
    required String subCategory,
    required File imageFile,
    required String? token,
  }) async {
    try {

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token is missing or empty');
      }

      final String correctedUrl = baseUrl.replaceAll(
          'localhost', '192.168.43.63'); // Use your actual IP
      final Uri uri = Uri.parse('$correctedUrl/wardrobe-items');
      print("Sending request to: $uri");

      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['category'] = category;
      request.fields['sub_category'] = subCategory;

      String filename = imageFile.path.split('/').last;
      String extension = filename.split('.').last.toLowerCase();
      String mimeType = 'image/$extension';
      final file = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType.parse(mimeType),
      );
      request.files.add(file);

      http.StreamedResponse streamedResponse;
      try {
        streamedResponse = await request.send().timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            throw TimeoutException('Request timed out after 60 seconds');
          },
        );
      } catch (e) {
        rethrow;
      }


      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['data'] != null) {

          return WardrobeItem.fromJson(responseData['data']);
        } else {
          // Fallback: try parsing entire response body directly
          print("Fallback: Attempting to parse entire body as WardrobeItem");
          return WardrobeItem.fromJson(
              responseData); // Adjust based on your actual model structure
        }
      } else {
        throw Exception(
            'Server error: ${response.statusCode} - ${response.body}');
      }
    } on SocketException catch (e) {
      throw Exception(
          'Network error: Check your internet connection - ${e.message}');
    } on TimeoutException catch (_) {
      throw Exception('Request timed out: The server took too long to respond');
    } on FormatException catch (_) {
      throw Exception('Data format error: The response could not be parsed');
    } catch (e) {

      throw Exception('Error uploading wardrobe item: $e');
    }

  }

  Future<bool> deleteWardrobeItem(String itemId, String? token) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/wardrobe-items/$itemId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete wardrobe item: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting wardrobe item: $e');
    }
  }
}
