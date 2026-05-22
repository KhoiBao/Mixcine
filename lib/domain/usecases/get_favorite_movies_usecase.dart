import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class GetFavoriteMoviesUseCase {
  const GetFavoriteMoviesUseCase(this._repository);

  final MovieRepository _repository;

  Future<List<Movie>> call() {
    return _repository.getFavoriteMovies();
  }
}
