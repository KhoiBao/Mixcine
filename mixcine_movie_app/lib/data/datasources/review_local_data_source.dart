import 'package:sqflite/sqflite.dart';

import '../../database/database_helper.dart';
import '../models/review_model.dart';

class ReviewLocalDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Đã bổ sung userId, authorName và created_at
  Future<void> addReview(
    int movieId,
    String userId,
    String authorName,
    String comment,
    double rating,
  ) async {
    final Database db = await _dbHelper.database;

    await db.insert('reviews', {
      'movie_id': movieId,
      'user_id': userId,
      'author_name': authorName,
      'comment': comment,
      'rating': rating,
      'created_at': DateTime.now()
          .toIso8601String(), // Tự động lấy giờ hiện tại
    });
  }

  // Lấy bình luận của một phim (giữ nguyên logic nhưng model ánh xạ đã có đủ trường)
  Future<List<ReviewModel>> getReviewsForMovie(int movieId) async {
    final Database db = await _dbHelper.database;

    final maps = await db.query(
      'reviews',
      where: 'movie_id = ?',
      whereArgs: [movieId],
      orderBy: 'created_at DESC', // Sắp xếp theo thời gian mới nhất thay vì ID
    );

    return maps.map((map) => ReviewModel.fromMap(map)).toList();
  }

  // (Tùy chọn) Có thể kiểm tra thêm userId để đảm bảo chỉ user tạo bình luận mới được xóa
  Future<void> deleteReview(int reviewId, String currentUserId) async {
    final Database db = await _dbHelper.database;

    await db.delete(
      'reviews',
      where: 'id = ? AND user_id = ?',
      whereArgs: [reviewId, currentUserId],
    );
  }
}
