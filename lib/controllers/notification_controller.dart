import 'dart:math'; // Add this import at the top

import 'package:flutter/cupertino.dart';
import '../model/notification_model.dart';
import '../services/notification_service.dart';
import '../services/socket_service.dart';

class NotificationController {
  final ValueNotifier<List<NotificationModel>> notificationsNotifier = ValueNotifier([]);
  final ValueNotifier<Set<String>> processingNotificationsNotifier = ValueNotifier({});
  final ValueNotifier<int> unreadCountNotifier = ValueNotifier(0);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  final ValueNotifier<String?> errorNotifier = ValueNotifier(null);
  final ValueNotifier<bool> isSocketConnectedNotifier = ValueNotifier(false);

  final SocketService _socketService = SocketService();
  bool _isDisposed = false;
  bool _socketEventsSetup = false;

  NotificationController() {
    _setupSocketConnection();
  }

  Future<void> loadNotifications(String token) async {
    if (isLoadingNotifier.value) return;

    isLoadingNotifier.value = true;
    errorNotifier.value = null;

    try {
      final response = await NotificationService.fetchNotifications(token);

      if (!_isDisposed) {
        notificationsNotifier.value = response.notifications;
        unreadCountNotifier.value = response.unreadCount;
      }

      if (!_socketEventsSetup) {
        _setupSocketEventHandlers();
      }
    } catch (e) {
      if (!_isDisposed) {
        errorNotifier.value = e.toString();
      }
    } finally {
      if (!_isDisposed) {
        isLoadingNotifier.value = false;
      }
    }
  }

  void _setupSocketConnection() {
    if (_isDisposed) return;

    _socketService.connectionState.addListener(() {
      if (!_isDisposed) {
        isSocketConnectedNotifier.value = _socketService.connectionState.value;
        if (_socketService.connectionState.value && !_socketEventsSetup) {
          _setupSocketEventHandlers();
        }
      }
    });

    isSocketConnectedNotifier.value = _socketService.isConnected;
  }

  void _setupSocketEventHandlers() {
    if (_isDisposed || _socketEventsSetup) return;

    _socketService.off('new_notification');
    _socketService.off('notification_read');
    _socketService.off('all_notifications_read');
    _socketService.off('notification_deleted');

    _socketService.on('new_notification', (data) {
      print('[Socket] new_notification received: $data'); // Add this
      if (data != null && !_isDisposed) {
        try {
          final newNotification = NotificationModel.fromJson(data);
          _handleNewNotification(newNotification);
        } catch (e) {
          print('Error parsing new notification: $e');
        }
      }
    });

    _socketService.on('notification_read', (data) {
      if (data != null && !_isDisposed) {
        _handleNotificationRead(data);
      }
    });

    _socketService.on('all_notifications_read', (data) {
      if (!_isDisposed) {
        _handleAllNotificationsRead(data);
      }
    });

    _socketService.on('notification_deleted', (data) {
      if (data != null && !_isDisposed) {
        _handleNotificationDeleted(data);
      }
    });

    _socketEventsSetup = true;
  }

  void _handleNewNotification(NotificationModel notification) {
    if (_isDisposed) return;

    final existingIndex = notificationsNotifier.value.indexWhere((n) => n.id == notification.id);
    if (existingIndex != -1) return;

    final updated = [notification, ...notificationsNotifier.value];
    notificationsNotifier.value = updated;

    if (!notification.isRead) {
      unreadCountNotifier.value = unreadCountNotifier.value + 1;
    }
  }

  void _handleNotificationRead(dynamic data) {
    if (_isDisposed) return;

    final notificationId = data is Map ? data['notificationId'] ?? data['id'] : data;
    if (notificationId == null) return;

    final updated = [...notificationsNotifier.value];
    final index = updated.indexWhere((n) => n.id == notificationId);

    if (index != -1 && !updated[index].isRead) {
      updated[index] = updated[index].copyWith(isRead: true);
      notificationsNotifier.value = updated;
      unreadCountNotifier.value = max(0, unreadCountNotifier.value - 1); // Fixed: using max from dart:math
    }
  }

  void _handleAllNotificationsRead(dynamic data) {
    if (_isDisposed) return;

    notificationsNotifier.value = notificationsNotifier.value
        .map((n) => n.copyWith(isRead: true))
        .toList();
    unreadCountNotifier.value = 0;
  }

  void _handleNotificationDeleted(dynamic data) {
    if (_isDisposed) return;

    final notificationId = data is Map ? data['notificationId'] ?? data['id'] : data;
    if (notificationId == null) return;

    final updated = [...notificationsNotifier.value];
    final index = updated.indexWhere((n) => n.id == notificationId);

    if (index != -1) {
      final wasUnread = !updated[index].isRead;
      updated.removeAt(index);
      notificationsNotifier.value = updated;

      if (wasUnread) {
        unreadCountNotifier.value = max(0, unreadCountNotifier.value - 1); // Fixed: using max from dart:math
      }
    }
  }

  Future<bool> markNotificationAsRead(String token, String notificationId) async {
    if (_isDisposed) return false;

    if (processingNotificationsNotifier.value.contains(notificationId)) {
      return false;
    }

    final processingSet = {...processingNotificationsNotifier.value, notificationId};
    processingNotificationsNotifier.value = processingSet;

    try {
      final success = await NotificationService.markAsRead(token, notificationId);

      if (success) {
        final notification = notificationsNotifier.value.firstWhere(
              (n) => n.id == notificationId,
          orElse: () => throw StateError('Notification not found'),
        );

        if (!notification.isRead) {
          _handleNotificationRead({'notificationId': notificationId});
        }
      }

      return success;
    } catch (e) {
      return false;
    } finally {
      final updatedProcessingSet = {...processingNotificationsNotifier.value};
      updatedProcessingSet.remove(notificationId);
      processingNotificationsNotifier.value = updatedProcessingSet;
    }
  }

  Future<bool> markAllNotificationsAsRead(String token) async {
    if (_isDisposed) return false;

    try {
      final success = await NotificationService.markAllAsRead(token);
      if (success) {
        _handleAllNotificationsRead(null);
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  // Future<bool> deleteNotification(String token, String notificationId) async {
  //   if (_isDisposed) return false;
  //
  //   try {
  //     final success = await NotificationService.deleteNotification(token, notificationId);
  //     if (success) {
  //       _handleNotificationDeleted({'notificationId': notificationId});
  //     }
  //     return success;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  Future<void> refreshNotifications(String token) async {
    await loadNotifications(token);
  }

  int get unreadCount => unreadCountNotifier.value;
  List<NotificationModel> get notifications => notificationsNotifier.value;
  bool get isSocketConnected => _socketService.isConnected;

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    if (_socketEventsSetup) {
      _socketService.off('new_notification');
      _socketService.off('notification_read');
      _socketService.off('all_notifications_read');
      _socketService.off('notification_deleted');
    }

    notificationsNotifier.dispose();
    processingNotificationsNotifier.dispose();
    unreadCountNotifier.dispose();
    isLoadingNotifier.dispose();
    errorNotifier.dispose();
    isSocketConnectedNotifier.dispose();
  }
}