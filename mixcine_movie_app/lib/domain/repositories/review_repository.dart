import '../entities/movie_comment.dart';

abstract class ReviewRepository {
  Future<void> addReview(int movieId, String comment, double rating);
  Future<List<MovieComment>> getReviewsForMovie(int movieId);
  Future<void> deleteReview(int reviewId);
}
