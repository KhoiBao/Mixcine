import '../entities/movie_comment.dart';

abstract class ReviewRepository {
  Future<void> addReview(
    int movieId,
    String userId,
    String authorName,
    String comment,
    double rating,
  );
  Future<List<MovieComment>> getReviewsForMovie(int movieId);
  Future<void> deleteReview(int reviewId, String currentUserId);
}
