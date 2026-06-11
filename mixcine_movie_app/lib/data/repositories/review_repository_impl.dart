import '../../domain/entities/movie_comment.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_local_data_source.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  ReviewRepositoryImpl({required ReviewLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  final ReviewLocalDataSource _localDataSource;

  @override
  // Cập nhật tham số đầu vào
  Future<void> addReview(
    int movieId,
    String userId,
    String authorName,
    String comment,
    double rating,
  ) {
    // Truyền đủ 5 tham số xuống Data Source
    return _localDataSource.addReview(
      movieId,
      userId,
      authorName,
      comment,
      rating,
    );
  }

  @override
  Future<List<MovieComment>> getReviewsForMovie(int movieId) async {
    final models = await _localDataSource.getReviewsForMovie(movieId);

    return models
        .map(
          (model) => MovieComment(
            id: model.id.toString(),
            movieId: model.movieId,
            userId: model.userId, // Cập nhật lấy userId thật từ DB
            author: model.authorName, // Cập nhật lấy authorName thật từ DB
            text: model.comment,
            rating: model.rating,
            createdAt:
                DateTime.tryParse(model.createdAt) ??
                DateTime.now().toUtc(), // Parse chuỗi thời gian về DateTime
          ),
        )
        .toList();
  }

  @override
  // Cập nhật tham số đầu vào
  Future<void> deleteReview(int reviewId, String currentUserId) {
    // Truyền đủ 2 tham số xuống Data Source
    return _localDataSource.deleteReview(reviewId, currentUserId);
  }
}
