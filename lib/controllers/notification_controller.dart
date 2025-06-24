// import 'package:flutter/material.dart';
//
// import '../model/notification_model.dart';
// import '../services/notification_service.dart';
//
//
// class NotificationController {
//   final ValueNotifier<List<NotificationModel>> notificationsNotifier =
//   ValueNotifier([]);
//
//   final ValueNotifier<Set<String>> processingNotificationsNotifier = ValueNotifier({});
//   final ValueNotifier<int> unreadCountNotifier = ValueNotifier(0);
//   final ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
//   final ValueNotifier<String?> errorNotifier = ValueNotifier(null);
//   final ValueNotifier<Set<String>> currentlyMarkingNotifier = ValueNotifier({});
//
//   Future<void> loadNotifications(String token) async {
//     isLoadingNotifier.value = true;
//     errorNotifier.value = null;
//
//     try {
//       final response = await NotificationService.fetchNotifications(token);
//       notificationsNotifier.value = response.notifications;
//       unreadCountNotifier.value = response.unreadCount;
//     } catch (e) {
//       errorNotifier.value = e.toString();
//     } finally {
//       isLoadingNotifier.value = false;
//     }
//   }
//   Future<bool> markNotificationAsRead(String token, String notificationId) async {
//     try {
//       // Add to processing set
//       processingNotificationsNotifier.value = {
//         ...processingNotificationsNotifier.value,
//         notificationId
//       };
//
//       final success = await NotificationService.markAsRead(token, notificationId);
//       if (success) {
//         // Update local state immediately
//         final updatedNotifications = [...notificationsNotifier.value];
//         final index = updatedNotifications.indexWhere((n) => n.id == notificationId);
//         if (index != -1) {
//           updatedNotifications[index] = updatedNotifications[index].copyWith(
//             isRead: true,
//           );
//           notificationsNotifier.value = updatedNotifications;
//           unreadCountNotifier.value = unreadCountNotifier.value - 1;
//         }
//         return true;
//       }
//       return false;
//     } catch (e) {
//       print('Error marking notification as read: $e');
//       return false;
//     } finally {
//       // Remove from processing set
//       processingNotificationsNotifier.value = {
//         ...processingNotificationsNotifier.value
//       }..remove(notificationId);
//     }
//   }
//
//   Future<void> markAllNotificationsAsRead(String token) async {
//     try {
//       final success = await NotificationService.markAllAsRead(token);
//       if (success) {
//         notificationsNotifier.value = notificationsNotifier.value
//             .map((n) => n.copyWith(isRead: true))
//             .toList();
//         unreadCountNotifier.value = 0;
//       }
//     } catch (e) {
//       print('Error marking all notifications as read: $e');
//     }
//   }
//
//   void dispose() {
//     notificationsNotifier.dispose();
//     unreadCountNotifier.dispose();
//     isLoadingNotifier.dispose();
//     errorNotifier.dispose();
//   }
// }
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../model/notification_model.dart';
import '../services/notification_service.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../model/notification_model.dart';
import '../services/notification_service.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../model/notification_model.dart';
import '../services/notification_service.dart';

class NotificationController {
  final ValueNotifier<List<NotificationModel>> notificationsNotifier = ValueNotifier([]);
  final ValueNotifier<Set<String>> processingNotificationsNotifier = ValueNotifier({});
  final ValueNotifier<int> unreadCountNotifier = ValueNotifier(0);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  final ValueNotifier<String?> errorNotifier = ValueNotifier(null);
  final ValueNotifier<Set<String>> currentlyMarkingNotifier = ValueNotifier({});

  IO.Socket? _socket;
  final ValueNotifier<bool> isSocketConnectedNotifier = ValueNotifier(false);
  String? _currentToken;
  bool _isDisposed = false;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;

  Future<void> connectSocket(String token) async {
    _currentToken = token;
    _reconnectAttempts = 0;

    try {
      await _disconnectSocket();

      // Updated socket configuration with better options
      _socket = IO.io(
        'https://nnl056zh-3099.inc1.devtunnels.ms',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(_maxReconnectAttempts)
            .setReconnectionDelay(2000)
            .setReconnectionDelayMax(10000)
            .setRandomizationFactor(0.5)
            .setTimeout(20000) // 20 second timeout
            .setPath('/socket.io/') // Default Socket.IO path
            .setQuery({'token': token})
            .setExtraHeaders({'Authorization': 'Bearer $token'}) // Add auth header
            .build(),
      );

      _setupSocketListeners();
      _socket!.connect();

    } catch (e) {
      print('Socket connection error: $e');
      isSocketConnectedNotifier.value = false;
      _scheduleReconnect();
    }
  }

  void _setupSocketListeners() {
    if (_socket == null) return;

    _socket!.onConnect((_) {
      print('Socket.IO connected successfully');
      isSocketConnectedNotifier.value = true;
      _reconnectAttempts = 0;
      _cancelReconnectTimer();

      // Join the notifications namespace
      _socket!.emit('join', {'userId': _extractUserIdFromToken(_currentToken)});
    });

    _socket!.onDisconnect((reason) {
      print('Socket.IO disconnected: $reason');
      isSocketConnectedNotifier.value = false;

      // Only attempt reconnection if not manually disconnected
      if (reason != 'io client disconnect' && !_isDisposed) {
        _scheduleReconnect();
      }
    });

    _socket!.onConnectError((error) {
      print('Socket.IO connection error: $error');
      isSocketConnectedNotifier.value = false;
      _scheduleReconnect();
    });

    _socket!.onError((error) {
      print('Socket.IO error: $error');
      isSocketConnectedNotifier.value = false;
    });

    // Reconnect event
    _socket!.on('reconnect', (data) {
      print('Socket.IO reconnected after ${data} attempts');
      isSocketConnectedNotifier.value = true;
      _reconnectAttempts = 0;
    });

    _socket!.on('reconnecting', (attemptNumber) {
      print('Socket.IO attempting to reconnect (attempt $attemptNumber)');
    });

    _socket!.on('reconnect_error', (error) {
      print('Socket.IO reconnection error: $error');
    });

    _socket!.on('reconnect_failed', (_) {
      print('Socket.IO failed to reconnect after maximum attempts');
      isSocketConnectedNotifier.value = false;
    });

    // Notification event listeners
    _socket!.on('new_notification', _handleNewNotification);
    _socket!.on('notification_read', _handleNotificationRead);
    _socket!.on('all_notifications_read', _handleAllNotificationsRead);

    // Connection confirmation
    _socket!.on('connect_error', (error) {
      print('Connection error details: $error');
    });
  }

  void _scheduleReconnect() {
    if (_isDisposed || _reconnectAttempts >= _maxReconnectAttempts) return;

    _cancelReconnectTimer();

    final delay = Duration(seconds: (2 * (_reconnectAttempts + 1)).clamp(2, 30));
    print('Scheduling reconnect in ${delay.inSeconds} seconds (attempt ${_reconnectAttempts + 1})');

    _reconnectTimer = Timer(delay, () {
      if (!_isDisposed && _currentToken != null) {
        _reconnectAttempts++;
        connectSocket(_currentToken!);
      }
    });
  }

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  String? _extractUserIdFromToken(String? token) {
    // Add your JWT token parsing logic here
    // This is a placeholder - implement according to your token structure
    return null;
  }

  void _handleNewNotification(dynamic data) {
    try {
      print('Received new notification: $data');

      final notificationData = data is Map ? data['notification'] : data;
      if (notificationData == null) {
        print('Invalid notification data received');
        return;
      }

      final newNotification = NotificationModel.fromJson(notificationData);
      final updatedNotifications = [newNotification, ...notificationsNotifier.value];
      notificationsNotifier.value = updatedNotifications;

      if (!newNotification.isRead) {
        unreadCountNotifier.value = unreadCountNotifier.value + 1;
      }
    } catch (e) {
      print('Error handling new notification: $e');
    }
  }

  void _handleNotificationRead(dynamic data) {
    try {
      print('Notification marked as read: $data');

      final notificationId = data is Map ? data['notificationId'] : data;
      if (notificationId == null) return;

      final updatedNotifications = [...notificationsNotifier.value];
      final index = updatedNotifications.indexWhere((n) => n.id == notificationId);

      if (index != -1 && !updatedNotifications[index].isRead) {
        updatedNotifications[index] = updatedNotifications[index].copyWith(isRead: true);
        notificationsNotifier.value = updatedNotifications;
        unreadCountNotifier.value = (unreadCountNotifier.value - 1).clamp(0, double.infinity).toInt();
      }
    } catch (e) {
      print('Error handling notification read: $e');
    }
  }

  void _handleAllNotificationsRead(dynamic data) {
    try {
      print('All notifications marked as read');

      notificationsNotifier.value = notificationsNotifier.value
          .map((n) => n.copyWith(isRead: true))
          .toList();
      unreadCountNotifier.value = 0;
    } catch (e) {
      print('Error handling all notifications read: $e');
    }
  }

  Future<void> _disconnectSocket() async {
    _cancelReconnectTimer();

    if (_socket != null) {
      try {
        _socket!.disconnect();
        _socket!.dispose();
      } catch (e) {
        print('Error disconnecting socket: $e');
      }
      _socket = null;
    }
    isSocketConnectedNotifier.value = false;
  }

  Future<void> loadNotifications(String token) async {
    if (isLoadingNotifier.value) return; // Prevent multiple simultaneous loads

    isLoadingNotifier.value = true;
    errorNotifier.value = null;

    try {
      final response = await NotificationService.fetchNotifications(token);
      notificationsNotifier.value = response.notifications;
      unreadCountNotifier.value = response.unreadCount;

      // Connect socket after successfully loading notifications
      await connectSocket(token);
    } catch (e) {
      errorNotifier.value = e.toString();
      print('Error loading notifications: $e');
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  Future<bool> markNotificationAsRead(String token, String notificationId) async {
    if (processingNotificationsNotifier.value.contains(notificationId)) {
      return false; // Already processing
    }

    try {
      processingNotificationsNotifier.value = {
        ...processingNotificationsNotifier.value,
        notificationId
      };

      final success = await NotificationService.markAsRead(token, notificationId);

      if (success) {
        // Update local state immediately for better UX
        _handleNotificationRead({'notificationId': notificationId});
      }

      return success;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    } finally {
      processingNotificationsNotifier.value = {
        ...processingNotificationsNotifier.value
      }..remove(notificationId);
    }
  }

  Future<bool> markAllNotificationsAsRead(String token) async {
    try {
      final success = await NotificationService.markAllAsRead(token);
      if (success) {
        // Update local state immediately
        _handleAllNotificationsRead(null);
      }
      return success;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }

  // Getters
  bool get isSocketConnected => isSocketConnectedNotifier.value;
  List<NotificationModel> get notifications => notificationsNotifier.value;
  int get unreadCount => unreadCountNotifier.value;
  bool get isLoading => isLoadingNotifier.value;
  String? get error => errorNotifier.value;

  // Manual reconnection method
  Future<void> reconnectWebSocket() async {
    if (_currentToken != null && !_isDisposed) {
      print('Manual reconnection requested');
      await connectSocket(_currentToken!);
    }
  }

  // Test connection method
  Future<bool> testConnection() async {
    if (_socket == null) return false;

    try {
      _socket!.emit('ping');
      return true;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  void dispose() {
    print('Disposing NotificationController');
    _isDisposed = true;
    _disconnectSocket();
    _cancelReconnectTimer();

    // Dispose all notifiers
    notificationsNotifier.dispose();
    unreadCountNotifier.dispose();
    isLoadingNotifier.dispose();
    errorNotifier.dispose();
    isSocketConnectedNotifier.dispose();
    processingNotificationsNotifier.dispose();
    currentlyMarkingNotifier.dispose();
  }
}
