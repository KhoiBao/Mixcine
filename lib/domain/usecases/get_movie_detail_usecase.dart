import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class GetMovieDetailUseCase {
  const GetMovieDetailUseCase(this._repository);

  final MovieRepository _repository;

  Future<Movie> call(int movieId) {
    return _repository.getMovieDetail(movieId);
  }
}
