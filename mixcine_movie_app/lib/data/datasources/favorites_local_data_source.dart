import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesLocalDataSource {
  final _client = Supabase.instance.client;

  Future<Set<int>> getFavoriteIds(String userId) async {
    final response = await _client
        .from('favorites')
        .select('movie_id')
        .eq('user_id', userId);

    return (response as List).map((item) => item['movie_id'] as int).toSet();
  }

  Future<Set<int>> toggleFavorite(String userId, int movieId) async {
    final existing = await _client
        .from('favorites')
        .select()
        .eq('user_id', userId)
        .eq('movie_id', movieId)
        .maybeSingle();

    if (existing != null) {
      await _client
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('movie_id', movieId);
    } else {
      await _client.from('favorites').insert({
        'user_id': userId,
        'movie_id': movieId,
      });
    }

    return await getFavoriteIds(userId);
  }
}
