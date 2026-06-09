class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.movieId,
    required this.userId,
    required this.authorName,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });

  final int id;
  final int movieId;
  final String userId;
  final String authorName;
  final String comment;
  final double rating;
  final String createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'movie_id': movieId,
      'user_id': userId,
      'author_name': authorName,
      'comment': comment,
      'rating': rating,
      'created_at': createdAt,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] as int,
      movieId: map['movie_id'] as int,
      userId: map['user_id'] as String,
      authorName: map['author_name'] as String,
      comment: map['comment'] as String,
      rating: (map['rating'] as num).toDouble(),
      createdAt: map['created_at'] as String,
    );
  }
}
