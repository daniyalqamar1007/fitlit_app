// auth_service.dart
import 'package:flutter/material.dart';

class AuthService {
  final ValueNotifier<String?> email = ValueNotifier(null);
  final ValueNotifier<String?> otp = ValueNotifier(null);
  final ValueNotifier<String?> newPassword = ValueNotifier(null);
  final ValueNotifier<String?> confirmPassword = ValueNotifier(null);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> error = ValueNotifier(null);

  Future<bool> sendOtp(String email) async {
    isLoading.value = true;
    error.value = null;

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Validate email format
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        throw Exception('Invalid email format');
      }

      this.email.value = email;
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    isLoading.value = true;
    error.value = null;

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Simple validation for demo
      if (otp.length != 4) {
        throw Exception('OTP must be 4 digits');
      }

      this.otp.value = otp;
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> resetPassword(String newPassword, String confirmPassword) async {
    isLoading.value = true;
    error.value = null;

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      if (newPassword.length < 8) {
        throw Exception('Password must be at least 8 characters');
      }

      if (newPassword != confirmPassword) {
        throw Exception('Passwords do not match');
      }

      this.newPassword.value = newPassword;
      this.confirmPassword.value = confirmPassword;
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void dispose() {
    email.dispose();
    otp.dispose();
    newPassword.dispose();
    confirmPassword.dispose();
    isLoading.dispose();
    error.dispose();
  }
}
