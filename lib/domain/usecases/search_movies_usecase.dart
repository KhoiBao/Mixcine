import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class SearchMoviesUseCase {
  const SearchMoviesUseCase(this._repository);

  final MovieRepository _repository;

  Future<List<Movie>> call(String query) {
    return _repository.searchMovies(query);
  }
}
