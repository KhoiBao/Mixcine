import '../entities/paginated_movies.dart';
import '../repositories/movie_repository.dart';

class GetDiscoverMoviesUseCase {
  const GetDiscoverMoviesUseCase(this._repository);

  final MovieRepository _repository;

  Future<PaginatedMovies> call({int page = 1}) {
    return _repository.getDiscoverMovies(page: page);
  }
}
