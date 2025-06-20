
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import '../model/outfit_model.dart';
import '../view/Utils/connection.dart';
import '../view/Utils/globle_variable/globle.dart';

class OutfitService {
  final http.Client client = http.Client();

  Future<OutfitResponse> saveOutfit({
    required String token,
    required String? shirtId,
    required String? pantId,
    required String? shoeId,
    required String? accessoryId,
    required String? backgroundimageurl,
    required DateTime date,
    required File? file,
    required String avatarurl,
    String? message,
  }) async {
    try {
      final formattedDate = DateFormat('dd/MM/yyyy').format(date);

      final uri = Uri.parse('$baseUrl/avatar/save-avatar');

      var request = http.MultipartRequest('POST', uri)
        ..headers.addAll({
          'Authorization': 'Bearer $token',
          // Don't add Content-Type here — http sets it automatically for multipart
        });

      // Add fields
      request.fields['shirt_id'] = shirtId ?? '';
      request.fields['pant_id'] = pantId ?? '';
      request.fields['shoe_id'] = shoeId ?? '';
      request.fields['accessories_id'] = accessoryId ?? '';
      request.fields['avatarUrl'] = avatarurl;
      request.fields['backgroundimageurl'] = backgroundimageurl ?? '';
      request.fields['date'] = formattedDate;
      if (message != null) {
        request.fields['stored_message'] = message;
      }

      // Add image file if available
      if (file != null && file.existsSync()) {
        final fileStream = http.ByteStream(file.openRead());
        final fileLength = await file.length();

        final multipartFile = http.MultipartFile(
          'file', // this key should match your API expectation
          fileStream,
          fileLength,
          filename: basename(file.path),
        );
        request.files.add(multipartFile);
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("Multipart Response: $responseBody");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(responseBody);
        return OutfitResponse.fromJson(jsonResponse);
      } else {
        final error = getErrorMessageFromBody(responseBody, response.statusCode);
        return OutfitResponse(success: false, message: error);
      }
    } catch (e) {
      print('❌ Multipart error: $e');
      return OutfitResponse(
          success: false, message: 'Network error: ${e.toString()}');
    }
  }

// Helper to extract error message from response body
  String getErrorMessageFromBody(String body, int code) {
    try {
      final jsonResponse = jsonDecode(body);
      return jsonResponse['message'] ?? 'An error occurred: $code';
    } catch (e) {
      return 'An error occurred: $code';
    }
  }

// Updated getOutfitByDate method in OutfitService
  Future<OutfitResponse?> getOutfitByDate({
    required String token,
    required DateTime date,
    required int id,
  }) async {
    try {
      final formattedDate = DateFormat('dd/MM/yyyy').format(date);
      print("Fetching avatar for date: $formattedDate");
      print("User ID: $id");

      final response = await client.get(
        Uri.parse('$baseUrl/avatar/check?date=$formattedDate&id=$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("API Response: ${response.body}");
      print("Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Parse the response using OutfitResponse model
        final outfitResponse = OutfitResponse.fromJson(jsonResponse);

        if (outfitResponse.success) {
          print("Successfully fetched outfit data");
          print("Avatar URL: ${outfitResponse.avatar_url}");
          print("Background Image: ${outfitResponse.backgroundimage}");
          return outfitResponse;
        } else {
          print("API returned success=false: ${outfitResponse.message}");
          return OutfitResponse(
              success: false,
              message: outfitResponse.message ?? "No outfit found for this date"
          );
        }
      } else {
        final errorMessage = getErrorMessage(response);
        print("API Error: $errorMessage");
        return OutfitResponse(
            success: false,
            message: errorMessage
        );
      }
    } catch (e) {
      print("Exception during API call: ${e.toString()}");
      return OutfitResponse(
          success: false,
          message: "Network error: ${e.toString()}"
      );
    }
  }

  // Future<String?> getOutfitByDate({
  //   required String token,
  //   required DateTime date,
  //   required int id
  // }) async
  // {
  //   try {
  //     final formattedDate = DateFormat('dd/MM/yyyy').format(date);
  //     print("Fetching avatar for date: $formattedDate");
  //     print(id);
  //
  //     final response = await client.get(
  //       Uri.parse('$baseUrl/avatar/check?date=$formattedDate&id=$id'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );
  //     print("API Response: ${response.body}");
  //
  //     if (response.statusCode == 200) {
  //       final jsonResponse = jsonDecode(response.body);
  //
  //       if (jsonResponse['success'] == true) {
  //         return jsonResponse['avatarUrl'].toString();
  //       } else {
  //         avatarindex = 3; // Default index for fallback
  //         print("API returned success=false, using default avatar");
  //         return null;
  //       }
  //     } else {
  //       final errorMessage = getErrorMessage(response);
  //       print("API Error: $errorMessage");
  //       return null;
  //     }
  //   } catch (e) {
  //     print("Exception during API call: ${e.toString()}");
  //     return null;
  //   }
  // }

  // New method to get all avatar dates
  Future<AvatarListResponse> getAllAvatarsByDate({
    required String token,
  }) async
  {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/avatar/all-by-date'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("All Avatars API Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return AvatarListResponse.fromJson(jsonResponse);
      } else {
        final errorMessage = getErrorMessage(response);
        print("API Error: $errorMessage");
        return AvatarListResponse(success: false, data: []);
      }
    } catch (e) {
      print("Exception during API call: ${e.toString()}");
      return AvatarListResponse(success: false, data: []);
    }
  }

  // Helper to extract error message from response
  String getErrorMessage(http.Response response) {
    try {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['message'] ??
          'An error occurred: ${response.statusCode}';
    } catch (e) {
      return 'An error occurred: ${response.statusCode}';
    }
  }
}