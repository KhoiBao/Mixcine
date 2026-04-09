import 'movie.dart';

class PaginatedMovies {
  const PaginatedMovies({
    required this.items,
    required this.currentPage,
    required this.hasMore,
  });

  final List<Movie> items;
  final int currentPage;
  final bool hasMore;
}
