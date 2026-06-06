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

  void addComment(
    int movieId,
    String userId,
    String author,
    String text,
    double rating,
  ) {
    final comment = MovieComment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      movieId: movieId,
      userId: userId, // ✓ Add userId for security
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

// Provider for storing user ratings for comments
// Key format: "commentId:userId" → Rating (1-5 stars)
final commentRatingsProvider =
    NotifierProvider<CommentRatingsNotifier, Map<String, double>>(
      CommentRatingsNotifier.new,
    );

class CommentRatingsNotifier extends Notifier<Map<String, double>> {
  @override
  Map<String, double> build() {
    return {};
  }

  // ✓ Set rating for a comment by a user (1-5 stars)
  void rateComment(String commentId, String userId, double rating) {
    final key = '$commentId:$userId';
    final newState = {...state};
    newState[key] = rating.clamp(1, 5);
    state = newState;
  }

  // ✓ Get rating for a comment by a user
  double? getCommentRating(String commentId, String userId) {
    final key = '$commentId:$userId';
    return state[key];
  }

  // ✓ Get average rating for a comment
  double getAverageRating(String commentId) {
    final ratings = state.entries
        .where((e) => e.key.startsWith('$commentId:'))
        .map((e) => e.value)
        .toList();

    if (ratings.isEmpty) return 0;
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }
}
