import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/avatar_model.dart';
import '../view/Utils/globle_variable/globle.dart';

class AvatarService {

  Future<AvatarGenerationResponse> generateAvatar({
    String? shirtId,
    String? pantId,
    String? shoeId,
    required String? token,
  }) async {
    Future<http.Response> callApi() async {
      final request = AvatarGenerationRequest(
        shirtId: shirtId,
        pantId: pantId,
        shoeId: shoeId,
      );

      return await http.post(
        Uri.parse('$baseUrl/avatar/outfit'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
        body: json.encode(request.toJson()),
      );
    }

    try {
      print("Calling avatar API...");

      // Setup a timeout for 180 seconds
      final response = await callApi()
          .timeout(Duration(seconds: 300), onTimeout: () async {
        print("Initial call timed out. Retrying after 180 seconds...");

        return await callApi();
      });

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return AvatarGenerationResponse.fromJson(data);
      } else {
        throw Exception(
            'Avatar generation failed. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Exception during avatar generation: $e");
      throw Exception('Error generating avatar: $e');
    }
  }


}