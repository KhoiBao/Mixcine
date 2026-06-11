class NotificationModel {
  final String title;
  final String message;
  final String type; // subscription | movie
  final int? movieId;
  final DateTime createdAt;

  const NotificationModel({
    required this.title,
    required this.message,
    required this.type,
    this.movieId,
    required this.createdAt,
  });
}
