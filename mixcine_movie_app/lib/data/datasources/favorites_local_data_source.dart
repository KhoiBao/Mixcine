import 'package:shared_preferences/shared_preferences.dart';

class FavoritesLocalDataSource {
  FavoritesLocalDataSource() : _prefs = SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;

  static const String _favoriteIdsKey = 'favorite_movie_ids';

  Future<Set<int>> getFavoriteIds() async {
    final values = await _prefs.getStringList(_favoriteIdsKey) ?? <String>[];
    return values.map(int.parse).toSet();
  }

  Future<Set<int>> toggleFavorite(int movieId) async {
    final current = await getFavoriteIds();

    if (current.contains(movieId)) {
      current.remove(movieId);
    } else {
      current.add(movieId);
    }

    await _prefs.setStringList(
      _favoriteIdsKey,
      current.map((item) => item.toString()).toList(),
    );

    return current;
  }
}
