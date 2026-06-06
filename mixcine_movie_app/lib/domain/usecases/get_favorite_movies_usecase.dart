import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class GetFavoriteMoviesUseCase {
  const GetFavoriteMoviesUseCase(this._repository);

  final MovieRepository _repository;

  // ✓ Add userId parameter
  Future<List<Movie>> call(String userId) {
    return _repository.getFavoriteMovies(userId);
  }
}
