// auth_service.dart
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

  String prettyJson(Map<String, dynamic> json) {
    return const JsonEncoder.withIndent('  ').convert(json);
  }

  // Initial signup with email only
  Future<AuthResponse> initialSignup(InitialSignupRequest request) async {
    isLoading.value = true;
    error.value = null;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      isLoading.value = false;
      print('Initial Signup Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        email.value = request.email;
        return AuthResponse.fromInitialSignUpResponse(jsonResponse);
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

  // Complete signup with all user details
  Future<AuthResponse> signUp(SignUpRequest request) async {
    isLoading.value = true;
    error.value = null;

    try {
      print('SignUp request details:');
      print('Name: ${request.name}');
      print('Email: ${request.email}');
      print('Gender: ${request.gender}');
      print('Phone: ${request.phoneNumber}');
      print('Has profile photo: ${request.profilePhotoFile != null}');

      final uri = Uri.parse('$baseUrl/auth/verify-otp');
      var requestMultipart = http.MultipartRequest('POST', uri);

      // Add text fields
      requestMultipart.fields['name'] = request.name;
      requestMultipart.fields['email'] = request.email;
      requestMultipart.fields['password'] = request.password;
      requestMultipart.fields['phoneNumber'] = request.phoneNumber;
      requestMultipart.fields['gender'] = request.gender.toLowerCase();

      // Add profile photo if available
      if (request.profilePhotoFile != null) {
        requestMultipart.files.add(
          http.MultipartFile(
            'file', // key expected by the backend
            request.profilePhotoFile!.openRead(),
            await request.profilePhotoFile!.length(),
            filename: request.profilePhotoFile!.path.split('/').last,
          ),
        );
      }
print(request.email);
      final streamedResponse = await requestMultipart.send();
      final response = await http.Response.fromStream(streamedResponse);

      isLoading.value = false;

      print('SignUp response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        email.value = request.email;
        return AuthResponse.fromVerifyOtpResponse(jsonResponse);
      } else {
        final errorMessage = _getErrorMessage(response);
        error.value = errorMessage;
        return AuthResponse.error(errorMessage);
      }
    } catch (e) {
      isLoading.value = false;
      error.value = 'Network error: ${e.toString()}';
      print('SignUp error: ${e.toString()}');
      return AuthResponse.error('Network error: ${e.toString()}');
    }
  }

  // Sign In API Call
  Future<AuthResponse> signIn(SignInRequest request) async {
    isLoading.value = true;
    error.value = null;
    print("Signing in...");

    try {
      print(request.email);
      print(request.password);
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );
      print('SignIn response: ${response.statusCode} - ${response.body}');

      isLoading.value = false;

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final authResponse = AuthResponse.fromSignInResponse(jsonResponse);
        await savetoken(jsonResponse['access_token'] ?? "");
        print("New token saved: $token");

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
        error.value = errorMessage;
        return AuthResponse.error(errorMessage);
      }
    } catch (e) {
      isLoading.value = false;
      error.value = 'Network error: ${e.toString()}';
      print('SignIn error: ${error.value}');
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
  }

  // Reset Password API Call
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