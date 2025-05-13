import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';

class AuthService {
  // ValueNotifiers for state management
  final ValueNotifier<UserModel?> currentUser = ValueNotifier(null);
  final ValueNotifier<String?> email = ValueNotifier(null);
  final ValueNotifier<String?> otp = ValueNotifier(null);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> error = ValueNotifier(null);


  final String baseUrl = 'http://localhost:3000'; // Replace with your actual base URL

  String prettyJson(Map<String, dynamic> json) {
    return const JsonEncoder.withIndent('  ').convert(json);
  }

  Future<AuthResponse> signUp(SignUpRequest request) async {
    isLoading.value = true;
    error.value = null;

    final requestData = request.toJson();


    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      isLoading.value = false;

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

        if (authResponse.user != null &&
            authResponse.user!.accessToken != null) {
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

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      isLoading.value = false;

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final authResponse = AuthResponse.fromSignInResponse(jsonResponse);

        if (authResponse.user != null &&
            authResponse.user!.accessToken != null) {
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
        error.value = errorMessage;
        return AuthResponse.error(errorMessage);
      }
    } catch (e) {
      isLoading.value = false;

      error.value = 'Network error: ${e.toString()}';
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
        final authResponse =
            AuthResponse.fromForgotPasswordResponse(jsonResponse);
        print(
            'Parsed AuthResponse: OTP=${authResponse.otp}, Success=${authResponse.success}');
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
      return "https://example.com/photo.jpg";
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

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

  Future<void> _saveUserSession(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user.toJson()));
    } catch (e) {
      print('Error saving user session: $e');
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      currentUser.value = null;
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  String _getErrorMessage(http.Response response) {
    try {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['message'] ??
          'An error occurred: ${response.statusCode}';
    } catch (e) {
      return 'An error occurred: ${response.statusCode}';
    }
  }

  void dispose() {
    currentUser.dispose();
    email.dispose();
    otp.dispose();
    isLoading.dispose();
    error.dispose();
  }
}
