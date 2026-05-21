class WatchHistoryModel {
  const WatchHistoryModel({
    required this.id,
    required this.movieId,
    required this.progress,
  });

  final int id;
  final int movieId;
  final int progress;

  Map<String, dynamic> toMap() {
    return {'id': id, 'movie_id': movieId, 'progress': progress};
  }

  factory WatchHistoryModel.fromMap(Map<String, dynamic> map) {
    return WatchHistoryModel(
      id: map['id'],
      movieId: map['movie_id'],
      progress: map['progress'],
    );
  }
}
