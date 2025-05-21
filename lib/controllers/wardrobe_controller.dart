import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:table_calendar/table_calendar.dart';
import '../model/wardrobe_model.dart';

import '../services/wardrobe_services.dart';
enum WardrobeStatus { initial, loading, success, error }

class WardrobeController {
  final WardrobeService _wardrobeService = WardrobeService();

  // Value notifiers for different categories
  final ValueNotifier<List<WardrobeItem>> shirtsNotifier = ValueNotifier<List<WardrobeItem>>([]);
  final ValueNotifier<List<WardrobeItem>> pantsNotifier = ValueNotifier<List<WardrobeItem>>([]);
  final ValueNotifier<List<WardrobeItem>> shoesNotifier = ValueNotifier<List<WardrobeItem>>([]);
  final ValueNotifier<List<WardrobeItem>> accessoriesNotifier = ValueNotifier<List<WardrobeItem>>([]);
  final ValueNotifier<WardrobeStatus> statusNotifier = ValueNotifier<WardrobeStatus>(WardrobeStatus.initial);
  final ValueNotifier<String> errorNotifier = ValueNotifier<String>('');
  final ValueNotifier<WardrobeItem?> recentlyUploadedItem = ValueNotifier<WardrobeItem?>(null);
  final ValueNotifier<DateTime> selectedDayNotifier = ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<DateTime> focusedDayNotifier = ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<CalendarFormat> calendarFormatNotifier = ValueNotifier<CalendarFormat>(CalendarFormat.month);
  Future<void> loadWardrobeItems() async {
    try {
      statusNotifier.value = WardrobeStatus.loading;
      print("coming");
      // print(token);
      List<WardrobeItem> allItems = await _wardrobeService.getWardrobeItems();
      print("sahvshas");
      print(allItems.length);

      shirtsNotifier.value = [];
      pantsNotifier.value = [];
      shoesNotifier.value = [];
      accessoriesNotifier.value = [];
      print(allItems.length);
      for (var item in allItems) {
        print("comihg");
        _categorizeItem(item);
      }
      statusNotifier.value = WardrobeStatus.success;
    } catch (e) {
      statusNotifier.value = WardrobeStatus.error;
      errorNotifier.value = e.toString();
    }
  }
  // Future<void> loadItemsByCategory(String userId, String category, String? token) async {
  //   try {
  //     statusNotifier.value = WardrobeStatus.loading;
  //
  //     List<WardrobeItem> items = await _wardrobeService.getWardrobeItemsByCategory(userId, category, token);
  //     _updateCategoryNotifier(category, items);
  //     statusNotifier.value = WardrobeStatus.success;
  //   } catch (e) {
  //     statusNotifier.value = WardrobeStatus.error;
  //     errorNotifier.value = e.toString();
  //   }
  // }
  Future<void> uploadWardrobeItem({
    // required String userId,
    required String category,
    required String subCategory,
    required File imageFile,
    required String? token,
    required String? avatarurl
  }) async {
    try {
      print("coming");
      statusNotifier.value = WardrobeStatus.loading;

      WardrobeItem newItem = await _wardrobeService.uploadWardrobeItem(
        // userId: userId,
        category: category,
        subCategory: subCategory,
        imageFile: imageFile,
        avatarurl:avatarurl!,
        token: token,
      );

      // Add to appropriate category list
      _categorizeItem(newItem);

      // Set as recently uploaded item
      recentlyUploadedItem.value = newItem;

      statusNotifier.value = WardrobeStatus.success;
      await loadWardrobeItems();
    } catch (e) {
      statusNotifier.value = WardrobeStatus.error;
      errorNotifier.value = e.toString();
    }
  }

  // Delete a wardrobe item
  Future<void> deleteWardrobeItem(WardrobeItem item, String? token) async {
    try {
      statusNotifier.value = WardrobeStatus.loading;

      if (item.id == null) {
        throw Exception('Item ID is null');
      }

     // bool success = await _wardrobeService.deleteWardrobeItem(item.id!, token);

      // if (success) {
      //   // Remove from the appropriate category list
      //   _removeItemFromCategory(item);
      // }

      statusNotifier.value = WardrobeStatus.success;
    } catch (e) {
      statusNotifier.value = WardrobeStatus.error;
      errorNotifier.value = e.toString();
    }
  }

  // Helper method to categorize an item
  void _categorizeItem(WardrobeItem item) {
    print(item.category);
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
      case 'assessries': // Account for the typo in your UI
        accessoriesNotifier.value = [...accessoriesNotifier.value, item];
        break;
    }
  }

  // Helper method to update a specific category notifier
  void _updateCategoryNotifier(String category, List<WardrobeItem> items) {
    switch (category.toLowerCase()) {
      case 'shirt':
      case 'shirts':
        shirtsNotifier.value = items;
        break;
      case 'pant':
      case 'pants':
        pantsNotifier.value = items;
        break;
      case 'shoe':
      case 'shoes':
        shoesNotifier.value = items;
        break;
      case 'accessory':
      case 'accessories':
      case 'assessries': // Account for the typo in your UI
        accessoriesNotifier.value = items;
        break;
    }
  }

  // Helper method to remove item from category
  void _removeItemFromCategory(WardrobeItem item) {
    switch (item.category.toLowerCase()) {
      case 'shirt':
      case 'shirts':
        shirtsNotifier.value = shirtsNotifier.value.where((i) => i.id != item.id).toList();
        break;
      case 'pant':
      case 'pants':
        pantsNotifier.value = pantsNotifier.value.where((i) => i.id != item.id).toList();
        break;
      case 'shoe':
      case 'shoes':
        shoesNotifier.value = shoesNotifier.value.where((i) => i.id != item.id).toList();
        break;
      case 'accessory':
      case 'accessories':
      case 'assessries': // Account for the typo in your UI
        accessoriesNotifier.value = accessoriesNotifier.value.where((i) => i.id != item.id).toList();
        break;
    }
  }

  // Clean up resources when done
  void dispose() {
    shirtsNotifier.dispose();
    pantsNotifier.dispose();
    shoesNotifier.dispose();
    accessoriesNotifier.dispose();
    statusNotifier.dispose();
    errorNotifier.dispose();
    recentlyUploadedItem.dispose();
  }
}