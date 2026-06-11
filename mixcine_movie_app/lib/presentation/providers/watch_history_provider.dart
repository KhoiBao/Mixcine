import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/watch_history.dart';
import 'app_providers.dart';
import 'auth_provider.dart';

class WatchHistoryNotifier extends AsyncNotifier<List<WatchHistory>> {
  @override
  Future<List<WatchHistory>> build() async {
    final authState = ref.watch(authStateProvider);
    // SỬA: Dùng .id (UUID) thay vì .email
    final userId = authState.user?.id;

    if (userId == null) return [];

    return ref.read(watchHistoryRepositoryProvider).getAllWatchHistory(userId);
  }

  Future<void> saveProgress(int movieId, int progress) async {
    final authState = ref.read(authStateProvider);
    final userId = authState.user?.id;

    if (userId == null) return;

    try {
      await ref.read(watchHistoryRepositoryProvider).saveWatchProgress(userId, movieId, progress);
      ref.invalidateSelf(); // Tải lại danh sách sau khi lưu
    } catch (e) {
      print('Lỗi lưu lịch sử xem: $e');
    }
  }

  Future<void> remove(int movieId) async {
    final authState = ref.read(authStateProvider);
    final userId = authState.user?.id;
    if (userId == null) return;

    await ref.read(watchHistoryRepositoryProvider).removeWatchHistory(userId, movieId);
    ref.invalidateSelf();
  }
}

final watchHistoryProvider = AsyncNotifierProvider<WatchHistoryNotifier, List<WatchHistory>>(
  WatchHistoryNotifier.new,
);
