class WatchHistoryModel {
  const WatchHistoryModel({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.progress,
    required this.updatedAt,
  });

  final int id;
  final String userId;
  final int movieId;
  final int progress;
  final String updatedAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'movie_id': movieId,
      'progress': progress,
      'updated_at': updatedAt,
    };
  }

  factory WatchHistoryModel.fromMap(Map<String, dynamic> map) {
    return WatchHistoryModel(
      id: map['id'] as int,
      userId: map['user_id'] as String,
      movieId: map['movie_id'] as int,
      progress: map['progress'] as int,
      updatedAt: map['updated_at'] as String,
    );
  }
}
