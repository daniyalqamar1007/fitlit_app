class NotificationModel {
  final String id;
  final int userId;
  final String type;
  final String message;
  final int senderId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.message,
    required this.senderId,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'],
      userId: json['userId'],
      type: json['type'],
      message: json['message'],
      senderId: json['sender'],
      isRead: json['isRead'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  NotificationModel copyWith({
    bool? isRead,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      type: type,
      message: message,
      senderId: senderId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class NotificationResponse {
  final List<NotificationModel> notifications;
  final int totalCount;
  final int unreadCount;

  NotificationResponse({
    required this.notifications,
    required this.totalCount,
    required this.unreadCount,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      notifications: (json['notifications'] as List)
          .map((n) => NotificationModel.fromJson(n))
          .toList(),
      totalCount: json['count'],
      unreadCount: json['unreadCount'],
    );
  }
}