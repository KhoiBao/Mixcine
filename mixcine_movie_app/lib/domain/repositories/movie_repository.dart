import '../entities/movie.dart';
import '../entities/movie_section.dart';
import '../entities/paginated_movies.dart';

abstract class MovieRepository {
  Future<List<MovieSection>> getHomeSections();
  Future<PaginatedMovies> getDiscoverMovies({int page = 1});
  Future<List<Movie>> searchMovies(String query);
  Future<Movie> getMovieDetail(int movieId);
  Future<Set<int>> getFavoriteIds(String userId); // ✓ Add userId
  Future<Set<int>> toggleFavorite(String userId, int movieId); // ✓ Add userId
  Future<List<Movie>> getFavoriteMovies(String userId); // ✓ Add userId
}
