import '../repositories/movie_repository.dart';

class ToggleFavoriteUseCase {
  const ToggleFavoriteUseCase(this._repository);

  final MovieRepository _repository;

  Future<Set<int>> call(int movieId) {
    return _repository.toggleFavorite(movieId);
  }
}
