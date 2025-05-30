import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:table_calendar/table_calendar.dart';
import '../model/wardrobe_model.dart';

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
  String errorr="";
  Future<void> loadWardrobeItems() async {
    try {
      statusNotifier.value = WardrobeStatus.loading;

      List<WardrobeItem> allItems = await _wardrobeService.getWardrobeItems();

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

  Future<void> uploadWardrobeItem(
      {
      required String category,
      required String subCategory,
      required File imageFile,

      required String? token,
        required BuildContext context,
      required String? avatarurl}) async {
    try {
      print("coming");
      statusNotifier.value = WardrobeStatus.loading;
      bool hasInternet =
      await checkInternetAndShowDialog(context);
      if (!hasInternet) {
        return;
      }
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
