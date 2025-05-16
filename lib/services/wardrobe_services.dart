import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/wardrobe_model.dart';
import '../view/Utils/globle_variable/globle.dart';

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

      if (response.statusCode == 200) {
        print("Successfully received response from API");

        // Print a small sample of the response for debugging
        print("Response preview: ${response.body.substring(0, min(5000, response.body.length))}...");

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

  Future<WardrobeItem> uploadWardrobeItem({
    required String category,
    required String subCategory,
    required File imageFile,
    required String? token,
  }) async {
    try {
      print("Starting image upload process...");
      print("Category: $category, SubCategory: $subCategory");
      print("Image file size: ${await imageFile.length()} bytes");
      print("Image file path: ${imageFile.path}");
      print("Token: ${token != null ? 'Present (${token.length} chars)' : 'NULL'}");

      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/wardrobe-items'));

      // Add headers
      if (token != null && token.isNotEmpty) {
        request.headers.addAll({
          'Authorization': 'Bearer $token',
          // Add content-type header explicitly
          'Accept': 'application/json',
        });
      } else {
        print("WARNING: Token is null or empty!");
      }

      // Log all request headers for debugging
      print("Request headers: ${request.headers}");

      // Add text fields
      request.fields['category'] = category;
      request.fields['sub_category'] = subCategory;

      // Add file
      var fileStream = http.ByteStream(imageFile.openRead());
      var fileLength = await imageFile.length();

      var multipartFile = http.MultipartFile(
          'image',
          fileStream,
          fileLength,
          filename: imageFile.path.split('/').last,
          // contentType: MediaType('image', 'jpeg') // Explicitly set content type
      );

      request.files.add(multipartFile);
      print("Request prepared, sending to server...");

      var streamedResponse = await request.send();
      print(streamedResponse.statusCode);

      var response = await http.Response.fromStream(streamedResponse);

      print("Upload API response status code: ${response.statusCode}");
      print("Upload API response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          // Parse response
          Map<String, dynamic> responseData = json.decode(response.body);

          // Check if response contains the item directly or nested in a field
          Map<String, dynamic> itemData;
          if (responseData.containsKey('data')) {
            itemData = responseData['data'];
          } else if (responseData.containsKey('item')) {
            itemData = responseData['item'];
          } else {
            // Assume the response is the item itself
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
    } catch (e) {
      print("Exception during image upload: $e");
      throw Exception('Error uploading wardrobe item: $e');
    }
  }
  int min(int a, int b) {
    return a < b ? a : b;
  }
}