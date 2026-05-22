import 'package:dio/dio.dart';

import '../../core/config/api_config.dart';
import '../../core/config/app_config.dart';
import '../models/movie_model.dart';

class MovieRemoteDataSource {
  MovieRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<MovieModel>> fetchPopularMovies({int page = 1}) {
    // Latest movies
    return _fetchMovieList('/phim-moi-cap-nhat', page: page);
  }

  Future<List<MovieModel>> fetchTopRatedMovies({int page = 1}) {
    // Single films (phim lẻ)
    return _fetchMovieList('/danh-sach/phim-le', page: page);
  }

  Future<List<MovieModel>> fetchUpcomingMovies({int page = 1}) {
    // TV series (phim bộ)
    return _fetchMovieList('/danh-sach/phim-bo', page: page);
  }

  Future<List<MovieModel>> fetchDiscoverMovies({int page = 1}) {
    // Animations (hoạt hình)
    return _fetchMovieList('/danh-sach/hoat-hinh', page: page);
  }

  Future<List<MovieModel>> searchMovies(String query, {int page = 1}) async {
    // Vietnamese API doesn't have search endpoint, fallback to popular
    return fetchPopularMovies(page: page);
  }

  Future<MovieModel> getMovieDetail(int movieId) async {
    // Fallback: fetch list and find by ID, or return a mock movie
    final movies = await fetchPopularMovies();
    try {
      return movies.firstWhere((movie) => movie.id == movieId);
    } catch (_) {
      // Return first movie if not found
      return movies.isNotEmpty ? movies.first : _createDummyMovie();
    }
  }

  Future<List<MovieModel>> _fetchMovieList(String path, {required int page}) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: <String, dynamic>{
          'page': page,
        },
      );

      final data = response.data as Map<String, dynamic>;
      
      // Check if response has the Vietnamese API structure
      if (data.containsKey('items') && data['items'] is List) {
        final items = List<Map<String, dynamic>>.from(data['items'] as List<dynamic>);
        return items.map(MovieModel.fromVietnameseApi).toList();
      }
      
      // Fallback for other response formats
      return const <MovieModel>[];
    } catch (e) {
      // Return empty list on error
      return const <MovieModel>[];
    }
  }

  MovieModel _createDummyMovie() {
    return MovieModel(
      id: 0,
      title: 'Movie Not Found',
      overview: 'Could not load movie details.',
      posterUrl: '',
      backdropUrl: '',
      rating: 0,
      releaseDate: '2026-01-01',
      genres: const ['Film'],
      durationMinutes: 120,
      videoUrl: AppConfig.demoVideoUrl,
    );
  }
}
