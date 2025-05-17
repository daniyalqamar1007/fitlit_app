// auth_model.dart
import 'dart:convert';
import 'dart:io';

class UserModel {
  final int? userId;
  final String? name;
  final String email;
  final String? phoneNumber;
  final String? profilePhoto;
  final String? gender;
  final String? accessToken;

  UserModel({
    this.userId,
    this.name,
    required this.email,
    this.phoneNumber,
    this.profilePhoto,
    this.gender,
    this.accessToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePhoto,
      'gender': gender,
      'accessToken': accessToken,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profilePhoto: json['profilePicture'],
      gender: json['gender'],
      accessToken: json['access_token'] ?? json['accessToken'],
    );
  }
}

class AuthResponse {
  final String? otp;
  final String? message;
  final UserModel? user;
  final bool? success;

  AuthResponse({this.otp, this.message, this.user, this.success});

  // For initial signup (email only)
  factory AuthResponse.fromInitialSignUpResponse(Map<String, dynamic> json) {
    return AuthResponse(
      success: true,
      message: json['message'] ?? 'OTP sent to your email',
      otp: json['otp']?.toString(),
      user: null,
    );
  }

  factory AuthResponse.fromSignInResponse(Map<String, dynamic> json) {
    return AuthResponse(
      success: true,
      message: json['message'] ?? 'Login successful',
      user: UserModel(
        userId: json['userId'],
        email: '', // Email isn't returned in the response
        accessToken: json['access_token'],
      ),
    );
  }

  factory AuthResponse.fromVerifyOtpResponse(Map<String, dynamic> json) {
    return AuthResponse(
      success: true,
      message: json['message'] ?? 'Signup successful',
      user: UserModel(
        userId: json['userId'],
        email: '', // Email isn't returned in the response
        accessToken: json['access_token'],
      ),
    );
  }

  factory AuthResponse.fromForgotPasswordResponse(Map<String, dynamic> json) {
    return AuthResponse(
      otp: json['otp']?.toString(),
      message: json['message'],
      success: json['otp'] != null,
    );
  }

  factory AuthResponse.fromResetPasswordResponse(Map<String, dynamic> json) {
    return AuthResponse(
      success: true,
      message: json['message'] ?? 'Password updated successfully',
      user: null,
    );
  }

  factory AuthResponse.error(String errorMessage) {
    return AuthResponse(
      success: false,
      message: errorMessage,
    );
  }
}

// Initial signup request (email-only)
class InitialSignUpRequest {
  final String email;

  InitialSignUpRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class SignUpRequest {
  final String name;
  final String email;
  final String password;
  final String phoneNumber;
  final String gender;
  final File? profilePhotoFile;

  SignUpRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.gender,
    this.profilePhotoFile,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'gender': gender.toLowerCase(),
      // profilePhotoFile will be handled separately in multipart request
    };
  }
}

class SignInRequest {
  final String email;
  final String password;

  SignInRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class VerifyOtpRequest {
  final String email;
  final String? password;
  final String? name;
  final String? phoneNumber;
  final String? gender;

  VerifyOtpRequest({
    required this.email,
    this.password,
    this.name,
    this.phoneNumber,
    this.gender,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
    };

    if (password != null) data['password'] = password;
    if (name != null) data['name'] = name;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    final gender = this.gender;
    if (gender != null) data['gender'] = gender.toLowerCase();

    return data;
  }
}

class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class InitialSignupRequest {
  final String email;

  InitialSignupRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class ResetPasswordRequest {
  final String email;
  final String newPassword;

  ResetPasswordRequest({
    required this.email,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'newPassword': newPassword,
    };
  }
}