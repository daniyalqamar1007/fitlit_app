import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
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
      print("nbwo working");
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
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 360),
    receiveTimeout: const Duration(seconds: 360),
    headers: {
      'Accept': 'application/json',
    },
  ));
  Future<WardrobeItem> uploadWardrobeItem({
    required String category,
    required String subCategory,
    required String? avatarurl,
    required File imageFile,
    required String? token,
  }) async
  {
    try {
      // Input validation
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token is required');
      }

      if (avatarurl == null || avatarurl.isEmpty) {
        throw Exception('Avatar URL is required');
      }

      // Debug logging
      print("=== Upload Request Debug ===");
      print("Category: $category");
      print("SubCategory: $subCategory");
      print("Avatar URL: $avatarurl");
      print("Image File Path: ${imageFile.path}");
      print("Token: ${token.substring(0, 20)}..."); // Show only first 20 chars for security
      print("==============================");

      // Check if original file exists
      if (!await imageFile.exists()) {
        throw Exception('Source image file does not exist: ${imageFile.path}');
      }

      // Convert image to PNG format
      File pngImageFile = await _convertImageToPng(imageFile);
      print("Image successfully converted to PNG format");

      // Verify converted file exists and get file info
      if (!await pngImageFile.exists()) {
        throw Exception('Converted PNG file does not exist');
      }

      // int fileSize = await pngImageFile.length();
      // print("PNG file size: ${fileSize} bytes");

      // Create FormData with proper field names
      FormData formData = FormData.fromMap({
        'category': category,
        'sub_category': subCategory, // Fixed: removed asterisk from 'sub*category'
        'avatar': avatarurl,
        'file': await MultipartFile.fromFile(
          pngImageFile.path,
          filename: 'wardrobe_${DateTime.now().millisecondsSinceEpoch}.png',
          contentType: MediaType('image', 'png'),
        ),
      });

      // Debug FormData contents
      print("=== FormData Contents ===");
      formData.fields.forEach((field) {
        print("Field: ${field.key} = ${field.value}");
      });
      formData.files.forEach((file) {
        print("File: ${file.key} = ${file.value.filename} (${file.value.contentType})");
      });
      print("========================");

      // Send request with proper options
      final response = await _dio.post(
        '/wardrobe-items',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
          validateStatus: (status) => status! < 500, // Don't throw on client errors
          sendTimeout: const Duration(seconds: 500),
          receiveTimeout: const Duration(seconds: 500),
        ),
      );

      // Detailed response logging
      print("=== API Response Debug ===");
      print("Status Code: ${response.statusCode}");
      print("Status Message: ${response.statusMessage}");
      print("Response Headers: ${response.headers}");
      print("Response Data Type: ${response.data.runtimeType}");
      print("Response Data: ${response.data}");
      print("==========================");

      // Handle successful responses
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        // Handle different response structures
        Map<String, dynamic> itemData;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            itemData = responseData['data'];
          } else if (responseData.containsKey('item')) {
            itemData = responseData['item'];
          } else {
            itemData = responseData;
          }
        } else {
          throw Exception('Unexpected response format: ${responseData.runtimeType}');
        }

        print("Successfully parsed item data: ${itemData.keys}");
        return WardrobeItem.fromJson(itemData);

      } else {
        // Handle error responses with detailed information
        String errorMessage = 'Upload failed with status ${response.statusCode}';

        if (response.data != null) {
          if (response.data is Map<String, dynamic>) {
            var errorData = response.data as Map<String, dynamic>;
            if (errorData.containsKey('message')) {
              errorMessage += ': ${errorData['message']}';
            } else if (errorData.containsKey('error')) {
              errorMessage += ': ${errorData['error']}';
            } else if (errorData.containsKey('errors')) {
              errorMessage += ': ${errorData['errors']}';
            }
          } else {
            errorMessage += ': ${response.data}';
          }
        }

        print("API Error: $errorMessage");
        throw Exception(errorMessage);
      }

    } on DioException catch (e) {
      print("=== DioException Details ===");
      print("Type: ${e.type}");
      print("Message: ${e.message}");
      print("Response Status: ${e.response?.statusCode}");
      print("Response Data: ${e.response?.data}");
      print("Request Options: ${e.requestOptions.uri}");
      print("===========================");

      String errorMessage = 'Network error during upload';

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        switch (statusCode) {
          case 400:
            errorMessage = 'Bad request - please check your input data';
            if (responseData != null && responseData is Map<String, dynamic>) {
              if (responseData.containsKey('message')) {
                errorMessage += ': ${responseData['message']}';
              }
            }
            break;
          case 401:
            errorMessage = 'Authentication failed - please check your token';
            break;
          case 403:
            errorMessage = 'Access denied - insufficient permissions';
            break;
          case 413:
            errorMessage = 'File too large - please use a smaller image';
            break;
          case 422:
            errorMessage = 'Validation failed - please check your input';
            break;
          case 500:
            errorMessage = 'Server error - please try again later';
            break;
          default:
            errorMessage = 'HTTP $statusCode: ${e.message}';
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout - please check your internet connection';
      } else if (e.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Upload timeout - file might be too large';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Response timeout - server took too long to respond';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Connection error - please check your internet connection';
      }

      throw Exception(errorMessage);

    } on TimeoutException catch (e) {
      print("Timeout error: $e");
      throw Exception('Upload timed out. Please check your connection and try again.');

    } catch (e) {
      print("=== Unexpected Error ===");
      print("Type: ${e.runtimeType}");
      print("Message: $e");
      // print("Stack trace: ${StackTrace.current}");
      print("=======================");

      throw Exception('Unexpected error during upload: ${e.toString()}');
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