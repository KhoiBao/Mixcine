import '../repositories/movie_repository.dart';

class ToggleFavoriteUseCase {
  const ToggleFavoriteUseCase(this._repository);

  final MovieRepository _repository;

  // ✓ Add userId parameter
  Future<Set<int>> call(String userId, int movieId) {
    return _repository.toggleFavorite(userId, movieId);
  }
}
