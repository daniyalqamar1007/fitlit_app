import 'package:flutter/foundation.dart';
import '../model/background_image_model.dart';

class BackgroundImageController {
  final ValueNotifier<List<BackgroundImageModel>> backgroundImagesNotifier =
      ValueNotifier<List<BackgroundImageModel>>([]);
  final ValueNotifier<String> errorNotifier = ValueNotifier<String>('');
  final ValueNotifier<bool> generateFromImageLoadingNotifier = ValueNotifier<bool>(false);

  BackgroundImageController();

  Future<bool> getAllBackgroundImages({required String token}) async {
    try {
      // Stub implementation - return empty list
      backgroundImagesNotifier.value = [];
      return true;
    } catch (e) {
      errorNotifier.value = e.toString();
      return false;
    }
  }

  Future<bool> generateFromImage({
    required String token,
    required String imageFile,
  }) async {
    try {
      generateFromImageLoadingNotifier.value = true;
      // Stub implementation
      await Future.delayed(Duration(seconds: 1));
      generateFromImageLoadingNotifier.value = false;
      return true;
    } catch (e) {
      errorNotifier.value = e.toString();
      generateFromImageLoadingNotifier.value = false;
      return false;
    }
  }

  Future<bool> generateFromPrompt({
    required String token,
    required String prompt,
  }) async {
    try {
      // Stub implementation
      await Future.delayed(Duration(seconds: 1));
      return true;
    } catch (e) {
      errorNotifier.value = e.toString();
      return false;
    }
  }

  Future<bool> changeImageStatus({
    required String token,
    required String imageId,
    required String status,
  }) async {
    try {
      // Stub implementation
      return true;
    } catch (e) {
      errorNotifier.value = e.toString();
      return false;
    }
  }

  void dispose() {
    backgroundImagesNotifier.dispose();
    errorNotifier.dispose();
    generateFromImageLoadingNotifier.dispose();
  }
}
