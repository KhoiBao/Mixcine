import '../entities/watch_history.dart';

abstract class WatchHistoryRepository {
  Future<void> saveWatchProgress(String userId, int movieId, int progress);
  Future<int?> getWatchProgress(String userId, int movieId);
  Future<List<WatchHistory>> getAllWatchHistory(String userId); 
  Future<void> removeWatchHistory(String userId, int movieId);
}
