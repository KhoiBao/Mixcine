import '../entities/watch_history.dart';

abstract class WatchHistoryRepository {
  Future<void> saveWatchProgress(int movieId, int progress);
  Future<int?> getWatchProgress(int movieId);
  Future<List<WatchHistory>> getAllWatchHistory(); 
  Future<void> removeWatchHistory(int movieId);
}