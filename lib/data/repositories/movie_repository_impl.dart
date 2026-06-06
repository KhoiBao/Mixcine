import '../../core/config/app_config.dart';

import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_section.dart';
import '../../domain/entities/paginated_movies.dart';

import '../../domain/repositories/movie_repository.dart';

import '../datasources/favorites_local_data_source.dart';
import '../datasources/mock_movie_data_source.dart';
import '../datasources/movie_remote_data_source.dart';

import '../models/movie_model.dart';

class MovieRepositoryImpl implements MovieRepository {
  MovieRepositoryImpl({
    required MockMovieDataSource mockDataSource,

    required MovieRemoteDataSource remoteDataSource,

    required FavoritesLocalDataSource favoritesLocalDataSource,
  }) : _mockDataSource = mockDataSource,

       _remoteDataSource = remoteDataSource,

       _favoritesLocalDataSource = favoritesLocalDataSource;

  final MockMovieDataSource _mockDataSource;

  final MovieRemoteDataSource _remoteDataSource;

  final FavoritesLocalDataSource _favoritesLocalDataSource;

  // HOME SECTIONS

  @override
  Future<List<MovieSection>> getHomeSections() async {
    final popular = await _getPopularMovies();

    final topRated = await _getTopRatedMovies();

    final upcoming = await _getUpcomingMovies();

    return <MovieSection>[
      MovieSection(
        title: 'Popular',
        subtitle: 'Trending movies',

        movies: popular.map((item) => item.toEntity()).toList(),
      ),

      MovieSection(
        title: 'Top Rated',
        subtitle: 'Highest rated movies',

        movies: topRated.map((item) => item.toEntity()).toList(),
      ),

      MovieSection(
        title: 'Upcoming',
        subtitle: 'Coming soon',

        movies: upcoming.map((item) => item.toEntity()).toList(),
      ),
    ];
  }

  // DISCOVER

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

  // DETAIL

  @override
  Future<Movie> getMovieDetail(int movieId) async {
    final result = AppConfig.useMockData
        ? await _mockDataSource.getMovieDetail(movieId)
        : await _remoteDataSource.getMovieDetail(movieId);

    return result.toEntity();
  }

  // SEARCH

  @override
  Future<List<Movie>> searchMovies(String query) async {
    final result = AppConfig.useMockData
        ? await _mockDataSource.searchMovies(query)
        : await _remoteDataSource.searchMovies(query);

    return result.map((item) => item.toEntity()).toList();
  }

  // FAVORITES

  @override
  Future<Set<int>> getFavoriteIds(String userId) {
    // ✓ Add userId
    return _favoritesLocalDataSource.getFavoriteIds(userId);
  }

  @override
  Future<Set<int>> toggleFavorite(String userId, int movieId) {
    // ✓ Add userId
    return _favoritesLocalDataSource.toggleFavorite(userId, movieId);
  }

  @override
  Future<List<Movie>> getFavoriteMovies(String userId) async {
    // ✓ Add userId
    final ids = await getFavoriteIds(userId);

    if (ids.isEmpty) {
      return <Movie>[];
    }

    final result = AppConfig.useMockData
        ? await _mockDataSource.getMoviesByIds(ids)
        : await Future.wait(
            ids.map((id) => _remoteDataSource.getMovieDetail(id)),
          );

    final movies = result.map((item) => item.toEntity()).toList();

    movies.sort((a, b) => a.title.compareTo(b.title));

    return movies;
  }

  // PRIVATE HELPERS

  Future<List<MovieModel>> _getPopularMovies() {
    return AppConfig.useMockData
        ? _mockDataSource.fetchPopularMovies()
        : _remoteDataSource.fetchPopularMovies();
  }

  Future<List<MovieModel>> _getTopRatedMovies() {
    return AppConfig.useMockData
        ? _mockDataSource.fetchTopRatedMovies()
        : _remoteDataSource.fetchTopRatedMovies();
  }

  Future<List<MovieModel>> _getUpcomingMovies() {
    return AppConfig.useMockData
        ? _mockDataSource.fetchUpcomingMovies()
        : _remoteDataSource.fetchUpcomingMovies();
  }
}
