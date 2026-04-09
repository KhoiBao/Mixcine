import 'movie.dart';

class MovieSection {
  const MovieSection({
    required this.title,
    required this.subtitle,
    required this.movies,
  });

  final String title;
  final String subtitle;
  final List<Movie> movies;
}
