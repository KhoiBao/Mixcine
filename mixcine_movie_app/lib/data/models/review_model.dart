class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.movieId,
    required this.comment,
    required this.rating,
  });

  final int id;
  final int movieId;
  final String comment;
  final double rating;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'movie_id': movieId,
      'comment': comment,
      'rating': rating,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'],
      movieId: map['movie_id'],
      comment: map['comment'],
      rating: (map['rating'] as num).toDouble(),
    );
  }
}
