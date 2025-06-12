// background_image_controller.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../model/background_image_model.dart';
import '../services/background_service.dart';

enum BackgroundImageStatus {
  initial, // Initial state before any operation
  loading, // When data is being fetched/saved
  loaded, // When operation completes successfully
  error // When an error occurs
}

class BackgroundImageController {
  final BackgroundImageService _backgroundImageService = BackgroundImageService();

  // Value notifiers for state management
  final ValueNotifier<BackgroundImageStatus> statusNotifier =
  ValueNotifier(BackgroundImageStatus.initial);
  final ValueNotifier<String?> errorNotifier = ValueNotifier(null);
   ValueNotifier<String?> currenturl=ValueNotifier(null);

  // Notifiers for different operations
  final ValueNotifier<String?> generatedImageUrlNotifier = ValueNotifier(null);
  final ValueNotifier<List<BackgroundImageModel>> backgroundImagesNotifier =
  ValueNotifier<List<BackgroundImageModel>>([]);
  final ValueNotifier<BackgroundImageModel?> updatedImageNotifier = ValueNotifier(null);

  // Loading states for individual operations
  final ValueNotifier<bool> generateFromPromptLoadingNotifier = ValueNotifier(false);
  final ValueNotifier<bool> generateFromImageLoadingNotifier = ValueNotifier(false);
  final ValueNotifier<bool> getAllImagesLoadingNotifier = ValueNotifier(false);
  final ValueNotifier<bool> changeStatusLoadingNotifier = ValueNotifier(false);

  // Generate image from prompt
  Future<bool> generateFromPrompt({
    required String token,
    required String prompt,
  }) async {
    if (token.trim().isEmpty) {
      errorNotifier.value = "Token is required";
      return false;
    }

    if (prompt.trim().isEmpty) {
      errorNotifier.value = "Prompt is required";
      return false;
    }

    generateFromPromptLoadingNotifier.value = true;
    statusNotifier.value = BackgroundImageStatus.loading;

    try {
      final response = await _backgroundImageService.generateFromPrompt(
        token: token,
        prompt: prompt,
      );

      if (response.success && response.imageUrl != null) {
        print("Image generated successfully from prompt");
        currenturl.value=response.imageUrl;
        statusNotifier.value = BackgroundImageStatus.loaded;
        generatedImageUrlNotifier.value = response.imageUrl;
        errorNotifier.value = null;

        // Refresh the images list after successful generation
        await getAllBackgroundImages(token: token);

        return true;
      } else {
        print("Failed to generate image from prompt: ${response.message}");
        statusNotifier.value = BackgroundImageStatus.error;
        errorNotifier.value = response.message ?? "Failed to generate image from prompt";
        generatedImageUrlNotifier.value = null;
        return false;
      }
    } catch (e) {
      print("Error generating image from prompt: $e");
      statusNotifier.value = BackgroundImageStatus.error;
      errorNotifier.value = "An unexpected error occurred: ${e.toString()}";
      generatedImageUrlNotifier.value = null;
      return false;
    } finally {
      generateFromPromptLoadingNotifier.value = false;
    }
  }

  // Generate image from image file
  Future<bool> generateFromImage({
    required String token,
    required File imageFile,
  }) async {
    if (token.trim().isEmpty) {
      errorNotifier.value = "Token is required";
      return false;
    }

    if (!await imageFile.exists()) {
      errorNotifier.value = "Image file does not exist";
      return false;
    }

    generateFromImageLoadingNotifier.value = true;
    statusNotifier.value = BackgroundImageStatus.loading;

    try {
      final response = await _backgroundImageService.generateFromImage(
        token: token,
        imageFile: imageFile,
      );

      if (response.success && response.imageUrl != null) {
        print("Image generated successfully from image file");
        currenturl.value=response.imageUrl;
        statusNotifier.value = BackgroundImageStatus.loaded;
        generatedImageUrlNotifier.value = response.imageUrl;
        errorNotifier.value = null;

        // Refresh the images list after successful generation
        await getAllBackgroundImages(token: token);

        return true;
      } else {
        print("Failed to generate image from file: ${response.message}");
        statusNotifier.value = BackgroundImageStatus.error;
        errorNotifier.value = response.message ?? "Failed to generate image from file";
        generatedImageUrlNotifier.value = null;
        return false;
      }
    } catch (e) {
      print("Error generating image from file: $e");
      statusNotifier.value = BackgroundImageStatus.error;
      errorNotifier.value = "An unexpected error occurred: ${e.toString()}";
      generatedImageUrlNotifier.value = null;
      return false;
    } finally {
      generateFromImageLoadingNotifier.value = false;
    }
  }

  // Get all background images
  Future<bool> getAllBackgroundImages({required String token}) async {
    if (token.trim().isEmpty) {
      errorNotifier.value = "Token is required";
      return false;
    }

    getAllImagesLoadingNotifier.value = true;
    statusNotifier.value = BackgroundImageStatus.loading;

    try {
      final response = await _backgroundImageService.getAllBackgroundImages(
        token: token,
      );

      if (response.success) {
        print("Background images loaded successfully: ${response.images.length} images");
        statusNotifier.value = BackgroundImageStatus.loaded;
        backgroundImagesNotifier.value = response.images;
        errorNotifier.value = null;
        return true;
      } else {
        print("Failed to load background images: ${response.message}");
        statusNotifier.value = BackgroundImageStatus.error;
        errorNotifier.value = response.message ?? "Failed to load background images";
        backgroundImagesNotifier.value = [];
        return false;
      }
    } catch (e) {
      print("Error loading background images: $e");
      statusNotifier.value = BackgroundImageStatus.error;
      errorNotifier.value = "An unexpected error occurred: ${e.toString()}";
      backgroundImagesNotifier.value = [];
      return false;
    } finally {
      getAllImagesLoadingNotifier.value = false;
    }
  }

  // Change image status
  Future<bool> changeImageStatus({
    required String token,
    required String backgroundImageId,
  }) async {
    if (token.trim().isEmpty) {
      errorNotifier.value = "Token is required";
      return false;
    }

    if (backgroundImageId.trim().isEmpty) {
      errorNotifier.value = "Background image ID is required";
      return false;
    }

    changeStatusLoadingNotifier.value = true;
    statusNotifier.value = BackgroundImageStatus.loading;

    try {
      final response = await _backgroundImageService.changeImageStatus(
        token: token,
        backgroundImageId: backgroundImageId,
      );

      if (response.success && response.image != null) {
        print("Image status changed successfully $response");

        statusNotifier.value = BackgroundImageStatus.loaded;
        updatedImageNotifier.value = response.image;
        currenturl.value = updatedImageNotifier.value?.imageUrl;
        print(currenturl.value);

        errorNotifier.value = null;

        // Update the specific image in the list
        _updateImageInList(response.image!);

        return true;
      } else {
        print("Failed to change image status: ${response.message}");
        statusNotifier.value = BackgroundImageStatus.error;
        errorNotifier.value = response.message ?? "Failed to change image status";
        return false;
      }
    } catch (e) {
      print("Error changing image status: $e");
      statusNotifier.value = BackgroundImageStatus.error;
      errorNotifier.value = "An unexpected error occurred: ${e.toString()}";
      return false;
    } finally {
      changeStatusLoadingNotifier.value = false;
    }
  }

  // Helper method to update a specific image in the list
  void _updateImageInList(BackgroundImageModel updatedImage) {
    final currentImages = List<BackgroundImageModel>.from(backgroundImagesNotifier.value);
    final index = currentImages.indexWhere((image) => image.id == updatedImage.id);

    if (index != -1) {
      currentImages[index] = updatedImage;
      backgroundImagesNotifier.value = currentImages;
    }
  }

  // Helper method to get image by ID
  BackgroundImageModel? getImageById(String id) {
    try {
      return backgroundImagesNotifier.value.firstWhere((image) => image.id == id);
    } catch (e) {
      return null;
    }
  }

  // Helper method to get active images
  List<BackgroundImageModel> getActiveImages() {
    return backgroundImagesNotifier.value.where((image) => image.status).toList();
  }

  // Helper method to get inactive images
  List<BackgroundImageModel> getInactiveImages() {
    return backgroundImagesNotifier.value.where((image) => !image.status).toList();
  }

  // Clear generated image URL
  void clearGeneratedImageUrl() {
    generatedImageUrlNotifier.value = null;
  }

  // Clear error
  void clearError() {
    errorNotifier.value = null;
  }

  // Reset all data
  void reset() {
    statusNotifier.value = BackgroundImageStatus.initial;
    errorNotifier.value = null;
    generatedImageUrlNotifier.value = null;
    backgroundImagesNotifier.value = [];
    updatedImageNotifier.value = null;

    // Reset loading states
    generateFromPromptLoadingNotifier.value = false;
    generateFromImageLoadingNotifier.value = false;
    getAllImagesLoadingNotifier.value = false;
    changeStatusLoadingNotifier.value = false;
  }

  // Dispose all notifiers
  void dispose() {
    statusNotifier.dispose();
    errorNotifier.dispose();
    generatedImageUrlNotifier.dispose();
    backgroundImagesNotifier.dispose();
    updatedImageNotifier.dispose();
    generateFromPromptLoadingNotifier.dispose();
    generateFromImageLoadingNotifier.dispose();
    getAllImagesLoadingNotifier.dispose();
    changeStatusLoadingNotifier.dispose();
  }
}