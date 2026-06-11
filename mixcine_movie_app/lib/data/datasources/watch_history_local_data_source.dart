import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/watch_history_model.dart';

class WatchHistoryLocalDataSource {
  final _client = Supabase.instance.client;

  Future<void> saveWatchProgress(
    String userId, // Phải truyền UUID (user.id)
    int movieId,
    int progress,
  ) async {
    await _client.from('watch_history').upsert({
      'user_id': userId,
      'movie_id': movieId,
      'progress': progress,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id, movie_id');
  }

  Future<int?> getWatchProgress(String userId, int movieId) async {
    final response = await _client
        .from('watch_history')
        .select('progress')
        .eq('user_id', userId)
        .eq('movie_id', movieId)
        .maybeSingle();

    if (response != null) {
      return response['progress'] as int;
    }
    return null;
  }

  Future<List<WatchHistoryModel>> getAllWatchHistory(String userId) async {
    final response = await _client
        .from('watch_history')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);

    return (response as List).map((map) => WatchHistoryModel.fromMap(map)).toList();
  }

  Future<void> removeWatchHistory(String userId, int movieId) async {
    await _client
        .from('watch_history')
        .delete()
        .eq('user_id', userId)
        .eq('movie_id', movieId);
  }
}
