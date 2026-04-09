import '../../core/config/app_config.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_section.dart';
import '../../domain/entities/paginated_movies.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/favorites_local_data_source.dart';
import '../datasources/mock_movie_data_source.dart';
import '../datasources/movie_remote_data_source.dart';

class MovieRepositoryImpl implements MovieRepository {
  MovieRepositoryImpl({
    required MockMovieDataSource mockDataSource,
    required MovieRemoteDataSource remoteDataSource,
    required FavoritesLocalDataSource favoritesLocalDataSource,
  })  : _mockDataSource = mockDataSource,
        _remoteDataSource = remoteDataSource,
        _favoritesLocalDataSource = favoritesLocalDataSource;

  final MockMovieDataSource _mockDataSource;
  final MovieRemoteDataSource _remoteDataSource;
  final FavoritesLocalDataSource _favoritesLocalDataSource;

  @override
  Future<List<MovieSection>> getHomeSections() async {
    final popular = AppConfig.useMockData
        ? await _mockDataSource.fetchPopularMovies(page: 1)
        : await _remoteDataSource.fetchPopularMovies(page: 1);

    final topRated = AppConfig.useMockData
        ? await _mockDataSource.fetchTopRatedMovies(page: 1)
        : await _remoteDataSource.fetchTopRatedMovies(page: 1);

    final upcoming = AppConfig.useMockData
        ? await _mockDataSource.fetchUpcomingMovies(page: 1)
        : await _remoteDataSource.fetchUpcomingMovies(page: 1);

    return <MovieSection>[
      MovieSection(
        title: 'Popular now',
        subtitle: 'The movies everyone is opening first.',
        movies: popular.map((item) => item.toEntity()).toList(),
      ),
      MovieSection(
        title: 'Top rated',
        subtitle: 'Highest scored titles this week.',
        movies: topRated.map((item) => item.toEntity()).toList(),
      ),
      MovieSection(
        title: 'Coming soon',
        subtitle: 'Fresh releases and upcoming picks.',
        movies: upcoming.map((item) => item.toEntity()).toList(),
      ),
    ];
  }

  @override
  Future<PaginatedMovies> getDiscoverMovies({int page = 1}) async {
    final result = AppConfig.useMockData
        ? await _mockDataSource.fetchDiscoverMovies(page: page)
        : await _remoteDataSource.fetchDiscoverMovies(page: page);

    return PaginatedMovies(
      items: result.map((item) => item.toEntity()).toList(),
      currentPage: page,
      hasMore: result.length == AppConfig.pageSize,
    );
  }

  @override
  Future<Movie> getMovieDetail(int movieId) async {
    final result = AppConfig.useMockData
        ? await _mockDataSource.getMovieDetail(movieId)
        : await _remoteDataSource.getMovieDetail(movieId);

    return result.toEntity();
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    final result = AppConfig.useMockData
        ? await _mockDataSource.searchMovies(query)
        : await _remoteDataSource.searchMovies(query);

    return result.map((item) => item.toEntity()).toList();
  }

  @override
  Future<Set<int>> getFavoriteIds() {
    return _favoritesLocalDataSource.getFavoriteIds();
  }

  @override
  Future<Set<int>> toggleFavorite(int movieId) {
    return _favoritesLocalDataSource.toggleFavorite(movieId);
  }

  @override
  Future<List<Movie>> getFavoriteMovies() async {
    final ids = await _favoritesLocalDataSource.getFavoriteIds();
    if (ids.isEmpty) {
      return <Movie>[];
    }

    final result = AppConfig.useMockData
        ? await _mockDataSource.getMoviesByIds(ids)
        : await Future.wait(ids.map(_remoteDataSource.getMovieDetail));

    final movies = result.map((item) => item.toEntity()).toList();
    movies.sort((a, b) => a.title.compareTo(b.title));
    return movies;
  }
}
