class WatchHistory {
  const WatchHistory({
    required this.id,
    required this.movieId,
    required this.progress,
  });

  final int id;
  final int movieId;
  final int progress; // Tiến độ xem (ví dụ: tính bằng phút)

  /// Hàm hỗ trợ tính toán phần trăm đã xem dựa trên tổng thời lượng phim.
  /// Rất hữu ích khi hiển thị thanh Progress Bar trên UI.
  double getProgressPercentage(int totalDurationMinutes) {
    if (totalDurationMinutes <= 0) return 0.0;

    final percentage = progress / totalDurationMinutes;
    // Đảm bảo giá trị trả về nằm trong khoảng 0.0 đến 1.0
    return percentage > 1.0 ? 1.0 : percentage;
  }
}
