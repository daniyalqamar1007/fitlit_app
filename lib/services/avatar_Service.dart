import 'dart:convert';
import 'package:dio/dio.dart';
import '../model/avatar_model.dart';
import '../view/Utils/globle_variable/globle.dart';

class AvatarService {
  late final Dio _dio;

  AvatarService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(minutes: 3), // 3 minutes connection timeout
      receiveTimeout: const Duration(minutes: 3), // 3 minutes receive timeout
      sendTimeout: const Duration(minutes: 3), // 3 minutes send timeout
      headers: {
        'Content-Type': 'application/json',
      },
      validateStatus: (status) => status != null && status < 500,
    ));
  }

  Future<AvatarGenerationResponse> generateAvatar({
    String? shirtId,
    String? pantId,
    String? shoeId,
    String? profile,
    required String? token,
  }) async {
    final request = AvatarGenerationRequest(
      shirtId: shirtId,
      pantId: pantId,
      shoeId: shoeId,
      profile: profile,
    );

    print("Avatar Request Payload:");
    print(jsonEncode(request.toJson()));
    print("Token: $token");

    // First API call
    AvatarGenerationResponse response = await _makeApiCall(request, token);

    // If we get avatar URL immediately, return it
    if (response.avatar != null && response.avatar!.isNotEmpty) {
      print("Avatar generated immediately");
      return response;
    }

    // If no avatar URL, start polling
    print("Avatar not ready, starting polling...");

    // Wait 3 minutes before first retry
    print("Waiting 3 minutes before first retry...");
    await Future.delayed(const Duration(minutes: 4));

    // Keep polling until we get the avatar
    while (true) {
      try {
        print("Polling for avatar...");
        response = await _makeApiCall(request, token);

        // Check if avatar is ready
        if (response.avatar != null && response.avatar!.isNotEmpty) {
          print("Avatar generated successfully after polling");
          return response;
        }

        // Wait 1 minute before next retry
        print("Avatar not ready yet, waiting 1 minute...");
        await Future.delayed(const Duration(minutes:2));

      } catch (e) {
        print("Error during polling: $e");
        // Wait 1 minute before retrying on error
        await Future.delayed(const Duration(minutes: 1));
      }
    }
  }

  Future<AvatarGenerationResponse> _makeApiCall(
      AvatarGenerationRequest request,
      String? token,
      ) async {
    try {
      // Prepare authorization header and make request
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );

      final response = await _dio.post(
        '/avatar/outfit',
        data: request.toJson(),
        options: options,
      );

      print("Avatar API Response Code: ${response.statusCode}");
      print("Avatar API Response Body: ${response.data}");

      return AvatarGenerationResponse.fromJson(response.data);

    } on DioException catch (e) {
      print("DioException: ${e.response?.statusCode} - ${e.message}");
      throw Exception(_getDioErrorMessage(e));
    } catch (e) {
      print("Unexpected Exception: $e");
      throw Exception('Unexpected error: $e');
    }
  }

  String _getDioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.sendTimeout:
        return 'Send timeout - Request took too long to send';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout - No response received within 3 minutes';
      case DioExceptionType.connectionError:
        return 'Connection error - Please check your internet connection';
      case DioExceptionType.badResponse:
        if (e.response?.data is Map<String, dynamic>) {
          return e.response?.data['message'] ?? 'Server error occurred';
        }
        return 'Server returned error: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.unknown:
        return e.message ?? 'Unknown error occurred';
      default:
        return 'Something went wrong';
    }
  }
}