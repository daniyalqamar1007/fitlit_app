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
          'localhost', '192.168.18.114'); // Replace with your actual IP
      print("coming");
      final response = await _client.get(
        Uri.parse('$correctedUrl/wardrobe-items'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print(response.body);


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
  }) async
  {
    try {
      // Log token and basic info
      print('📌 Starting upload process...');
      print('🔑 Token: ${token != null ? "*****" + token.substring(token.length - 4) : "NULL"}');
      print('📂 File path: ${imageFile.path}');
      print('📏 File size: ${(await imageFile.length()) / 1024} KB');
      print('🏷️ Category: $category, Subcategory: $subCategory');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token is missing or empty');
      }

      final String correctedUrl = baseUrl.replaceAll('localhost', '192.168.18.114');
      final Uri uri = Uri.parse('$correctedUrl/wardrobe-items');
      print('🌐 API Endpoint: $uri');
      final http.Client _client = http.Client();

      final request = http.MultipartRequest('POST', uri);

      // Log headers
      print('📤 Request Headers:');
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });
      request.headers.forEach((key, value) => print('   $key: $value'));

      request.fields['category'] = category;
      request.fields['sub_category'] = subCategory;

      // Log file details
      String filename = imageFile.path.split('/').last;
      String extension = filename.split('.').last.toLowerCase();
      String mimeType = 'image/$extension';
      print('📄 File Details:');
      print('   Name: $filename');
      print('   Type: $mimeType');
      print('   Extension: $extension');

      final file = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType.parse(mimeType),
      );
      request.files.add(file);

      // Log before sending


      http.StreamedResponse streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw TimeoutException('Request timed out after 60 seconds');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      // Log complete response
      print('✅ Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');
      print('📋 Response Headers:');
      response.headers.forEach((key, value) => print('   $key: $value'));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Log parsed data
        print('🔍 Parsed Response Data:');
        responseData.forEach((key, value) => print('   $key: $value'));

        if (responseData['data'] != null) {
          print('🛍️ Successfully created WardrobeItem');
          return WardrobeItem.fromJson(responseData['data']);
        } else {
          print('⚠️ No "data" field in response, parsing full body');
          return WardrobeItem.fromJson(responseData);
        }
      } else {
        print('❌ Server error response');
        throw Exception('Server error: ${response.statusCode} - ${response.body}');
      }
    } on SocketException catch (e) {
      print('🚫 Network error: ${e.message}');
      throw Exception('Network error: Check your internet connection - ${e.message}');
    } on TimeoutException catch (_) {
      print('⏰ Request timeout');
      throw Exception('Request timed out: The server took too long to respond');
    } on FormatException catch (_) {
      print('📛 Response format error');
      throw Exception('Data format error: The response could not be parsed');
    } catch (e) {
      print('❗ Unexpected error: $e');
      throw Exception('Error uploading wardrobe item: $e');
    } finally {
      print('🏁 Upload process completed');
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
