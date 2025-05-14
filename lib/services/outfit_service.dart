import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../model/outfit_model.dart';
import '../view/Utils/globle_variable/globle.dart';

class OutfitService {
  final String baseUrl = "http://localhost:3000";
  final http.Client client = http.Client();

  // Save outfit selection API
  Future<OutfitResponse> saveOutfit({
    required String token,
    required String? shirtId,
    required String? pantId,
    required String? shoeId,
    required String? accessoryId,
    required DateTime date,
  }) async {
    try {
      final formattedDate = DateFormat('dd/MM/yyyy').format(date);
      print(formattedDate);
      final String correctedUrl = baseUrl.replaceAll(
          'localhost', '192.168.18.114');
      final response = await client.post(
        Uri.parse('$correctedUrl/avatar/save-avatar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'shirt_id': shirtId,
          'pant_id': pantId,
          'shoe_id': shoeId,
          'avatarUrl': 'https://fitlit-assets.s3.us-east-2.amazonaws.com/1747230002356-undefined',
          'accessory_id': accessoryId,
          'date': formattedDate, // Now in dd/MM/yyyy format
        }),

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
      return OutfitResponse(success: false, message: 'Network error: ${e.toString()}');
    }
  }

  // Get outfit for a specific date
  Future<String?> getOutfitByDate({
    required String token,
    required DateTime date,
  }) async {
    try {
      final formattedDate = DateFormat('dd/MM/yyyy').format(date);
      print("shjdgjh");
      final String correctedUrl = baseUrl.replaceAll(
          'localhost', '192.168.18.114');

      final response = await client.get(
        Uri.parse('$correctedUrl/avatar/check?date=${formattedDate}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print(response.body);


      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print(jsonResponse['avatarUrl']);
        if(jsonResponse['success']==false){
          url="";
        }
        else{
          url="655";
        }
        return jsonResponse['avatarUrl'].toString();
      //  return OutfitResponse.fromJson(jsonResponse);
      } else {
        final errorMessage = getErrorMessage(response);
        return errorMessage.toString();
       // return OutfitResponse(success: false, message: errorMessage);
      }
    } catch (e) {
      return "Issue on site";
     // return OutfitResponse(success: false, message: 'Network error: ${e.toString()}');
    }
  }

  // Helper to extract error message from response
  String getErrorMessage(http.Response response) {
    try {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['message'] ?? 'An error occurred: ${response.statusCode}';
    } catch (e) {
      return 'An error occurred: ${response.statusCode}';
    }
  }
}