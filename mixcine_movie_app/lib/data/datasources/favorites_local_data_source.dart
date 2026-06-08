import 'package:sqflite/sqflite.dart';

import '../../database/database_helper.dart';

class FavoritesLocalDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ✓ Add userId parameter
  Future<Set<int>> getFavoriteIds(String userId) async {
    final Database db = await _dbHelper.database;

    final maps = await db.query(
      'favorites',
      where: 'user_id = ?', // ✓ Filter by user_id
      whereArgs: [userId],
    );

    return maps.map((item) => item['movie_id'] as int).toSet();
  }

  // ✓ Add userId parameter
  Future<Set<int>> toggleFavorite(String userId, int movieId) async {
    final Database db = await _dbHelper.database;

    final existing = await db.query(
      'favorites',
      where: 'user_id = ? AND movie_id = ?', // ✓ Filter by both
      whereArgs: [userId, movieId],
    );

    if (existing.isNotEmpty) {
      await db.delete(
        'favorites',
        where: 'user_id = ? AND movie_id = ?',
        whereArgs: [userId, movieId],
      );
    } else {
      await db.insert('favorites', {'user_id': userId, 'movie_id': movieId});
    }

    return await getFavoriteIds(userId);
  }
}
