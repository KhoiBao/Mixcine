import '../../domain/entities/watch_history.dart';
import '../../domain/repositories/watch_history_repository.dart';
import '../datasources/watch_history_local_data_source.dart';

class WatchHistoryRepositoryImpl implements WatchHistoryRepository {
  WatchHistoryRepositoryImpl({
    required WatchHistoryLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final WatchHistoryLocalDataSource _localDataSource;

  @override
  Future<void> saveWatchProgress(int movieId, int progress) {
    return _localDataSource.saveWatchProgress(movieId, progress);
  }

  @override
  Future<int?> getWatchProgress(int movieId) {
    return _localDataSource.getWatchProgress(movieId);
  }

  @override
  Future<List<WatchHistory>> getAllWatchHistory() async {
    final models = await _localDataSource.getAllWatchHistory();
    // Chuyển đổi từ Model (Data) sang Entity (Domain)
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
  Future<void> removeWatchHistory(int movieId) {
    return _localDataSource.removeWatchHistory(movieId);
  }
}
