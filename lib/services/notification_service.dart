import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/notification_model.dart';
import '../view/Utils/globle_variable/globle.dart';

class NotificationService {
  static const String baseEndpoint = '/notifications';

  static Future<NotificationResponse> fetchNotifications(String token) async {
    try {
      print("coming");
      final response = await http.get(
        Uri.parse('$baseUrl$baseEndpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        return NotificationResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<bool> markAsRead(String token, String notificationId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$baseEndpoint/$notificationId/mark-read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print(response.statusCode);
      print(response.body);
      if(response.statusCode==201){

      }

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> markAllAsRead(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$baseEndpoint/mark-all-read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}