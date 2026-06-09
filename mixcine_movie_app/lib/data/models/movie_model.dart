import '../../core/config/app_config.dart';
import '../../core/config/api_config.dart';
import '../../domain/entities/movie.dart';

class MovieModel {
  const MovieModel({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterUrl,
    required this.backdropUrl,
    required this.rating,
    required this.releaseDate,
    required this.genres,
    required this.durationMinutes,
    required this.videoUrl,
    required this.requiredTier,
  });

  final int id;
  final String title;
  final String overview;
  final String posterUrl;
  final String backdropUrl;
  final double rating;
  final String releaseDate;
  final List<String> genres;
  final int durationMinutes;
  final String videoUrl;
  final int requiredTier;

  Movie toEntity() {
    return Movie(
      id: id,
      title: title,
      overview: overview,
      posterUrl: posterUrl,
      backdropUrl: backdropUrl,
      rating: rating,
      releaseDate: releaseDate,
      genres: genres,
      durationMinutes: durationMinutes,
      videoUrl: videoUrl,
      requiredTier: requiredTier, // ✓ Map sang Entity
    );
  }

  factory MovieModel.fromTmdb(Map<String, dynamic> json) {
    final detailGenres = json['genres'];
    final genreIds = List<int>.from(json['genre_ids'] ?? const <int>[]);

    final genres = detailGenres is List
        ? detailGenres
        .map(
          (item) =>
      (item as Map<String, dynamic>)['name']?.toString() ?? '',
    )
        .where((item) => item.isNotEmpty)
        .toList()
        : genreIds.map(_mapGenreId).where((item) => item.isNotEmpty).toList();

    final overviewStr = json['overview']?.toString() ?? '';
    final id = json['id'] as int? ?? 0;

    return MovieModel(
      id: id,
      title:
      json['title']?.toString() ?? json['name']?.toString() ?? 'Untitled',
      overview: overviewStr.trim().isNotEmpty
          ? overviewStr
          : 'No description available for this movie yet.',
      posterUrl: _buildImageUrl(json['poster_path']),
      backdropUrl: _buildBackdropUrl(
        json['backdrop_path'] ?? json['poster_path'],
      ),
      rating: (json['vote_average'] as num?)?.toDouble() ?? 0,
      releaseDate: json['release_date']?.toString() ?? '2026-01-01',
      genres: genres.isEmpty ? const ['Drama'] : genres.take(3).toList(),
      durationMinutes: (json['runtime'] as num?)?.toInt() ?? 120,
      videoUrl: AppConfig.demoVideoUrl,
      requiredTier: (id % 3) + 1, // ✓ Trick: Tự động random tier 1, 2, hoặc 3 dựa trên ID
    );
  }

  factory MovieModel.fromVietnameseApi(Map<String, dynamic> json) {
    final slug = json['slug']?.toString() ?? '';
    final id = slug.hashCode.abs(); // Generate a unique ID from slug

    return MovieModel(
      id: id,
      title:
      json['name']?.toString() ??
          json['original_name']?.toString() ??
          'Untitled',
      overview: (() {
        final desc = json['description']?.toString() ?? '';
        return desc.trim().isNotEmpty
            ? desc
            : 'No description available for this movie yet.';
      })(),
      posterUrl: (json['poster_url'] as String?)?.trim() ?? '',
      backdropUrl: (json['thumb_url'] as String?)?.trim() ?? '',
      rating: 0.0, // Vietnamese API doesn't provide ratings
      releaseDate: json['created']?.toString().split('T').first ?? '2026-01-01',
      genres: [json['language']?.toString() ?? 'Film'].take(3).toList(),
      durationMinutes: _extractDuration(json['time']?.toString() ?? '120 phút'),
      videoUrl: AppConfig.demoVideoUrl,
      requiredTier: (id % 3) + 1, // ✓ Trick: Tự động random tier 1, 2, hoặc 3 dựa trên ID
    );
  }

  static int _extractDuration(String timeStr) {
    final match = RegExp(r'(\d+)').firstMatch(timeStr);
    return match != null ? int.parse(match.group(1)!) : 120;
  }

  static String _buildImageUrl(dynamic path) {
    final value = path?.toString() ?? '';
    if (value.isEmpty) {
      return AppConfig.fallbackPosterUrl;
    }
    return '${ApiConfig.tmdbImageBaseUrl}$value';
  }

  static String _buildBackdropUrl(dynamic path) {
    final value = path?.toString() ?? '';
    if (value.isEmpty) {
      return AppConfig.fallbackBackdropUrl;
    }
    return '${ApiConfig.tmdbImageBaseUrl}$value';
  }

  static String _mapGenreId(int id) {
    const genres = <int, String>{
      12: 'Adventure', 14: 'Fantasy', 16: 'Animation', 18: 'Drama',
      27: 'Horror', 28: 'Action', 35: 'Comedy', 36: 'History',
      53: 'Thriller', 80: 'Crime', 99: 'Documentary', 878: 'Sci-Fi',
      9648: 'Mystery', 10402: 'Music', 10749: 'Romance', 10751: 'Family',
      10752: 'War',
    };
    return genres[id] ?? '';
  }
}