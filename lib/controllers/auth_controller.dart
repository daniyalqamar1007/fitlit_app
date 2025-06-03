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
    if (email != null) {
      _instance._tempSignUpData = {
        'name': name ?? '',
        'email': email,
        'phone': phone ?? '',
        'gender': gender ?? '',
        'password': password ?? '',
        'file': imageFile,
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

  // Getter for temporary signup data
  Map<String, dynamic> get tempSignUpData => _tempSignUpData;

  Future<void> init() async {
    await _authService.loadUserSession();
  }

  // Step 1: Initial Sign Up - Only send email to get OTP
  Future<Map<String, dynamic>> initialSignUp(String email,BuildContext context) async {
    try {
      // Clear previous data but keep the email
      _tempSignUpData = {'email': email};

      final request = InitialSignupRequest(email: email,);
      final response = await _authService.initialSignup(request,context);

      if (response.success == true && response.otp != null) {
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
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}'
      };
    }
  }
  Future<bool> validate(String otp)async{
    if(otp==_verificationOtp){
      return  true;
    }
    else{
      return false;
    }
  }

  // Step 2: Complete Sign Up after OTP verification
  Future<Map<String, dynamic>> completeSignUp(
      String userOtp,
      String name,
      String email,
      String password,
      String phone,
      String gender,
      BuildContext context,
      File file) async {
    if (_tempSignUpData.isEmpty || _tempSignUpData['email'] == null) {
      return {'success': false, 'message': 'No sign up data provided'};
    }

    // Verify OTP locally (as per your requirement)
    if (_verificationOtp == null || userOtp != _verificationOtp) {
      return {'success': false, 'message': 'Invalid OTP'};
    }

    try {
      final signUpRequest = SignUpRequest(
        name: name,
        email: email,
        password: password,
        phoneNumber: phone,
        gender: gender, // Default value
        profilePhotoFile: file,
      );

      // Call the signUp method with all user data
      final response = await _authService.signUp(signUpRequest, context);

      if (response.success == true) {
        // Clear temporary data after successful signup
        _tempSignUpData = {};
        _verificationOtp = null;
        print(response);

        // Save token if available
        if (response.user?.accessToken != null) {
          await savetoken(response.user!.accessToken!);
        }


        return {
          'success': true,
          'message': response.message ?? 'Registration successful',
          'userId': response.user?.userId,
          'access_token': response.user?.accessToken,
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}'
      };
    }
  }

  // Sign In
  Future<Map<String, dynamic>> signIn(String email, String password,BuildContext context) async {
    try {
      final request = SignInRequest(
        email: email,
        password: password,

      );

      final response = await _authService.signIn(request,context);
      print('Sign in response message: ${response.message}');

      if (response.user != null && response.user!.accessToken != null) {
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
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}'
      };
    }
  }

  // Forgot Password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final request = ForgotPasswordRequest(email: email);
      final response = await _authService.forgotPassword(request);

      // Debug logs
      print(
          'Controller received: OTP=${response.otp}, Message=${response.message}, Success=${response.success}');

      if (response.otp != null) {
        _verificationOtp = response.otp;
        return {
          'success': true,
          'otp': response.otp,
          'message': response.message ?? 'OTP sent successfully',
        };
      } else {
        return {
          'success': false,
          'message': response.message ?? 'Failed to send OTP',
          'otp': null,
        };
      }
    } catch (e) {
      print('Error in forgotPassword: ${e.toString()}');
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
        'otp': null,
      };
    }
  }

  // Reset Password
  Future<Map<String, dynamic>> resetPassword(
      String email, String newPassword) async {
    try {
      final request = ResetPasswordRequest(
        email: email,
        newPassword: newPassword,
      );

      final response = await _authService.resetPassword(request);

      // Assuming reset password returns {message} on success
      if (response.success == true) {
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
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}'
      };
    }
  }

  // Update temporary signup data
  void updateSignUpData({
    String? name,
    String? phone,
    String? gender,
    String? password,
    File? imageFile,
  }) {
    if (name != null) _tempSignUpData['name'] = name;
    if (phone != null) _tempSignUpData['phone'] = phone;
    if (gender != null) _tempSignUpData['gender'] = gender;
    if (password != null) _tempSignUpData['password'] = password;
    if (imageFile != null) _tempSignUpData['file'] = imageFile;
  }

  // Verify OTP locally
  bool verifyOtp(String userOtp) {
    return userOtp == _verificationOtp;
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
  }

  void dispose() {
    _authService.dispose();
  }
}
