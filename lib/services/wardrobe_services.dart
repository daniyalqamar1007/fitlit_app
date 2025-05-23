import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import '../model/wardrobe_model.dart';
import '../view/Utils/globle_variable/globle.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data' as typed_data;
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img; // Import for image processing
import 'package:path_provider/path_provider.dart'; // Import for temp directory access
import 'package:path/path.dart' as path;
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data' as typed_data;
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
class WardrobeService {

  WardrobeService(); // Constructor with optional token parameter

  Future<List<WardrobeItem>> getWardrobeItems() async {
    try {
      print("Fetching wardrobe items from API...");

      final response = await http.get(
        Uri.parse('$baseUrl/wardrobe-items'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("API Response Status Code: ${response.statusCode}");
      print(response.body);
      print("Response preview: ${response.body.substring(0, min(5000000, response.body.length))}...");

      if (response.statusCode == 200) {
        print("Successfully received response from API");

        // Print a small sample of the response for debugging
        print("Response preview: ${response.body.substring(0, min(5000000, response.body.length))}...");

        try {
          // Parse the response body
          final dynamic responseData = json.decode(response.body);
          print("Response data type: ${responseData.runtimeType}");

          // Initialize with empty list to avoid null issues
          List<dynamic> itemsList = [];

          // Handle different response formats
          if (responseData is List) {
            // Response is directly a list
            itemsList = responseData;
          } else if (responseData is Map && responseData.containsKey('data')) {
            // Response is wrapped in a data field
            var data = responseData['data'];
            if (data is List) {
              itemsList = data;
            } else {
              print("'data' field is not a List: ${data.runtimeType}");
            }
          } else if (responseData is Map && responseData.containsKey('items')) {
            // Response is wrapped in an items field
            var items = responseData['items'];
            if (items is List) {
              itemsList = items;
            } else {
              print("'items' field is not a List: ${items.runtimeType}");
            }
          } else if (responseData is Map && responseData.containsKey('wardrobeItems')) {
            // Another possible wrapper
            var wardrobeItems = responseData['wardrobeItems'];
            if (wardrobeItems is List) {
              itemsList = wardrobeItems;
            } else {
              print("'wardrobeItems' field is not a List: ${wardrobeItems.runtimeType}");
            }
          } else {
            // If none of the above, try to extract the first list found
            bool foundList = false;
            if (responseData is Map) {
              for (var key in responseData.keys) {
                if (responseData[key] is List) {
                  itemsList = responseData[key];
                  foundList = true;
                  print("Found items in field: $key");
                  break;
                }
              }
            }

            if (!foundList) {
              print("Could not find any list in response. Response structure: $responseData");
              // Return empty list instead of throwing exception
              return [];
            }
          }

          // Now parse and convert to WardrobeItem objects
          print("Found ${itemsList.length} items, parsing...");

          List<WardrobeItem> result = [];
          for (var item in itemsList) {
            try {
              result.add(WardrobeItem.fromJson(item));
            } catch (e) {
              print("Error parsing item: $e");
              print("Problematic item data: $item");
            }
          }

          print("Successfully parsed ${result.length} wardrobe items");
          return result;
        } catch (e) {
          print("JSON parsing error: $e");
          // Print the full response for debugging when we have a parsing error
          print("Full response body: ${response.body}");
          throw Exception('Failed to parse response: $e');
        }
      } else {
        print("API error response: ${response.body}");
        throw Exception(
            'Failed to load wardrobe items. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Exception in getWardrobeItems: $e");
      throw Exception('Error retrieving wardrobe items: $e');
    }
  }
 // Add this import for image processing
// Add this for path manipulation
 // For path manipulation
  // Import for MediaType




  Future<WardrobeItem> uploadWardrobeItem({
    required String category,
    required String subCategory,
    required String? avatarurl,
    required File imageFile,
    required String? token,
  }) async {
    try {
      print("Starting image upload process...");
      print("Category: $category, SubCategory: $subCategory");
      print("avatarurl: $avatarurl");
      print("Original image file size: ${await imageFile.length()} bytes");
      print("Original image file path: ${imageFile.path}");
      print("Token: ${token != null ? 'Present (${token.length} chars)' : 'NULL'}");

      // Convert image to PNG format
      File pngImageFile = await _convertImageToPng(imageFile);
      print("Converted PNG image file size: ${await pngImageFile.length()} bytes");
      print("Converted PNG image file path: ${pngImageFile.path}");

      // Create multipart request with timeout
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/wardrobe-items'))
        ..headers.addAll({
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        })
        ..fields.addAll({
          'category': category,
          'sub_category': subCategory,
          'avatar': avatarurl!,
        });

      // Add PNG file with timeout handling
      var multipartFile = await http.MultipartFile.fromPath(
          'file',
          pngImageFile.path,
          contentType: MediaType('image', 'png')
      ).timeout(const Duration(seconds: 360));
      request.files.add(multipartFile);

      print("Request prepared, sending to server...");
      print(request.fields);

      // Send request with timeout
      var streamedResponse = await request.send();

      print("Response status code: ${streamedResponse.statusCode}");

      // Process response with timeout
      var response = await http.Response.fromStream(streamedResponse);

      print("Upload API response status code: ${response.statusCode}");
      print("Upload API response body:");
      response.body.replaceAllMapped(RegExp('.{1,15000}', dotAll: true), (match) {
        print(match.group(0));
        return ''; // Required to satisfy the function's return type
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          Map<String, dynamic> responseData = json.decode(response.body);
          Map<String, dynamic> itemData;

          if (responseData.containsKey('data')) {
            itemData = responseData['data'];
          } else if (responseData.containsKey('item')) {
            itemData = responseData['item'];
          } else {
            itemData = responseData;
          }

          return WardrobeItem.fromJson(itemData);
        } catch (e) {
          print("Error parsing upload response: $e");
          print("Raw response: ${response.body}");
          throw Exception('Failed to parse upload response: $e');
        }
      } else {
        print("Upload failed with status ${response.statusCode}");
        print("Response body: ${response.body}");
        throw Exception('Failed to upload wardrobe item. Status code: ${response.statusCode}, Response: ${response.body}');
      }
    } on TimeoutException catch (e) {
      print("Request timed out: $e");
      throw Exception('The request took too long to complete. Please try again.');
    } catch (e) {
      print("Exception during image upload: $e");
      throw Exception('Error uploading wardrobe item: $e');
    }
  }

  /// Helper function to convert image to PNG format
  Future<File> _convertImageToPng(File inputFile) async {
    try {
      // Read file as bytes
      final List<int> bytesList = await inputFile.readAsBytes();

      // Convert to Uint8List explicitly
      final typed_data.Uint8List bytes = typed_data.Uint8List.fromList(bytesList);

      // Decode the image
      final img.Image? decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) {
        throw Exception('Failed to decode the image');
      }

      // Encode to PNG
      final pngBytes = img.encodePng(decodedImage);

      // Create a new file path with .png extension
      final directory = await getTemporaryDirectory();
      String fileName = path.basenameWithoutExtension(inputFile.path) + '.png';
      final pngFilePath = path.join(directory.path, fileName);

      // Write the converted PNG file
      File pngFile = File(pngFilePath);
      await pngFile.writeAsBytes(pngBytes);

      print("Image successfully converted to PNG format");
      return pngFile;
    } catch (e) {
      print("Error converting image to PNG: $e");
      throw Exception('Failed to convert image to PNG format: $e');
    }
  }




  int min(int a, int b) {
    return a < b ? a : b;
  }
}