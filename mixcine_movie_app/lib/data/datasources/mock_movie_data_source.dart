import 'dart:math';

import '../../core/config/app_config.dart';
import '../models/movie_model.dart';

class MockMovieDataSource {
  final List<MovieModel> _movies = const <MovieModel>[
    MovieModel(
      id: 1,
      title: 'Dune Legacy',
      overview: 'A desert world, noble houses, and a prophecy that changes the balance of power.',
      posterUrl: 'https://picsum.photos/seed/movie_1/500/750',
      backdropUrl: 'https://picsum.photos/seed/backdrop_1/1200/700',
      rating: 8.7,
      releaseDate: '2024-02-16',
      genres: ['Sci-Fi', 'Adventure'],
      durationMinutes: 155,
      videoUrl: AppConfig.demoVideoUrl,
    ),
    MovieModel(
      id: 2,
      title: 'Midnight Hacker',
      overview: 'A student hacker discovers a surveillance tool hidden inside a streaming platform.',
      posterUrl: 'https://picsum.photos/seed/movie_2/500/750',
      backdropUrl: 'https://picsum.photos/seed/backdrop_2/1200/700',
      rating: 7.9,
      releaseDate: '2025-01-12',
      genres: ['Thriller', 'Crime'],
      durationMinutes: 121,
      videoUrl: AppConfig.demoVideoUrl,
    ),
    MovieModel(
      id: 3,
      title: 'Skyline 2049',
      overview: 'A futuristic detective follows clues across a neon megacity after a mysterious blackout.',
      posterUrl: 'https://picsum.photos/seed/movie_3/500/750',
      backdropUrl: 'https://picsum.photos/seed/backdrop_3/1200/700',
      rating: 8.4,
      releaseDate: '2023-10-03',
      genres: ['Sci-Fi', 'Mystery'],
      durationMinutes: 138,
      videoUrl: AppConfig.demoVideoUrl,
    ),
    MovieModel(
      id: 4,
      title: 'Runway to Tokyo',
      overview: 'A fashion intern lands in Tokyo and learns that ambition always comes with a price.',
      posterUrl: 'https://picsum.photos/seed/movie_4/500/750',
      backdropUrl: 'https://picsum.photos/seed/backdrop_4/1200/700',
      rating: 7.3,
      releaseDate: '2025-08-19',
      genres: ['Drama', 'Romance'],
      durationMinutes: 110,
      videoUrl: AppConfig.demoVideoUrl,
    ),
    MovieModel(
      id: 5,
      title: 'The Last Orbit',
      overview: 'A rescue mission near Saturn turns into a survival story between trust and sacrifice.',
      posterUrl: 'https://picsum.photos/seed/movie_5/500/750',
      backdropUrl: 'https://picsum.photos/seed/backdrop_5/1200/700',
      rating: 8.9,
      releaseDate: '2024-11-02',
      genres: ['Sci-Fi', 'Drama'],
      durationMinutes: 147,
      videoUrl: AppConfig.demoVideoUrl,
    ),
    MovieModel(
      id: 6,
      title: 'Paper Crown',
      overview: 'The youngest candidate in a royal election shakes a kingdom built on old secrets.',
      posterUrl: 'https://picsum.photos/seed/movie_6/500/750',
      backdropUrl: 'https://picsum.photos/seed/backdrop_6/1200/700',
      rating: 7.6,
      releaseDate: '2023-07-17',
      genres: ['Drama', 'History'],
      durationMinutes: 132,
      videoUrl: AppConfig.demoVideoUrl,
    ),
    MovieModel(
      id: 7,
      title: 'After Rainfall',
      overview: 'Two strangers reconnect every monsoon season and rewrite the story of their hometown.',
      posterUrl: 'https://picsum.photos/seed/movie_7/500/750',
      backdropUrl: 'https://picsum.photos/seed/backdrop_7/1200/700',
      rating: 7.8,
      releaseDate: '2022-04-27',
      genres: ['Romance', 'Drama'],
      durationMinutes: 104,
      videoUrl: AppConfig.demoVideoUrl,
    ),
    MovieModel(
      id: 8,
      title: 'Monster Street',
      overview: 'A comic artist accidentally sketches creatures that begin to appear in real life.',
      posterUrl: 'https://picsum.photos/seed/movie_8/500/750',
      backdropUrl: 'https://picsum.photos/seed/backdrop_8/1200/700',
      rating: 7.1,
      releaseDate: '2025-06-10',
      genres: ['Comedy', 'Fantasy'],
      durationMinutes: 99,
      videoUrl: AppConfig.demoVideoUrl,
    ),
    MovieModel(
      id: 9,
      title: 'Shadow Protocol',
      overview: 'An undercover agent races across Europe after a covert operation collapses overnight.',
      posterUrl: 'https://picsum.photos/seed/movie_9/500/750',
      backdropUrl: 'https://picsum.photos/seed/backdrop_9/1200/700',
      rating: 8.2,
      releaseDate: '2024-09-05',
      genres: ['Action', 'Thriller'],
      durationMinutes: 128,
      videoUrl: AppConfig.demoVideoUrl,
    ),
    MovieModel(
      id: 10,
      title: 'Quiet Letters',
      overview: 'A retiring postman starts reading the stories hidden between undelivered letters.',
      posterUrl: 'https://picsum.photos/seed/movie_10/500/750',
      backdropUrl: 'https://picsum.photos/seed/backdrop_10/1200/700',
      rating: 8.0,
      releaseDate: '2023-12-22',
      genres: ['Drama', 'Family'],
      durationMinutes: 113,
      videoUrl: AppConfig.demoVideoUrl,
    ),
    MovieModel(
      id: 11,
      title: 'Zero Gravity Club',
      overview: 'A group of trainees on a damaged orbital station must finish their final exam for real.',
      posterUrl: 'https://picsum.photos/seed/movie_11/500/750',
      backdropUrl: 'https://picsum.photos/seed/backdrop_11/1200/700',
      rating: 8.5,
      releaseDate: '2025-03-01',
      genres: ['Adventure', 'Sci-Fi'],
      durationMinutes: 143,
      videoUrl: AppConfig.demoVideoUrl,
    ),
    MovieModel(
      id: 12,
      title: 'Burning Signals',
      overview: 'A late-night radio host receives calls that predict disasters before they happen.',
      posterUrl: 'https://picsum.photos/seed/movie_12/500/750',
      backdropUrl: 'https://picsum.photos/seed/backdrop_12/1200/700',
      rating: 7.7,
      releaseDate: '2024-05-25',
      genres: ['Mystery', 'Thriller'],
      durationMinutes: 118,
      videoUrl: AppConfig.demoVideoUrl,
    ),
  ];

  Future<List<MovieModel>> fetchPopularMovies({int page = 1}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _slicePage(_movies, page);
  }

  Future<List<MovieModel>> fetchTopRatedMovies({int page = 1}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final sorted = [..._movies]..sort((a, b) => b.rating.compareTo(a.rating));
    return _slicePage(sorted, page);
  }

  Future<List<MovieModel>> fetchUpcomingMovies({int page = 1}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final sorted = [..._movies]..sort((a, b) => b.releaseDate.compareTo(a.releaseDate));
    return _slicePage(sorted, page);
  }

  Future<List<MovieModel>> fetchDiscoverMovies({int page = 1}) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return _slicePage(_movies, page);
  }

  Future<List<MovieModel>> searchMovies(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return <MovieModel>[];
    }

    return _movies.where((movie) {
      final titleMatch = movie.title.toLowerCase().contains(normalized);
      final genreMatch = movie.genres.any(
        (genre) => genre.toLowerCase().contains(normalized),
      );
      return titleMatch || genreMatch;
    }).toList();
  }

  Future<MovieModel> getMovieDetail(int movieId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _movies.firstWhere((movie) => movie.id == movieId);
  }

  Future<List<MovieModel>> getMoviesByIds(Set<int> ids) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _movies.where((movie) => ids.contains(movie.id)).toList();
  }

  List<MovieModel> _slicePage(List<MovieModel> source, int page) {
    final start = (page - 1) * AppConfig.pageSize;
    if (start >= source.length) {
      return <MovieModel>[];
    }

    final end = min(start + AppConfig.pageSize, source.length);
    return source.sublist(start, end);
  }
}
