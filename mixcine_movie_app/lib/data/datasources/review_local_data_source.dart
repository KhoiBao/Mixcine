import 'package:sqflite/sqflite.dart';

import '../../database/database_helper.dart'; // Thay đổi đường dẫn import cho khớp với cấu trúc dự án của bạn
import '../models/review_model.dart';

class ReviewLocalDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Thêm một đánh giá mới
  Future<void> addReview(int movieId, String comment, double rating) async {
    final Database db = await _dbHelper.database;

    await db.insert('reviews', {
      'movie_id': movieId,
      'comment': comment,
      'rating': rating,
    });
  }

  // Lấy danh sách toàn bộ đánh giá của một bộ phim cụ thể
  Future<List<ReviewModel>> getReviewsForMovie(int movieId) async {
    final Database db = await _dbHelper.database;

    final maps = await db.query(
      'reviews',
      where: 'movie_id = ?',
      whereArgs: [movieId],
      orderBy: 'id DESC', // Đưa các bình luận mới nhất lên đầu tiên
    );

    return maps.map((map) => ReviewModel.fromMap(map)).toList();
  }

  // Xóa một đánh giá cụ thể dựa trên ID của đánh giá đó
  Future<void> deleteReview(int reviewId) async {
    final Database db = await _dbHelper.database;

    await db.delete('reviews', where: 'id = ?', whereArgs: [reviewId]);
  }
}
