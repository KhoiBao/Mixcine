import 'package:sqflite/sqflite.dart';

import '../../database/database_helper.dart';
import '../models/watch_history_model.dart';

class WatchHistoryLocalDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Đã thêm userId và tự động tạo updated_at
  Future<void> saveWatchProgress(
    String userId,
    int movieId,
    int progress,
  ) async {
    final Database db = await _dbHelper.database;

    await db.insert('watch_history', {
      'user_id': userId,
      'movie_id': movieId,
      'progress': progress,
      'updated_at': DateTime.now()
          .toIso8601String(), // Tự động lấy giờ hiện tại
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Đã thêm userId để chỉ lấy tiến độ của tài khoản đang đăng nhập
  Future<int?> getWatchProgress(String userId, int movieId) async {
    final Database db = await _dbHelper.database;

    final maps = await db.query(
      'watch_history',
      where: 'user_id = ? AND movie_id = ?',
      whereArgs: [userId, movieId],
    );

    if (maps.isNotEmpty) {
      return maps.first['progress'] as int;
    }
    return null;
  }

  // Đã thêm userId để lấy danh sách lịch sử của riêng user đó, sắp xếp theo thời gian mới nhất
  Future<List<WatchHistoryModel>> getAllWatchHistory(String userId) async {
    final Database db = await _dbHelper.database;

    final maps = await db.query(
      'watch_history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC', // Đưa phim mới xem lên đầu
    );

    return maps.map((map) => WatchHistoryModel.fromMap(map)).toList();
  }

  Future<void> removeWatchHistory(String userId, int movieId) async {
    final Database db = await _dbHelper.database;

    await db.delete(
      'watch_history',
      where: 'user_id = ? AND movie_id = ?',
      whereArgs: [userId, movieId],
    );
  }
}
