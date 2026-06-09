import 'package:sqflite/sqflite.dart';

import '../../database/database_helper.dart'; // Thay đổi đường dẫn import cho khớp với cấu trúc dự án của bạn
import '../models/watch_history_model.dart';

class WatchHistoryLocalDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Lưu hoặc cập nhật tiến độ xem phim
  Future<void> saveWatchProgress(int movieId, int progress) async {
    final Database db = await _dbHelper.database;

    await db.insert(
      'watch_history',
      {'movie_id': movieId, 'progress': progress},
      // Nếu movie_id đã tồn tại, tự động ghi đè bản ghi cũ bằng tiến độ mới
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Lấy tiến độ xem của một phim cụ thể (trả về null nếu chưa từng xem)
  Future<int?> getWatchProgress(int movieId) async {
    final Database db = await _dbHelper.database;

    final maps = await db.query(
      'watch_history',
      where: 'movie_id = ?',
      whereArgs: [movieId],
    );

    if (maps.isNotEmpty) {
      return maps.first['progress'] as int;
    }
    return null;
  }

  // Lấy toàn bộ lịch sử xem phim (Sắp xếp từ mới nhất đến cũ nhất)
  Future<List<WatchHistoryModel>> getAllWatchHistory() async {
    final Database db = await _dbHelper.database;

    final maps = await db.query('watch_history', orderBy: 'id DESC');

    return maps.map((map) => WatchHistoryModel.fromMap(map)).toList();
  }

  // (Tùy chọn) Xóa một phim khỏi lịch sử
  Future<void> removeWatchHistory(int movieId) async {
    final Database db = await _dbHelper.database;

    await db.delete(
      'watch_history',
      where: 'movie_id = ?',
      whereArgs: [movieId],
    );
  }
}
