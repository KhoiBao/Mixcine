class MovieComment {
  const MovieComment({
    required this.id,
    required this.movieId,
    required this.userId,
    required this.author,
    required this.text,
    required this.rating,
    required this.createdAt,
  });

  final String id;
  final int movieId;
  final String userId; // User ID who created this comment
  final String author; // Display name
  final String text;
  final double rating;
  final DateTime createdAt;

  String get formattedDate {
    final now = DateTime.now();

    // 1. Ép Flutter phải hiểu con số lấy từ Database là giờ UTC (Giờ quốc tế)
    DateTime correctUtcTime = createdAt.isUtc
        ? createdAt
        : DateTime.utc(
            createdAt.year,
            createdAt.month,
            createdAt.day,
            createdAt.hour,
            createdAt.minute,
            createdAt.second,
          );

    // 2. Tự động chuyển đổi giờ UTC đó về giờ địa phương (Việt Nam)
    DateTime localCreatedAt = correctUtcTime.toLocal();

    // 3. Tính toán khoảng cách thời gian (dùng .abs() để luôn ra số dương)
    final difference = now.difference(localCreatedAt).abs();

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inHours == 0) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays == 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      // Dùng giờ đã chuyển đổi để hiển thị ngày tháng cho chuẩn
      return '${localCreatedAt.day}/${localCreatedAt.month}/${localCreatedAt.year}';
    }
  }
}
