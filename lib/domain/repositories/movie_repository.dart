import '../entities/movie.dart';
import '../entities/movie_section.dart';
import '../entities/paginated_movies.dart';

abstract class MovieRepository {
  Future<List<MovieSection>> getHomeSections();
  Future<PaginatedMovies> getDiscoverMovies({int page = 1});
  Future<List<Movie>> searchMovies(String query);
  Future<Movie> getMovieDetail(int movieId);
  Future<Set<int>> getFavoriteIds();
  Future<Set<int>> toggleFavorite(int movieId);
  Future<List<Movie>> getFavoriteMovies();
}
