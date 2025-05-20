import 'package:flutter/cupertino.dart';

import '../model/outfit_model.dart';
import '../services/outfit_service.dart';
enum OutfitStatus {
  initial,   // Initial state before any operation
  loading,   // When data is being fetched/saved
  loaded,    // When operation completes successfully
  error      // When an error occurs
}
class OutfitController {
  final OutfitService _outfitService = OutfitService();

  // Value notifiers for state management
  final ValueNotifier<OutfitStatus> statusNotifier = ValueNotifier(OutfitStatus.initial);
  final ValueNotifier<String?> errorNotifier = ValueNotifier(null);
  final ValueNotifier<OutfitModel?> outfitNotifier = ValueNotifier(null);
  final ValueNotifier<String?> avatarUrlNotifier = ValueNotifier(null);

  // Save outfit to server
  Future<bool> saveOutfit({
    required String token,
    String? shirtId,
    String? pantId,
    String? shoeId,
    String? accessoryId,
    required String avatarurl,
    required DateTime date,
  }) async {
    statusNotifier.value = OutfitStatus.loading;

    try {
      final response = await _outfitService.saveOutfit(
        token: token,
        shirtId: shirtId,
        pantId: pantId,
        shoeId: shoeId,
        accessoryId: accessoryId,
        date: date,
        avatarurl: avatarurl
      );

      if (response.success) {
        statusNotifier.value = OutfitStatus.loaded;
        outfitNotifier.value = response.data;
        avatarUrlNotifier.value = response.avatar_url;
        errorNotifier.value = null;
        return true;
      } else {
        statusNotifier.value = OutfitStatus.error;
        errorNotifier.value = response.message;
        return false;
      }
    } catch (e) {
      statusNotifier.value = OutfitStatus.error;
      errorNotifier.value = "An unexpected error occurred: ${e.toString()}";
      return false;
    }
  }

  // Get outfit for specific date
  Future<String?> getOutfitByDate({
    required String token,
    required DateTime date,
  }) async {
    statusNotifier.value = OutfitStatus.loading;

    try {
      final response = await _outfitService.getOutfitByDate(
        token: token,
        date: date,
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


  void dispose() {
    statusNotifier.dispose();
    errorNotifier.dispose();
    outfitNotifier.dispose();
    avatarUrlNotifier.dispose();
  }
}