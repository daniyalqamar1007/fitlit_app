import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:table_calendar/table_calendar.dart';
import '../model/wardrobe_model.dart';

import '../services/upload_isolate_service.dart';
import '../services/wardrobe_services.dart';
import '../view/Utils/connection.dart';

enum WardrobeStatus { initial, loading, success, error }

class WardrobeController {
  final WardrobeService _wardrobeService = WardrobeService();

  // Value notifiers for different categories
  final ValueNotifier<List<WardrobeItem>> shirtsNotifier =
      ValueNotifier<List<WardrobeItem>>([]);
  final ValueNotifier<List<WardrobeItem>> pantsNotifier =
      ValueNotifier<List<WardrobeItem>>([]);
  final ValueNotifier<List<WardrobeItem>> shoesNotifier =
      ValueNotifier<List<WardrobeItem>>([]);
  final ValueNotifier<List<WardrobeItem>> accessoriesNotifier =
      ValueNotifier<List<WardrobeItem>>([]);
  final ValueNotifier<WardrobeStatus> statusNotifier =
      ValueNotifier<WardrobeStatus>(WardrobeStatus.initial);
  final ValueNotifier<String> errorNotifier = ValueNotifier<String>('');
  final ValueNotifier<WardrobeItem?> recentlyUploadedItem =
      ValueNotifier<WardrobeItem?>(null);
  final ValueNotifier<DateTime> selectedDayNotifier =
      ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<DateTime> focusedDayNotifier =
      ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<CalendarFormat> calendarFormatNotifier =
      ValueNotifier<CalendarFormat>(CalendarFormat.month);

  final Map<String, StreamSubscription> _activeUploads = {};
  final ValueNotifier<Map<String, UploadProgress>> uploadProgressNotifier =
  ValueNotifier({});
  String errorr="";
  Future<void> loadWardrobeItems() async {
    try {
      statusNotifier.value = WardrobeStatus.loading;
      List<WardrobeItem> allItems = await _wardrobeService.getWardrobeItems();
      shirtsNotifier.value = [];
      pantsNotifier.value = [];
      shoesNotifier.value = [];
      accessoriesNotifier.value = [];
      print(allItems.length);
      for (var item in allItems) {

        _categorizeItem(item);
      }
      statusNotifier.value = WardrobeStatus.success;
    } catch (e) {
      statusNotifier.value = WardrobeStatus.error;
      errorNotifier.value = e.toString();
    }
  }

  Future<void> uploadWardrobeItem(
      {
      required String category,
      required String subCategory,
      required File imageFile,

      required String? token,
        required BuildContext context,
      required String? avatarurl}) async
  {
    try {

      statusNotifier.value = WardrobeStatus.loading;

      WardrobeItem newItem = await _wardrobeService.uploadWardrobeItem(
        category: category,
        subCategory: subCategory,
        imageFile: imageFile,
        avatarurl: avatarurl!,
        token: token,
      );
      print("responce is");
      print(newItem);
      _categorizeItem(newItem);


      recentlyUploadedItem.value = newItem;

      statusNotifier.value = WardrobeStatus.success;
      await loadWardrobeItems();
    } catch (e) {
      statusNotifier.value = WardrobeStatus.error;
      errorNotifier.value = e.toString();
    }
  }
  Future<String> uploadWardrobeItemInBackground({
    required String category,
    required String subCategory,
    required String? avatarurl,
    required File imageFile,
    required String? token,
  }) async {
    // Validation
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is required');
    }
    if (avatarurl == null || avatarurl.isEmpty) {
      throw Exception('Avatar URL is required');
    }

    // Generate unique upload ID
    final uploadId = 'upload_${DateTime.now().millisecondsSinceEpoch}';
print("coming");
    // Add to progress tracking
    _updateUploadProgress(uploadId, UploadProgress(
      uploadId: uploadId,
      category: category,
      subCategory: subCategory,
      status: UploadStatus.started,
      message: 'Preparing upload...',
      progress: 0.0,
    ));

    try {
      // Start upload in isolate
      await UploadIsolateService.startUpload(
        category: category,
        subCategory: subCategory,
        imageFile: imageFile,
        avatarUrl: avatarurl,
        token: token,
        uploadId: uploadId,
      );

      // Listen to upload progress
      final subscription = UploadIsolateService.uploadStream
          .where((message) => message.uploadId == uploadId)
          .listen((message) {
        _handleUploadMessage(message);
      });

      _activeUploads[uploadId] = subscription;
      return uploadId;

    } catch (e) {
      print("coming");
      print(e.toString());
      _updateUploadProgress(uploadId, UploadProgress(
        uploadId: uploadId,
        category: category,
        subCategory: subCategory,
        status: UploadStatus.error,
        message: 'Failed to start upload: ${e.toString()}',
        error: e.toString(),
      ));
      rethrow;
    }
  }
  void _handleUploadMessage(UploadMessage message) {
    final currentProgress = uploadProgressNotifier.value[message.uploadId];
    if (currentProgress == null) return;

    final updatedProgress = UploadProgress(
      uploadId: message.uploadId,
      category: currentProgress.category,
      subCategory: currentProgress.subCategory,
      status: message.status,
      message: message.message,
      progress: message.progress,
      error: message.error,
    );

    _updateUploadProgress(message.uploadId, updatedProgress);

    // Handle completion
    if (message.status == UploadStatus.completed && message.data != null) {
      _handleUploadComplete(message.uploadId, message.data!, currentProgress);
    } else if (message.status == UploadStatus.error) {
      _handleUploadError(message.uploadId, message.error ?? 'Unknown error');
    }
  }
  // Delete a wardrobe item
  Future<void> deleteWardrobeItem(WardrobeItem item, String? token) async {
    try {
      statusNotifier.value = WardrobeStatus.loading;

      if (item.id == null) {
        throw Exception('Item ID is null');
      }


      statusNotifier.value = WardrobeStatus.success;
    } catch (e) {
      statusNotifier.value = WardrobeStatus.error;
      errorNotifier.value = e.toString();
    }
  }
  void _handleUploadComplete(
      String uploadId,
      Map<String, dynamic> data,
      UploadProgress progress,
      ) {
    try {
      final wardrobeItem = WardrobeItem.fromJson(data);

      // Add to appropriate category
      switch (progress.category.toLowerCase()) {
        case 'shirts':
          final currentShirts = List<WardrobeItem>.from(shirtsNotifier.value);
          currentShirts.add(wardrobeItem);
          shirtsNotifier.value = currentShirts;
          break;
        case 'pants':
          final currentPants = List<WardrobeItem>.from(pantsNotifier.value);
          currentPants.add(wardrobeItem);
          pantsNotifier.value = currentPants;
          break;
        case 'shoes':
          final currentShoes = List<WardrobeItem>.from(shoesNotifier.value);
          currentShoes.add(wardrobeItem);
          shoesNotifier.value = currentShoes;
          break;
        case 'accessories':
          final currentAccessories = List<WardrobeItem>.from(accessoriesNotifier.value);
          currentAccessories.add(wardrobeItem);
          accessoriesNotifier.value = currentAccessories;
          break;
      }

      // Clean up
      _cleanupUpload(uploadId);

    } catch (e) {
      print(e.toString());
      _handleUploadError(uploadId, 'Failed to process upload result: ${e.toString()}');
    }
  }
  void _handleUploadError(String uploadId, String error) {
    errorNotifier.value = error;
    _cleanupUpload(uploadId);
  }

  // Update upload progress
  void _updateUploadProgress(String uploadId, UploadProgress progress) {
    final currentProgress = Map<String, UploadProgress>.from(uploadProgressNotifier.value);
    currentProgress[uploadId] = progress;
    uploadProgressNotifier.value = currentProgress;
  }

  // Clean up completed upload
  void _cleanupUpload(String uploadId) {
    _activeUploads[uploadId]?.cancel();
    _activeUploads.remove(uploadId);

    // Remove from progress tracking after a delay
    Timer(Duration(seconds: 3), () {
      final currentProgress = Map<String, UploadProgress>.from(uploadProgressNotifier.value);
      currentProgress.remove(uploadId);
      uploadProgressNotifier.value = currentProgress;
    });
  }

  // Get active uploads
  List<UploadProgress> get activeUploads {
    return uploadProgressNotifier.value.values.toList();
  }
  bool get hasActiveUploads {
    return uploadProgressNotifier.value.isNotEmpty;
  }

  // Cancel an upload
  void cancelUpload(String uploadId) {
    _activeUploads[uploadId]?.cancel();
    _activeUploads.remove(uploadId);

    final currentProgress = Map<String, UploadProgress>.from(uploadProgressNotifier.value);
    currentProgress.remove(uploadId);
    uploadProgressNotifier.value = currentProgress;
  }
  // Helper method to categorize an item
  void _categorizeItem(WardrobeItem item) {

    switch (item.category.toLowerCase()) {
      case 'shirt':
      case 'shirts':
        shirtsNotifier.value = [...shirtsNotifier.value, item];
        break;
      case 'pant':
      case 'pants':
        pantsNotifier.value = [...pantsNotifier.value, item];
        break;
      case 'shoe':
      case 'shoes':
        shoesNotifier.value = [...shoesNotifier.value, item];
        break;
      case 'accessory':
      case 'accessories':
      case 'assessories': // Account for the typo in your UI
        accessoriesNotifier.value = [...accessoriesNotifier.value, item];
        break;
    }
  }

  @override
  void dispose() {
    // Cancel all active uploads
    for (final subscription in _activeUploads.values) {
      subscription.cancel();
    }
    _activeUploads.clear();

    // Dispose notifiers
    shirtsNotifier.dispose();
    pantsNotifier.dispose();
    shoesNotifier.dispose();
    accessoriesNotifier.dispose();
    errorNotifier.dispose();
    uploadProgressNotifier.dispose();

  }

}
class UploadProgress {
  final String uploadId;
  final String category;
  bool hasShownNotification = false; // Add this field
  DateTime startTime = DateTime.now();
  final String subCategory;
  final UploadStatus status;
  final String message;
  final double? progress;
  final String? error;

  UploadProgress({
    required this.uploadId,
    required this.category,
    required this.subCategory,
    required this.status,
    required this.message,
    this.progress,
    this.error,
  });

  bool get isCompleted => status == UploadStatus.completed;
  bool get isError => status == UploadStatus.error;
  bool get isInProgress => status == UploadStatus.uploading || status == UploadStatus.processing;
}