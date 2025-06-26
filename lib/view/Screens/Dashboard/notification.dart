  // import 'package:fitlip_app/view/Utils/responsivness.dart';
  // import 'package:fitlip_app/view/Widgets/custom_message.dart';
  // import 'package:flutter/material.dart';
  // import 'package:google_fonts/google_fonts.dart';
  // import 'package:cached_network_image/cached_network_image.dart';
  // import 'package:loading_animation_widget/loading_animation_widget.dart';
  //
  // import '../../../controllers/notification_controller.dart';
  // import '../../../model/notification_model.dart';
  // import '../../Utils/Colors.dart';
  // import '../../Utils/globle_variable/globle.dart';
  //
  // class NotificationScreen extends StatefulWidget {
  //   const NotificationScreen({Key? key}) : super(key: key);
  //
  //   @override
  //   State<NotificationScreen> createState() => _NotificationScreenState();
  // }
  //
  // class _NotificationScreenState extends State<NotificationScreen> {
  //   final NotificationController _controller = NotificationController();
  //
  //   @override
  //   void initState() {
  //     super.initState();
  //     _loadNotifications();
  //   }
  //
  //   Future<void> _loadNotifications() async {
  //     await _controller.loadNotifications(token!);
  //   }
  //
  //   Future<void> _markAsRead(String notificationId) async {
  //     await _controller.markNotificationAsRead(token!, notificationId);
  //   }
  //
  //   Future<void> _markAllAsRead() async {
  //     await _controller.markAllNotificationsAsRead(token!);
  //   }
  //
  //   @override
  //   void dispose() {
  //     _controller.dispose();
  //     super.dispose();
  //   }
  //
  //   @override
  //   Widget build(BuildContext context) {
  //     return Scaffold(
  //       backgroundColor: Colors.white,
  //       appBar: AppBar(
  //         backgroundColor: Colors.white,
  //         elevation: 0,
  //         title: ValueListenableBuilder<int>(
  //           valueListenable: _controller.unreadCountNotifier,
  //           builder: (context, unreadCount, _) {
  //             return Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Text('Notifications',
  //                     style: GoogleFonts.poppins(
  //                       color: appcolor,
  //                       fontSize: Responsive.fontSize(24),
  //                     )),
  //                 if (unreadCount > 0) ...[
  //                   SizedBox(width: 8),
  //                   CircleAvatar(
  //                     radius: 10,
  //                     backgroundColor: Colors.red,
  //                     child: Text(
  //                       unreadCount.toString(),
  //                       style: TextStyle(fontSize: 12, color: Colors.white),
  //                     ),
  //                   ),
  //                 ],
  //               ],
  //             );
  //           },
  //         ),
  //         actions: [
  //           ValueListenableBuilder<int>(
  //             valueListenable: _controller.unreadCountNotifier,
  //             builder: (context, unreadCount, _) {
  //               if (unreadCount == 0) return SizedBox();
  //               return Padding(
  //                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //                 child: TextButton(
  //                   onPressed: _markAllAsRead,
  //                   child: Text(
  //                     'Mark all',
  //                     style: GoogleFonts.poppins(
  //                       color: appcolor,
  //                       fontSize: Responsive.fontSize(14),
  //                     ),
  //                   ),
  //                 ),
  //               );
  //             },
  //           ),
  //         ],
  //       ),
  //       body: Padding(
  //         padding: EdgeInsets.symmetric(horizontal: Responsive.width(10)),
  //         child: ValueListenableBuilder<bool>(
  //           valueListenable: _controller.isLoadingNotifier,
  //           builder: (context, isLoading, _) {
  //             if (isLoading) {
  //               return Center(
  //                 child: LoadingAnimationWidget.fourRotatingDots(
  //                     color: appcolor, size: 20),
  //               );
  //             }
  //
  //             return ValueListenableBuilder<String?>(
  //               valueListenable: _controller.errorNotifier,
  //               builder: (context, error, _) {
  //                 if (error != null) {
  //                   return Center(
  //                     child: Column(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         Icon(Icons.error_outline, color: Colors.red, size: 48),
  //                         SizedBox(height: 16),
  //                         Text(
  //                           'Failed to load notifications',
  //                           style: GoogleFonts.poppins(
  //                             fontSize: Responsive.fontSize(16),
  //                             color: Colors.grey[700],
  //                           ),
  //                         ),
  //                         SizedBox(height: 16),
  //                         ElevatedButton(
  //                           onPressed: _loadNotifications,
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: appcolor,
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(10),
  //                             ),
  //                           ),
  //                           child: Text(
  //                             'Try Again',
  //                             style: GoogleFonts.poppins(
  //                               color: Colors.white,
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   );
  //                 }
  //
  //                 return ValueListenableBuilder<List<NotificationModel>>(
  //                   valueListenable: _controller.notificationsNotifier,
  //                   builder: (context, notifications, _) {
  //                     if (notifications.isEmpty) {
  //                       return Center(
  //                         child: Column(
  //                           mainAxisAlignment: MainAxisAlignment.center,
  //                           children: [
  //                             Icon(
  //                               Icons.notifications_none,
  //                               size: 48,
  //                               color: Colors.grey[400],
  //                             ),
  //                             SizedBox(height: 16),
  //                             Text(
  //                               'No notifications yet',
  //                               style: GoogleFonts.poppins(
  //                                 fontSize: Responsive.fontSize(16),
  //                                 color: Colors.grey[600],
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       );
  //                     }
  //
  //                     return ListView.separated(
  //                       itemCount: notifications.length,
  //                       separatorBuilder: (context, index) => SizedBox(height: 8),
  //                       itemBuilder: (context, index) {
  //                         final notification = notifications[index];
  //                         return _buildNotificationItem(notification);
  //                       },
  //                     );
  //                   },
  //                 );
  //               },
  //             );
  //           },
  //         ),
  //       ),
  //     );
  //   }
  //
  //   Widget _buildNotificationItem(NotificationModel notification) {
  //     return ValueListenableBuilder<Set<String>>(
  //       valueListenable: _controller.processingNotificationsNotifier,
  //       builder: (context, processingSet, _) {
  //         final isProcessing = processingSet.contains(notification.id);
  //
  //         return InkWell(
  //           onTap: () async {
  //             if (!notification.isRead && !isProcessing) {
  //               final success = await _controller.markNotificationAsRead(token!, notification.id);
  //               if (!success && mounted) {
  //          showAppSnackBar(
  //            context,
  //                      'Failed to mark notification as read',
  //
  //
  //                 );
  //               }
  //             }
  //           },
  //           borderRadius: BorderRadius.circular(12),
  //           child: Container(
  //             padding: EdgeInsets.all(Responsive.width(16)),
  //             margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  //             decoration: BoxDecoration(
  //               color: notification.isRead
  //                   ? Colors.grey[50]  // Lighter color for read notifications
  //                   : appcolor.withOpacity(0.1),  // Highlight color for unread
  //               borderRadius: BorderRadius.circular(12),
  //               border: Border.all(
  //                 color: notification.isRead
  //                     ? Colors.grey[300]!
  //                     : appcolor.withOpacity(0.3),
  //                 width: 1.5,
  //               ),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.grey.withOpacity(0.05),
  //                   spreadRadius: 1,
  //                   blurRadius: 3,
  //                   offset: Offset(0, 1),
  //                 ),
  //               ],
  //             ),
  //             child: Row(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Stack(
  //                   children: [
  //                     Container(
  //                       width: Responsive.width(40),
  //                       height: Responsive.width(40),
  //                       decoration: BoxDecoration(
  //                         shape: BoxShape.circle,
  //                         color: notification.isRead
  //                             ? Colors.grey[200]
  //                             : appcolor.withOpacity(0.2),
  //                       ),
  //                       child: isProcessing
  //                           ? LoadingAnimationWidget.threeRotatingDots(
  //                         color: appcolor,
  //                         size: Responsive.width(15),
  //                       )
  //                           : Icon(
  //                         _getNotificationIcon(notification.type),
  //                         color: notification.isRead
  //                             ? Colors.grey[600]
  //                             : appcolor,
  //                         size: Responsive.width(20),
  //                       ),
  //                     ),
  //                     if (!notification.isRead && !isProcessing)
  //                       Positioned(
  //                         right: 0,
  //                         top: 0,
  //                         child: Container(
  //                           width: Responsive.width(10),
  //                           height: Responsive.width(10),
  //                           decoration: BoxDecoration(
  //                             color: appcolor,
  //                             shape: BoxShape.circle,
  //                             border: Border.all(color: Colors.white, width: 2),
  //                           ),
  //                         ),
  //                       ),
  //                   ],
  //                 ),
  //                 SizedBox(width: Responsive.width(12)),
  //                 Expanded(
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         notification.message,
  //                         style: GoogleFonts.poppins(
  //                           fontSize: Responsive.fontSize(14),
  //                           fontWeight: notification.isRead
  //                               ? FontWeight.normal
  //                               : FontWeight.w600,
  //                           color: notification.isRead
  //                               ? Colors.grey[700]
  //                               : Colors.black87,
  //                         ),
  //                       ),
  //                       SizedBox(height: Responsive.height(4)),
  //                       Row(
  //                         children: [
  //                           Icon(
  //                             Icons.access_time,
  //                             size: Responsive.width(12),
  //                             color: Colors.grey[500],
  //                           ),
  //                           SizedBox(width: Responsive.width(4)),
  //                           Text(
  //                             _formatDate(notification.createdAt),
  //                             style: GoogleFonts.poppins(
  //                               fontSize: Responsive.fontSize(12),
  //                               color: Colors.grey[600],
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 if (isProcessing)
  //                   Padding(
  //                     padding: EdgeInsets.only(left: 8),
  //                     child: SizedBox(
  //                       width: 16,
  //                       height: 16,
  //                       child: CircularProgressIndicator(
  //                         strokeWidth: 2,
  //                         color: appcolor,
  //                       ),
  //                     ),
  //                   ),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     );
  //   }
  //   IconData _getNotificationIcon(String type) {
  //     switch (type) {
  //       case 'follow':
  //         return Icons.person_add;
  //       case 'unfollow':
  //         return Icons.person;
  //       case 'like':
  //         return Icons.favorite;
  //       case 'comment':
  //         return Icons.comment;
  //       case 'mention':
  //         return Icons.alternate_email;
  //       default:
  //         return Icons.notifications;
  //     }
  //   }
  //
  //   String _formatDate(DateTime date) {
  //     final now = DateTime.now();
  //     final difference = now.difference(date);
  //
  //     if (difference.inDays > 30) {
  //       return '${(difference.inDays / 30).floor()}mo ago';
  //     } else if (difference.inDays > 0) {
  //       return '${difference.inDays}d ago';
  //     } else if (difference.inHours > 0) {
  //       return '${difference.inHours}h ago';
  //     } else if (difference.inMinutes > 0) {
  //       return '${difference.inMinutes}m ago';
  //     } else {
  //       return 'Just now';
  //     }
  //   }
  // }
  import 'dart:async';

import 'package:fitlip_app/view/Utils/responsivness.dart';
  import 'package:fitlip_app/view/Widgets/custom_message.dart';
  import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:cached_network_image/cached_network_image.dart';
  import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:socket_io_client/socket_io_client.dart';

  import '../../../controllers/notification_controller.dart';
  import '../../../model/notification_model.dart';
  import '../../../services/socket_service.dart';
import '../../Utils/Colors.dart';
  import '../../Utils/globle_variable/globle.dart';
  import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:loading_animation_widget/loading_animation_widget.dart';


  class NotificationScreen extends StatefulWidget {
    const NotificationScreen({Key? key}) : super(key: key);

    @override
    State<NotificationScreen> createState() => _NotificationScreenState();
  }

  class _NotificationScreenState extends State<NotificationScreen> {
    final NotificationController _controller = NotificationController();
    late final ValueNotifier<bool> _socketConnection = SocketService().connectionState;

    @override
    void initState() {
      super.initState();
      _initializeScreen();
    }

    Future<void> _initializeScreen() async {
      await _controller.loadNotifications(token!);
      _setupSocketConnectionListener();
    }

    void _setupSocketConnectionListener() {
      _socketConnection.addListener(() {
        if (mounted && _socketConnection.value && token != null) {
          print('Socket reconnected - syncing notifications');
          _controller.loadNotifications(token!);
        }
      });
    }

    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: _buildBody(),
      );
    }

    AppBar _buildAppBar() {
      return AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        title: ValueListenableBuilder<int>(
          valueListenable: _controller.unreadCountNotifier,
          builder: (context, unreadCount, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Notifications', style: GoogleFonts.poppins(
                    color: appcolor,
                    fontSize: Responsive.fontSize(20),
                    fontWeight: FontWeight.w600
                )),
                if (unreadCount > 0) ...[
                  SizedBox(width: 8),
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: TextStyle(
                        fontSize: unreadCount > 99 ? 8 : 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        actions: [
          _buildConnectionStatus(),
          _buildMarkAllButton(),
        ],
      );
    }

    Widget _buildConnectionStatus() {
      return ValueListenableBuilder<bool>(
        valueListenable: _controller.isSocketConnectedNotifier,
        builder: (context, isConnected, _) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isConnected ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  isConnected ? 'Live' : 'Offline',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.fontSize(10),
                    color: isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    Widget _buildMarkAllButton() {
      return ValueListenableBuilder<int>(
        valueListenable: _controller.unreadCountNotifier,
        builder: (context, unreadCount, _) {
          if (unreadCount == 0) return SizedBox();
          return TextButton(
            onPressed: () async {
              final success = await _controller.markAllNotificationsAsRead(token!);
              if (!success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to mark all as read'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'Mark all',
              style: GoogleFonts.poppins(
                color: appcolor,
                fontSize: Responsive.fontSize(14),
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
      );
    }

    Widget _buildBody() {
      return Column(
        children: [
          _buildConnectionWarning(),
          Expanded(child: _buildNotificationList()),
        ],
      );
    }

    Widget _buildConnectionWarning() {
      return ValueListenableBuilder<bool>(
        valueListenable: _controller.isSocketConnectedNotifier,
        builder: (context, isConnected, _) {
          return isConnected ? SizedBox() : Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.width(16),
              vertical: Responsive.height(8),
            ),
            color: Colors.orange.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.wifi_off, color: Colors.orange, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Real-time updates unavailable. Notifications may be delayed.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.orange[800],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    // Try to reconnect socket and reload notifications
                    final socketService = SocketService();
                    await socketService.forceReconnect();
                    await _controller.loadNotifications(token!);
                  },
                  child: Text(
                    'Retry',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: appcolor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    Widget _buildNotificationList() {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.width(10)),
        child: ValueListenableBuilder<bool>(
          valueListenable: _controller.isLoadingNotifier,
          builder: (context, isLoading, _) {
            if (isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadingAnimationWidget.fourRotatingDots(
                      color: appcolor,
                      size: 32,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading notifications...',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            return ValueListenableBuilder<String?>(
              valueListenable: _controller.errorNotifier,
              builder: (context, error, _) {
                if (error != null) return _buildErrorState();

                return ValueListenableBuilder<List<NotificationModel>>(
                  valueListenable: _controller.notificationsNotifier,
                  builder: (context, notifications, _) {
                    if (notifications.isEmpty) return _buildEmptyState();

                    return RefreshIndicator(
                      onRefresh: () => _controller.loadNotifications(token!),
                      color: appcolor,
                      child: ListView.separated(
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) => SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          return _buildNotificationItem(notifications[index]);
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      );
    }

    Widget _buildNotificationItem(NotificationModel notification) {
      return ValueListenableBuilder<Set<String>>(
        valueListenable: _controller.processingNotificationsNotifier,
        builder: (context, processingSet, _) {
          final isProcessing = processingSet.contains(notification.id);

          return InkWell(
            onTap: () async {
              if (!notification.isRead! && !isProcessing) {
                final success = await _controller.markNotificationAsRead(
                  token!,
                  notification.id!,
                );
                if (!success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to mark as read'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: notification.isRead!
                    ? Colors.grey[50]
                    : appcolor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: notification.isRead!
                      ? Colors.grey[300]!
                      : appcolor.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNotificationIcon(notification, isProcessing),
                  SizedBox(width: 12),
                  Expanded(child: _buildNotificationContent(notification)),
                ],
              ),
            ),
          );
        },
      );
    }

    Widget _buildNotificationIcon(NotificationModel notification, bool isProcessing) {
      return Stack(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: notification.isRead!
                ? Colors.grey[200]
                : appcolor.withOpacity(0.2),
            child: isProcessing
                ? LoadingAnimationWidget.threeRotatingDots(
              color: appcolor,
              size: 15,
            )
                : Icon(
              _getNotificationIcon(notification.type!),
              color: notification.isRead! ? Colors.grey : appcolor,
              size: 20,
            ),
          ),
          if (!notification.isRead! && !isProcessing)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: appcolor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      );
    }

    Widget _buildNotificationContent(NotificationModel notification) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification.message!,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: notification.isRead!
                  ? FontWeight.normal
                  : FontWeight.w600,
              color: notification.isRead!
                  ? Colors.grey[700]
                  : Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
              SizedBox(width: 4),
              Text(
                _formatDate(notification.createdAt!),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      );
    }

    Widget _buildErrorState() {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              'Failed to load notifications',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please check your connection and try again',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _controller.loadNotifications(token!),
              style: ElevatedButton.styleFrom(
                backgroundColor: appcolor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Try Again',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildEmptyState() {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You\'ll see notifications here when you have them',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    IconData _getNotificationIcon(String type) {
      switch (type.toLowerCase()) {
        case 'follow': return Icons.person_add;
        case 'unfollow': return Icons.person_remove;
        case 'like': return Icons.favorite;
        case 'comment': return Icons.comment;
        case 'mention': return Icons.alternate_email;
        case 'message': return Icons.message;
        case 'system': return Icons.info;
        default: return Icons.notifications;
      }
    }

    String _formatDate(DateTime date) {
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays > 365) {
        return '${(diff.inDays / 365).floor()}y ago';
      } else if (diff.inDays > 30) {
        return '${(diff.inDays / 30).floor()}mo ago';
      } else if (diff.inDays > 0) {
        return '${diff.inDays}d ago';
      } else if (diff.inHours > 0) {
        return '${diff.inHours}h ago';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    }
  }
