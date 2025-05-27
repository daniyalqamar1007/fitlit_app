import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../model/avatar_model.dart';
import '../view/Utils/globle_variable/globle.dart';

class AvatarService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  Future<AvatarGenerationResponse> generateAvatar({
    String? shirtId,
    String? pantId,
    String? shoeId,
    required String? token,
  }) async {
    final request = AvatarGenerationRequest(
      shirtId: shirtId,
      pantId: pantId,
      shoeId: shoeId,
    );

    try {
      print("Calling avatar API via Dio...");
      final response = await _dio.post(
        '/avatar/outfit',
        data: request.toJson(),
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AvatarGenerationResponse.fromJson(response.data);
      } else {
        throw Exception(
            'Avatar generation failed. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print("Dio Exception: ${e.message}");
      throw Exception('Dio error generating avatar: ${e.message}');
    } catch (e) {
      print("Unexpected Exception: $e");
      throw Exception('Unexpected error generating avatar: $e');
    }
  }
}
