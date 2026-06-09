import '../../domain/entities/movie_comment.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_local_data_source.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  ReviewRepositoryImpl({required ReviewLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  final ReviewLocalDataSource _localDataSource;

  @override
  Future<void> addReview(int movieId, String comment, double rating) {
    return _localDataSource.addReview(movieId, comment, rating);
  }

  @override
  Future<List<MovieComment>> getReviewsForMovie(int movieId) async {
    final models = await _localDataSource.getReviewsForMovie(movieId);

    // Map từ Model (Data) sang Entity (Domain)
    return models
        .map(
          (model) => MovieComment(
            id: model.id.toString(), // Entity của bạn đang dùng String cho ID
            movieId: model.movieId,
            userId: 'local_user', // Tạm thời hardcode nếu LocalDB chưa lưu User
            author: 'Guest', // Tạm thời hardcode
            text: model.comment,
            rating: model.rating,
            createdAt:
                DateTime.now(), // SQLite chưa lưu ngày tháng, tạm lấy giờ hiện tại
          ),
        )
        .toList();
  }

  @override
  Future<void> deleteReview(int reviewId) {
    return _localDataSource.deleteReview(reviewId);
  }
}
