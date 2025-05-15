
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';
import '../view/Utils/globle_variable/globle.dart';
class AuthService {
  // ValueNotifiers for state management
  final ValueNotifier<UserModel?> currentUser = ValueNotifier(null);
  final ValueNotifier<String?> email = ValueNotifier(null);
  final ValueNotifier<String?> otp = ValueNotifier(null);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> error = ValueNotifier(null);
  final http.Client _client = http.Client();
  // Base URL for API

  final String baseUrl = 'http://147.93.47.17:3099';

  // Replace with your actual base URL
  String prettyJson(Map<String, dynamic> json) {
    return const JsonEncoder.withIndent('  ').convert(json);
  }
  // Sign Up API Call
  Future<AuthResponse> signUp(SignUpRequest request) async {
    isLoading.value = true;
    error.value = null;

    final requestData = request.toJson();
    print('📤 SIGN UP REQUEST:');
    print('• Endpoint: $baseUrl/auth/signup');
    print('• Data: ${prettyJson(requestData)}');
// zainyshorts@gmail.com
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      isLoading.value = false;

      print('📥 SIGN UP RESPONSE:');
      print('• Status: ${response.statusCode}');
      print(response.body);
      // print('• Body: ${prettyJsonResponse(response)}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        email.value = request.email;
        return AuthResponse.fromSignUpResponse(jsonResponse);
      } else {
        final errorMessage = _getErrorMessage(response);
        error.value = errorMessage;
        return AuthResponse.error(errorMessage);
      }
    } catch (e) {
      isLoading.value = false;
      error.value = 'Network error: ${e.toString()}';
      print('❌ SIGN UP ERROR: $e');
      return AuthResponse.error('Network error: ${e.toString()}');
    }
  }

  // Verify OTP API Call
  Future<AuthResponse> verifyOtp(VerifyOtpRequest request) async {
    isLoading.value = true;
    error.value = null;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      isLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final authResponse = AuthResponse.fromVerifyOtpResponse(jsonResponse);

        if (authResponse.user != null && authResponse.user!.accessToken != null) {
          await _saveUserSession(authResponse.user!);
          currentUser.value = authResponse.user;
        }

        return authResponse;
      } else {
        final errorMessage = _getErrorMessage(response);
        error.value = errorMessage;
        return AuthResponse.error(errorMessage);
      }
    } catch (e) {
      isLoading.value = false;
      error.value = 'Network error: ${e.toString()}';
      return AuthResponse.error('Network error: ${e.toString()}');
    }
  }

  // Sign In API Call
  Future<AuthResponse> signIn(SignInRequest request) async {
    isLoading.value = true;
    error.value = null;
    print("loading");
   // var url=http://213.210.37.77:3099';
    // final String correctedUrl = url.replaceAll(
    //     'localhost', '192.168.18.114'); // Replace with your actual IP
    // print("coming");

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );
      print(' all data is ${response.body} ${response.statusCode}');

      isLoading.value = false;

      if (response.statusCode == 200) {

        final jsonResponse = jsonDecode(response.body);
        final authResponse = AuthResponse.fromSignInResponse(jsonResponse);
        await savetoken(jsonResponse['access_token']??"");
        print("new tokwn is ");
        print(token);

        if (authResponse.user != null && authResponse.user!.accessToken != null) {
          // Store user email since it's not returned in response
          final updatedUser = UserModel(
            userId: authResponse.user!.userId,
            email: request.email,
            accessToken: authResponse.user!.accessToken,
          );

          await _saveUserSession(updatedUser);
          currentUser.value = updatedUser;
        }

        return authResponse;
      } else {
        final errorMessage = _getErrorMessage(response);
        print(response);
        error.value = errorMessage;
        return AuthResponse.error(errorMessage);
      }
    } catch (e) {
      isLoading.value = false;

      error.value = 'Network error: ${e.toString()}';
      print(error.value);
      return AuthResponse.error('Network error: ${e.toString()}');
    }
  }

  // Forgot Password API Call
  Future<AuthResponse> forgotPassword(ForgotPasswordRequest request) async {
    isLoading.value = true;
    error.value = null;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-Password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      isLoading.value = false;
      print('Forgot Password Response: ${response.body}');

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        email.value = request.email;
        final authResponse = AuthResponse.fromForgotPasswordResponse(jsonResponse);
        print('Parsed AuthResponse: OTP=${authResponse.otp}, Success=${authResponse.success}');
        return authResponse;
      } else {
        final errorMessage = _getErrorMessage(response);
        error.value = errorMessage;
        return AuthResponse.error(errorMessage);
      }
    } catch (e) {
      isLoading.value = false;
      error.value = 'Network error: ${e.toString()}';
      return AuthResponse.error('Network error: ${e.toString()}');
    }
  }// Reset Password API Call
  Future<AuthResponse> resetPassword(ResetPasswordRequest request) async {
    isLoading.value = true;
    error.value = null;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      isLoading.value = false;

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return AuthResponse.fromResetPasswordResponse(jsonResponse);
      } else {
        final errorMessage = _getErrorMessage(response);
        error.value = errorMessage;
        return AuthResponse.error(errorMessage);
      }
    } catch (e) {
      isLoading.value = false;
      error.value = 'Network error: ${e.toString()}';
      return AuthResponse.error('Network error: ${e.toString()}');
    }
  }

  // Upload Profile Image to a server and get URL
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      // This is a placeholder for image upload functionality
      // You'll need to implement this based on your server requirements
      // Typically involves creating a multipart request

      // Example:
      // var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
      // request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      // var response = await request.send();
      // if (response.statusCode == 200) {
      //   final respStr = await response.stream.bytesToString();
      //   final jsonResponse = jsonDecode(respStr);
      //   return jsonResponse['url'];
      // }

      // For now, return null or a dummy URL
      return "https://example.com/photo.jpg";
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Load user session from local storage
  Future<void> loadUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');

      if (userJson != null) {
        final userData = jsonDecode(userJson);
        currentUser.value = UserModel.fromJson(userData);
      }
    } catch (e) {
      print('Error loading user session: $e');
    }
  }

  // Save user session to local storage
  Future<void> _saveUserSession(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user.toJson()));
    } catch (e) {
      print('Error saving user session: $e');
    }
  }

  // Clear user session on logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      currentUser.value = null;
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // Helper to extract error message from response
  String _getErrorMessage(http.Response response) {
    try {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['error'] ?? 'An error occurred: ${response.statusCode}';
    } catch (e) {
      return 'An error occurred: ${response.statusCode}';
    }
  }

  // Dispose resources
  void dispose() {
    currentUser.dispose();
    email.dispose();
    otp.dispose();
    isLoading.dispose();
    error.dispose();
  }
}