class Movie {
  const Movie({
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

  String get year => releaseDate.length >= 4 ? releaseDate.substring(0, 4) : releaseDate;

  String get durationLabel {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    return '$hours h $minutes m';
  }

  String get ratingLabel => rating.toStringAsFixed(1);
}
