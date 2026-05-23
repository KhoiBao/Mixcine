class FavoriteModel {
  const FavoriteModel({required this.id, required this.movieId});

  final int id;
  final int movieId;

  Map<String, dynamic> toMap() {
    return {'id': id, 'movie_id': movieId};
  }

  factory FavoriteModel.fromMap(Map<String, dynamic> map) {
    return FavoriteModel(id: map['id'], movieId: map['movie_id']);
  }
}
