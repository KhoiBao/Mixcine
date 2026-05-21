import 'package:sqflite/sqflite.dart';

import '../../database/database_helper.dart';

class FavoritesLocalDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<Set<int>> getFavoriteIds() async {
    final Database db = await _dbHelper.database;

    final maps = await db.query('favorites');

    return maps.map((item) => item['movie_id'] as int).toSet();
  }

  Future<Set<int>> toggleFavorite(int movieId) async {
    final Database db = await _dbHelper.database;

    final existing = await db.query(
      'favorites',
      where: 'movie_id = ?',
      whereArgs: [movieId],
    );

    if (existing.isNotEmpty) {
      await db.delete('favorites', where: 'movie_id = ?', whereArgs: [movieId]);
    } else {
      await db.insert('favorites', {'movie_id': movieId});
    }

    return await getFavoriteIds();
  }
}
