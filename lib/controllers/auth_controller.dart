// auth_controller.dart
import 'dart:io';
import 'package:fitlip_app/view/Utils/globle_variable/globle.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';
import '../services/auth_services.dart';

class AuthController {
  static final AuthController _instance = AuthController._internal();

  factory AuthController({
    String? name,
    String? email,
    String? phone,
    String? gender,
    String? password,
    File? imageFile,
  }) {
    if (name != null && email != null) {
      _instance._tempSignUpData = {
        'name': name,
        'email': email,
        'phone': phone ?? '',
        'gender': gender ?? '',
        'password': password ?? '',
        'imageFile': imageFile,
      };
    }
    return _instance;
  }

  AuthController._internal();

  final AuthService _authService = AuthService();
  Map<String, dynamic> _tempSignUpData = {};
  String? _verificationOtp;

  // Getters for ValueNotifiers
  ValueNotifier<UserModel?> get currentUser => _authService.currentUser;
  ValueNotifier<String?> get email => _authService.email;
  ValueNotifier<bool> get isLoading => _authService.isLoading;
  ValueNotifier<String?> get error => _authService.error;

  Future<void> init() async {
    await _authService.loadUserSession();
  }

  // Sign Up - Updated for new response format
  Future<Map<String, dynamic>> signUp() async {
    if (_tempSignUpData.isEmpty) {
      return {'success': false, 'message': 'No sign up data provided'};
    }

    try {
      final request = SignUpRequest(
        name: _tempSignUpData['name'],
        email: _tempSignUpData['email'],
        password: _tempSignUpData['password'],
        phoneNumber: _tempSignUpData['phone'],
        gender: _tempSignUpData['gender'],
      );

      final response = await _authService.signUp(request);

      // Handle the new response format {otp, message}
      if (response.otp != null) {
        _verificationOtp = response.otp;
        return {
          'success': true,
          'otp': response.otp,
          'message': response.message ?? 'OTP sent successfully'
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Failed to send OTP'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: ${e.toString()}'};
    }
  }

  // Verify OTP for Sign Up - Updated for new response format
  Future<Map<String, dynamic>> verifySignUpOtp(String userOtp) async {
    try {
      final request = VerifyOtpRequest(
        email: _tempSignUpData['email'],
        otp: userOtp,
        password: _tempSignUpData['password'],
        name: _tempSignUpData['name'],
      );

      final response = await _authService.verifyOtp(request);

      // Assuming verify endpoint returns {message, user} on success
      if (response.user != null) {
        _tempSignUpData = {};
        _verificationOtp = null;
      savetoken(response.user?.accessToken??"");
      gettoken();
        return {
          'success': true,
          'message': response.message ?? 'Verification successful',
          'userId': response.user?.userId,
          'token': response.user?.accessToken,
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Verification failed'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: ${e.toString()}'};
    }
  }

  // Sign In - Updated for new response format
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final request = SignInRequest(
        email: email,
        password: password,
      );

      final response = await _authService.signIn(request);

      if (response.user != null) {
        savetoken(response.user?.accessToken??"");
        gettoken();
        print("saved tomen is $token");
        return {
          'success': true,
          'message': response.message ?? 'Login successful',
          'userId': response.user?.userId,
          'token': response.user?.accessToken,
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Login failed'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: ${e.toString()}'};
    }
  }

  // Forgot Password - Updated for new response format
// Forgot Password - Fixed for API response format
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final request = ForgotPasswordRequest(email: email);
      final response = await _authService.forgotPassword(request);

      // Debug logs
      print('Controller received: OTP=${response.otp}, Message=${response.message}, Success=${response.success}');

      // Important: If we have an OTP, consider it a success regardless of the success flag
      final bool isSuccess = response.otp != null;

      return {
        'success': isSuccess,
        'otp': response.otp,
        'message': response.message ?? 'No message received',
      };
    } catch (e) {
      print('Error in forgotPassword: ${e.toString()}');
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
        'otp': null,
      };
    }
  }// Reset Password - Updated for new response format
  Future<Map<String, dynamic>> resetPassword(String email, String newPassword) async {
    try {
      final request = ResetPasswordRequest(
        email: email,
        newPassword: newPassword,
      );

      final response = await _authService.resetPassword(request);

      // Assuming reset password returns {message} on success
      if (response.message != null) {
        _verificationOtp = null;
        return {
          'success': true,
          'message': response.message ?? 'Password reset successful'
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Password reset failed'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: ${e.toString()}'};
    }
  }

  // Verify OTP for Password Reset
  Future<bool> verifyResetOtp(String userOtp) async {
    return userOtp == _verificationOtp;
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  void dispose() {
    _authService.dispose();
  }
}