import 'dart:math';

import '../models/notification_model.dart';
import 'mock_movie_data_source.dart';

class NotificationLocalDataSource {
  final MockMovieDataSource _movieDataSource = MockMovieDataSource();

  List<NotificationModel> getNotifications() {
    final random = Random();

    // ===== Thông báo quảng cáo gói =====
    final List<NotificationModel> notifications = [
      NotificationModel(
        title: "🎁 Nâng cấp Premium",
        message:
            "Xem phim không quảng cáo và mở khóa toàn bộ nội dung chỉ từ 49.000đ/tháng.",
        type: "subscription",
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      NotificationModel(
        title: "🔥 Ưu đãi đặc biệt",
        message: "Giảm 30% khi đăng ký gói Premium trong hôm nay.",
        type: "subscription",
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        title: "💎 Mở khóa phim VIP",
        message: "Đăng ký Premium để xem toàn bộ phim VIP và Vip Pro.",
        type: "subscription",
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    // ===== Lấy ngẫu nhiên 4 phim =====
    final movies = List.of(_movieDataSource.movies);
    movies.shuffle();

    final int count = min(4, movies.length);

    for (int i = 0; i < count; i++) {
      final movie = movies[i];

      notifications.add(
        NotificationModel(
          title: "🎬 Gợi ý dành cho bạn",
          message:
              "\"${movie.title}\" đang được nhiều người yêu thích. Xem ngay!",
          type: "movie",
          movieId: movie.id,
          createdAt: DateTime.now().subtract(
            Duration(minutes: random.nextInt(60), hours: random.nextInt(24)),
          ),
        ),
      );
    }

    // Trộn ngẫu nhiên danh sách thông báo
    notifications.shuffle();

    return notifications;
  }
}
