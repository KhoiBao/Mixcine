import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/movie_comment.dart';

// Provider for storing user ratings for movies
final movieRatingsProvider =
    NotifierProvider<MovieRatingsNotifier, Map<int, double>>(
      MovieRatingsNotifier.new,
    );

class MovieRatingsNotifier extends Notifier<Map<int, double>> {
  @override
  Map<int, double> build() {
    return {};
  }

  void setRating(int movieId, double rating) {
    final newState = {...state};
    newState[movieId] = rating.clamp(0, 10);
    state = newState;
  }

  double? getRating(int movieId) {
    return state[movieId];
  }
}

// Provider for storing comments for movies
final movieCommentsProvider =
    NotifierProvider<MovieCommentsNotifier, Map<int, List<MovieComment>>>(
      MovieCommentsNotifier.new,
    );

class MovieCommentsNotifier extends Notifier<Map<int, List<MovieComment>>> {
  @override
  Map<int, List<MovieComment>> build() {
    return {};
  }

  void addComment(int movieId, String author, String text, double rating) {
    final comment = MovieComment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      movieId: movieId,
      author: author,
      text: text,
      rating: rating.clamp(0, 10),
      createdAt: DateTime.now(),
    );

    final newState = {...state};
    newState[movieId] = [comment, ...(state[movieId] ?? [])];
    state = newState;
  }

  List<MovieComment> getComments(int movieId) {
    return state[movieId] ?? [];
  }

  void deleteComment(int movieId, String commentId) {
    final newState = {...state};
    newState[movieId] = (state[movieId] ?? [])
        .where((c) => c.id != commentId)
        .toList();
    state = newState;
  }
}
