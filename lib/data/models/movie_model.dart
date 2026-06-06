import '../../core/config/app_config.dart';
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

  // ENTITY
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
    );
  }

  // TMDB JSON
  factory MovieModel.fromTmdb(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] ?? 0,

      title: json['title'] ?? json['name'] ?? 'Untitled',

      overview: json['overview'] ?? '',

      posterUrl: json['poster_path'] ?? '',

      backdropUrl: json['backdrop_path'] ?? '',

      rating: (json['vote_average'] ?? 0).toDouble(),

      releaseDate: json['release_date'] ?? '',

      genres: _extractGenres(json),

      durationMinutes: json['runtime'] ?? 120,

      videoUrl: AppConfig.demoVideoUrl,
    );
  }

  // VIETNAMESE API JSON
  factory MovieModel.fromVietnameseApi(Map<String, dynamic> json) {
    final slug = json['slug']?.toString() ?? '';

    return MovieModel(
      id: slug.hashCode.abs(),

      title: json['name'] ?? json['original_name'] ?? 'Untitled',

      overview: json['description'] ?? '',

      posterUrl: json['poster_url'] ?? '',

      backdropUrl: json['thumb_url'] ?? '',

      rating: 0,

      releaseDate: json['created']?.toString().split('T').first ?? '',

      genres: [json['language'] ?? 'Film'],

      durationMinutes: _extractDuration(json['time']?.toString() ?? ''),

      videoUrl: AppConfig.demoVideoUrl,
    );
  }

  // SQLITE
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_url': posterUrl,
      'backdrop_url': backdropUrl,
      'rating': rating,
      'release_date': releaseDate,
      'genres': genres.join(','),
      'duration_minutes': durationMinutes,
      'video_url': videoUrl,
    };
  }

  factory MovieModel.fromMap(Map<String, dynamic> map) {
    return MovieModel(
      id: map['id'],

      title: map['title'],

      overview: map['overview'],

      posterUrl: map['poster_url'],

      backdropUrl: map['backdrop_url'],

      rating: (map['rating'] as num).toDouble(),

      releaseDate: map['release_date'],

      genres: map['genres'].toString().split(','),

      durationMinutes: map['duration_minutes'],

      videoUrl: map['video_url'],
    );
  }

  // HELPERS

  static List<String> _extractGenres(Map<String, dynamic> json) {
    final genres = json['genres'];

    if (genres is List) {
      return genres
          .map((item) => item['name']?.toString() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return <String>[];
  }

  static int _extractDuration(String text) {
    final match = RegExp(r'(\d+)').firstMatch(text);

    return match != null ? int.parse(match.group(1)!) : 120;
  }
}
