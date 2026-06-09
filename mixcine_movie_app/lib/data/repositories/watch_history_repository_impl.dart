import '../../domain/entities/watch_history.dart';
import '../../domain/repositories/watch_history_repository.dart';
import '../datasources/watch_history_local_data_source.dart';

class WatchHistoryRepositoryImpl implements WatchHistoryRepository {
  WatchHistoryRepositoryImpl({
    required WatchHistoryLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final WatchHistoryLocalDataSource _localDataSource;

  @override
  // Thêm userId
  Future<void> saveWatchProgress(String userId, int movieId, int progress) {
    return _localDataSource.saveWatchProgress(userId, movieId, progress);
  }

  @override
  // Thêm userId
  Future<int?> getWatchProgress(String userId, int movieId) {
    return _localDataSource.getWatchProgress(userId, movieId);
  }

  @override
  // Thêm userId
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
  // Thêm userId
  Future<void> removeWatchHistory(String userId, int movieId) {
    return _localDataSource.removeWatchHistory(userId, movieId);
  }
}
