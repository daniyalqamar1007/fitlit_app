import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:fitlip_app/services/profile_service.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:path/path.dart';
import '../model/profile_model.dart';
import '../view/Utils/connection.dart';

class ProfileController {
  final ProfileService _profileService = ProfileService();

  final ValueNotifier<UserProfileModel?> profileNotifier =
      ValueNotifier<UserProfileModel?>(null);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorNotifier = ValueNotifier<String?>(null);
  static ProfileController? _instance;

  factory ProfileController() {
    _instance ??= ProfileController._internal();
    return _instance!;
  }

  ProfileController._internal();

  Future<void> getUserProfile() async {
    if (isLoadingNotifier.value) return; // Prevent multiple simultaneous calls

    isLoadingNotifier.value = true;
    errorNotifier.value = null;

    try {
      // bool hasInternet =
      //     await checkInternetAndShowDialog(context as BuildContext);
      // if (!hasInternet) {
      //   return;
      // }
      final profile = await _profileService.getUserProfile();
print(profile);
      Future.microtask(() {
        profileNotifier.value = profile;
      });
    } catch (e) {
      errorNotifier.value = e.toString();
      print('Error loading profile: $e');
    } finally {
      // Use Future.microtask to avoid changing notifier during build
      Future.microtask(() {
        isLoadingNotifier.value = false;
      });
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(
      UserProfileModel profile, File? imageFile) async {
    isLoadingNotifier.value = true;
    errorNotifier.value = null;


    try {
      // bool hasInternet =
      //     await checkInternetAndShowDialog(context);
      // if (!hasInternet) {
      //   return false;
      // }

      final updatedProfile =
          await _profileService.updateUserProfile(profile, imageFile);

      profileNotifier.value = updatedProfile;
      return true;
    } catch (e) {
      errorNotifier.value = e.toString();

      return false;
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  // Clean up resources when done
  void dispose() {
    // Dispose all ValueNotifiers properly
    profileNotifier.dispose();
    isLoadingNotifier.dispose();
    errorNotifier.dispose();
    _instance = null; // Reset the singleton instance
  }
}
