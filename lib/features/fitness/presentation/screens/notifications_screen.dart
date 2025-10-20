import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import 'main_navigation.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  List<NotificationItem> notifications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading notifications
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        notifications = [
          NotificationItem(
            id: '1',
            title: 'Workout Reminder',
            message:
                'Time for your evening workout! You\'ve been consistent for 5 days.',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            type: NotificationType.workout,
            isRead: false,
          ),
          NotificationItem(
            id: '2',
            title: 'Goal Achievement',
            message:
                'Congratulations! You\'ve reached your weekly step goal of 10,000 steps.',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            type: NotificationType.achievement,
            isRead: true,
          ),
          NotificationItem(
            id: '3',
            title: 'Streak Milestone',
            message:
                'Amazing! You\'ve maintained a 7-day workout streak. Keep it up!',
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
            type: NotificationType.streak,
            isRead: true,
          ),
          NotificationItem(
            id: '4',
            title: 'New Feature Available',
            message:
                'Check out the new workout tracking features in the latest update.',
            timestamp: DateTime.now().subtract(const Duration(days: 3)),
            type: NotificationType.update,
            isRead: false,
          ),
          NotificationItem(
            id: '5',
            title: 'Weekly Summary',
            message:
                'Your weekly fitness summary is ready. You burned 2,500 calories this week!',
            timestamp: DateTime.now().subtract(const Duration(days: 4)),
            type: NotificationType.summary,
            isRead: true,
          ),
        ];
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainNavigation()),
              );
            },
          ),
          IconButton(
            icon:
                const Icon(Icons.mark_email_read, color: AppColors.textPrimary),
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
            )
          : notifications.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    _buildNotificationStats(),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          return _buildNotificationCard(notifications[index]);
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadNotifications,
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.refresh, color: AppColors.textPrimary),
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
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationStats() {
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.notifications,
            label: 'Total',
            value: notifications.length.toString(),
            color: AppColors.primaryBlue,
          ),
          _buildStatItem(
            icon: Icons.mark_email_unread,
            label: 'Unread',
            value: unreadCount.toString(),
            color: AppColors.error,
          ),
          _buildStatItem(
            icon: Icons.check_circle,
            label: 'Read',
            value: (notifications.length - unreadCount).toString(),
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: notification.isRead
            ? AppColors.cardGradient
            : AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getNotificationColor(notification.type).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: _getNotificationColor(notification.type),
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            color: notification.isRead
                ? AppColors.textPrimary
                : AppColors.textPrimary,
            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: TextStyle(
                color: notification.isRead
                    ? AppColors.textSecondary
                    : AppColors.textPrimary.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTimestamp(notification.timestamp),
              style: TextStyle(
                color: notification.isRead
                    ? AppColors.textSecondary.withOpacity(0.7)
                    : AppColors.textPrimary.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () => _markAsRead(notification),
        onLongPress: () => _showNotificationOptions(notification),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.workout:
        return Icons.fitness_center;
      case NotificationType.achievement:
        return Icons.emoji_events;
      case NotificationType.streak:
        return Icons.local_fire_department;
      case NotificationType.update:
        return Icons.system_update;
      case NotificationType.summary:
        return Icons.analytics;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.workout:
        return AppColors.primaryBlue;
      case NotificationType.achievement:
        return AppColors.success;
      case NotificationType.streak:
        return AppColors.warning;
      case NotificationType.update:
        return AppColors.info;
      case NotificationType.summary:
        return AppColors.info;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  void _markAsRead(NotificationItem notification) {
    setState(() {
      notification.isRead = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Marked "${notification.title}" as read'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification.isRead = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
  }

  void _showNotificationOptions(NotificationItem notification) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.mark_email_read,
                  color: AppColors.primaryBlue),
              title: const Text('Mark as Read'),
              onTap: () {
                Navigator.pop(context);
                _markAsRead(notification);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _deleteNotification(notification);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteNotification(NotificationItem notification) {
    setState(() {
      notifications.removeWhere((n) => n.id == notification.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${notification.title}"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              notifications.add(notification);
            });
          },
        ),
      ),
    );
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    required this.isRead,
  });
}

enum NotificationType {
  workout,
  achievement,
  streak,
  update,
  summary,
}
