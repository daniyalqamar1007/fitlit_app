import 'dart:convert';
import 'package:dio/dio.dart';
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

    print("Avatar Request Payload:");
    print(jsonEncode(request.toJson()));
    print("Token: $token");

    try {
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

      print("Avatar API Response Code: ${response.statusCode}");
      print("Avatar API Response Body: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AvatarGenerationResponse.fromJson(response.data);
      } else {
        final message = _getErrorMessage(response);
        throw Exception(message);
      }
    } on DioException catch (e) {
      print("DioException: ${e.response?.statusCode} - ${e.message}");
      throw Exception(_getDioErrorMessage(e));
    } catch (e) {
      print("Unexpected Exception: $e");
      throw Exception('Unexpected error: $e');
    }
  }

  String _getErrorMessage(Response response) {
    try {
      if (response.data is Map && response.data['message'] != null) {
        return response.data['message'];
      } else if (response.data is String) {
        return response.data;
      }
      return 'Failed with status code ${response.statusCode}';
    } catch (_) {
      return 'An unexpected error occurred';
    }
  }

  String _getDioErrorMessage(DioException e) {
    if (e.response != null && e.response?.data is Map<String, dynamic>) {
      return e.response?.data['message'] ?? 'Something went wrong';
    }
    return e.message ?? 'Something went wrong';
  }
}

