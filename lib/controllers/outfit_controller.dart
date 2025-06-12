//outfit_controller.dart
import 'package:flutter/cupertino.dart';
import '../model/outfit_model.dart';
import '../services/outfit_service.dart';

enum OutfitStatus {
  initial, // Initial state before any operation
  loading, // When data is being fetched/saved
  loaded, // When operation completes successfully
  error // When an error occurs
}

class OutfitController {
  final OutfitService _outfitService = OutfitService();

  // Value notifiers for state management
  final ValueNotifier<OutfitStatus> statusNotifier =
  ValueNotifier(OutfitStatus.initial);
  final ValueNotifier<String?> errorNotifier = ValueNotifier(null);
  final ValueNotifier<OutfitModel?> outfitNotifier = ValueNotifier(null);
  final ValueNotifier<String?> avatarUrlNotifier = ValueNotifier(null);

  // New notifier for avatar dates
  final ValueNotifier<List<AvatarData>> avatarDatesNotifier =
  ValueNotifier<List<AvatarData>>([]);

  // Save outfit to server
  Future<bool> saveOutfit({
    required String token,
    String? shirtId,
    String? pantId,
    String? shoeId,
    String? backgroundimageurl,
    String? accessoryId,
    required String avatarurl,
    required DateTime date,
    String? message, // Optional message parameter
  }) async {
    statusNotifier.value = OutfitStatus.loading;

    try {
      final response = await _outfitService.saveOutfit(
        token: token,
        shirtId: shirtId,
        pantId: pantId,
        shoeId: shoeId,
        accessoryId: accessoryId,
        backgroundimageurl:backgroundimageurl,
        date: date,
        avatarurl: avatarurl,
        message: message, // Pass message to service
      );

      if (response.success) {
        print("going");
        statusNotifier.value = OutfitStatus.loaded;
        outfitNotifier.value = response.data;
        avatarUrlNotifier.value = response.avatar_url;
        errorNotifier.value = null;

        // Refresh avatar dates after saving
        await loadAllAvatarDates(token: token);

        return true;
      } else {
        print("short");
        statusNotifier.value = OutfitStatus.error;
        errorNotifier.value = response.message;
        return false;
      }
    } catch (e) {
      print("new");
      statusNotifier.value = OutfitStatus.error;
      errorNotifier.value = "An unexpected error occurred: ${e.toString()}";
      return false;
    }
  }

  // Get outfit for specific date
  Future<String?> getOutfitByDate({
    required String token,
    required DateTime date,
    required int id
  }) async {
    statusNotifier.value = OutfitStatus.loading;

    try {
      final response = await _outfitService.getOutfitByDate(
          token: token,
          date: date,
          id: id
      );

      if (response != null) {
        statusNotifier.value = OutfitStatus.loaded;
        avatarUrlNotifier.value = response;
        errorNotifier.value = null;
        return response;
      } else {
        statusNotifier.value = OutfitStatus.error;
        errorNotifier.value = "Failed to fetch avatar";
        avatarUrlNotifier.value = null;
        return null;
      }
    } catch (e) {
      statusNotifier.value = OutfitStatus.error;
      errorNotifier.value = "An unexpected error occurred: ${e.toString()}";
      avatarUrlNotifier.value = null;
      return null;
    }
  }

  // New method to load all avatar dates
  Future<void> loadAllAvatarDates({required String token}) async {
    try {
      final response = await _outfitService.getAllAvatarsByDate(token: token);

      if (response.success) {
        avatarDatesNotifier.value = response.data;
        print("Loaded ${response.data.length} avatar dates");
      } else {
        print("Failed to load avatar dates");
        avatarDatesNotifier.value = [];
      }
    } catch (e) {
      print("Error loading avatar dates: ${e.toString()}");
      avatarDatesNotifier.value = [];
    }
  }

  // Helper method to check if a date has an avatar
  bool hasAvatarForDate(DateTime date) {
    return avatarDatesNotifier.value.any((avatarData) {
      return avatarData.dateTime.year == date.year &&
          avatarData.dateTime.month == date.month &&
          avatarData.dateTime.day == date.day;
    });
  }

  // Helper method to get message for a specific date
  String? getMessageForDate(DateTime date) {
    try {
      final avatarData = avatarDatesNotifier.value.firstWhere(
            (avatarData) {
          return avatarData.dateTime.year == date.year &&
              avatarData.dateTime.month == date.month &&
              avatarData.dateTime.day == date.day;
        },
      );
      return avatarData.storedMessage;
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    statusNotifier.dispose();
    errorNotifier.dispose();
    outfitNotifier.dispose();
    avatarUrlNotifier.dispose();
    avatarDatesNotifier.dispose();
  }
}