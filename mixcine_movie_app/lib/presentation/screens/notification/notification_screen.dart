import 'package:flutter/material.dart';

import '../../../data/datasources/notification_local_datasource.dart';
import '../../../data/models/notification_model.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});

  final List<NotificationModel> notifications = NotificationLocalDataSource()
      .getNotifications();

  String formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} phút";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} giờ";
    } else {
      return "${diff.inDays} ngày";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Thông báo",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];

          final bool isMovie = item.type == "movie";

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                backgroundColor: isMovie
                    ? Colors.deepPurple.shade100
                    : Colors.amber.shade100,
                child: Icon(
                  isMovie
                      ? Icons.movie_creation_outlined
                      : Icons.workspace_premium_rounded,
                  color: isMovie ? Colors.deepPurple : Colors.orange,
                ),
              ),
              title: Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  item.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              trailing: Text(
                formatTime(item.createdAt),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              onTap: () {
                if (isMovie) {
                  // Chuyển sang màn hình chi tiết phim
                } else {
                  // Chuyển sang màn hình đăng ký gói
                }
              },
            ),
          );
        },
      ),
    );
  }
}
