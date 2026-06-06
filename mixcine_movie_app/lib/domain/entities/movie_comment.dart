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
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.month}/${createdAt.day}/${createdAt.year}';
    }
  }
}
