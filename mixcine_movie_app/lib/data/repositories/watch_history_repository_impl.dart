import '../../domain/entities/watch_history.dart';
import '../../domain/repositories/watch_history_repository.dart';
import '../datasources/watch_history_local_data_source.dart';

class WatchHistoryRepositoryImpl implements WatchHistoryRepository {
  WatchHistoryRepositoryImpl({
    required WatchHistoryLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final WatchHistoryLocalDataSource _localDataSource;

  @override
  Future<void> saveWatchProgress(String userId, int movieId, int progress) {
    // userId ở đây phải là UUID (user.id)
    return _localDataSource.saveWatchProgress(userId, movieId, progress);
  }

  @override
  Future<int?> getWatchProgress(String userId, int movieId) {
    return _localDataSource.getWatchProgress(userId, movieId);
  }

  @override
  Future<List<WatchHistory>> getAllWatchHistory(String userId) async {
    final models = await _localDataSource.getAllWatchHistory(userId);

    return models
        .map(
          (model) => WatchHistory(
            id: model.id,
            movieId: model.movieId,
            progress: model.progress,
          ),
        )
        .toList();
  }

  @override
  Future<void> removeWatchHistory(String userId, int movieId) {
    return _localDataSource.removeWatchHistory(userId, movieId);
  }
}
