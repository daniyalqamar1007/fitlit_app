// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:path/path.dart';
// import '../model/outfit_model.dart';
// import '../view/Utils/connection.dart';
// import '../view/Utils/globle_variable/globle.dart';
//
// class OutfitService {
//   final http.Client client = http.Client();
//   Future<OutfitResponse> saveOutfit(
//       {required String token,
//       required String? shirtId,
//       required String? pantId,
//       required String? shoeId,
//       required String? accessoryId,
//       required DateTime date,
//       required String avatarurl}) async
//   {
//     try {
//
//       print(avatarurl);
//       final formattedDate = DateFormat('dd/MM/yyyy').format(date);
//       print(formattedDate);
// print(shirtId);
// print(pantId);
// print(accessoryId);
// print(shoeId
// );
//       final response = await http.post(
//         Uri.parse('$baseUrl/avatar/save-avatar'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           'shirt_id': shirtId,
//           'pant_id': pantId,
//           'shoe_id': shoeId,
//           // 'index':avatarindex.toString(),
//           'avatarUrl': avatarurl,
//           'accessories_id': accessoryId.toString(),
//           'date': formattedDate, // Now in dd/MM/yyyy format
//         }),
//       );
//
//       print(response.body);
//       print(response.statusCode);
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final jsonResponse = jsonDecode(response.body);
//
//         print(jsonResponse);
//         return OutfitResponse.fromJson(jsonResponse);
//       } else {
//         final errorMessage = getErrorMessage(response);
//         return OutfitResponse(success: false, message: errorMessage);
//       }
//     } catch (e) {
//       return OutfitResponse(
//           success: false, message: 'Network error: ${e.toString()}');
//     }
//   }
//
//   Future<String?> getOutfitByDate({
//     required String token,
//     required DateTime date,
//     required int id
//   }) async {
//     try {
//
//       final formattedDate = DateFormat('dd/MM/yyyy').format(date);
//       print("Fetching avatar for date: $formattedDate");
// print(id);
//       final response = await client.get(
//         Uri.parse('$baseUrl/avatar/check?date=$formattedDate&id=$id'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );
//       print("API Response: ${response.body}");
//
//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);
//
//         if (jsonResponse['success'] == true) {
//           return jsonResponse['avatarUrl'].toString();
//         } else {
//           avatarindex = 3; // Default index for fallback
//           print("API returned success=false, using default avatar");
//
//           // You can return a default avatar URL here if needed
//           return null;
//         }
//       } else {
//         final errorMessage = getErrorMessage(response);
//         print("API Error: $errorMessage");
//         return null;
//       }
//     } catch (e) {
//       print("Exception during API call: ${e.toString()}");
//       return null;
//     }
//   }
//
//   // Helper to extract error message from response
//   String getErrorMessage(http.Response response) {
//     try {
//       final jsonResponse = jsonDecode(response.body);
//       return jsonResponse['message'] ??
//           'An error occurred: ${response.statusCode}';
//     } catch (e) {
//       return 'An error occurred: ${response.statusCode}';
//     }
//   }
// }
//outfit_service.dart
import 'dart:convert';
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
    required String avatarurl,
    String? message, // Optional message parameter
  }) async {
    try {
      print(avatarurl);
      final formattedDate = DateFormat('dd/MM/yyyy').format(date);
      print(formattedDate);
      print(shirtId);
      print(pantId);
      print(accessoryId);
      print(shoeId);
      print(message);
      print(backgroundimageurl);


      Map<String, dynamic> requestBody = {
        'shirt_id': shirtId,
        'pant_id': pantId,
        'shoe_id': shoeId,
        'avatarUrl': avatarurl,
          'backgroundimageurl':backgroundimageurl,
        'accessories_id': accessoryId.toString(),
        'stored_message':message,
        'date': formattedDate,
      };

      // Add message if provided
      if (message != null && message.isNotEmpty) {
        requestBody['message'] = message;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/avatar/save-avatar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        print(jsonResponse);
        return OutfitResponse.fromJson(jsonResponse);
      } else {
        final errorMessage = getErrorMessage(response);
        return OutfitResponse(success: false, message: errorMessage);
      }
    } catch (e) {
      return OutfitResponse(
          success: false, message: 'Network error: ${e.toString()}');
    }
  }

  Future<String?> getOutfitByDate({
    required String token,
    required DateTime date,
    required int id
  }) async {
    try {
      final formattedDate = DateFormat('dd/MM/yyyy').format(date);
      print("Fetching avatar for date: $formattedDate");
      print(id);

      final response = await client.get(
        Uri.parse('$baseUrl/avatar/check?date=$formattedDate&id=$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("API Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true) {
          return jsonResponse['avatarUrl'].toString();
        } else {
          avatarindex = 3; // Default index for fallback
          print("API returned success=false, using default avatar");
          return null;
        }
      } else {
        final errorMessage = getErrorMessage(response);
        print("API Error: $errorMessage");
        return null;
      }
    } catch (e) {
      print("Exception during API call: ${e.toString()}");
      return null;
    }
  }

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