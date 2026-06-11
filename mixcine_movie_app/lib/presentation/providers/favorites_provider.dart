import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/movie.dart';
import 'app_providers.dart';
import 'auth_provider.dart';

class FavoriteIdsNotifier extends AsyncNotifier<Set<int>> {
  @override
  Future<Set<int>> build() async {
    final authState = ref.watch(authStateProvider);
    final userId = authState.user?.id;

    if (userId == null) return <int>{};

    return ref.read(getFavoriteIdsUseCaseProvider).call(userId);
  }

  Future<void> toggle(int movieId) async {
    final authState = ref.read(authStateProvider);
    final userId = authState.user?.id;

    if (userId == null) {
      debugPrint('LOG FAVORITE: Không thể toggle vì userId đang NULL. Vui lòng đăng nhập!');
      return;
    }

    debugPrint('LOG FAVORITE: Đang toggle phim ID: $movieId cho User: $userId');

    final previous = state.value ?? <int>{};
    final optimistic = <int>{...previous};

    if (optimistic.contains(movieId)) {
      optimistic.remove(movieId);
    } else {
      optimistic.add(movieId);
    }

    state = AsyncData(optimistic);

    try {
      final updated = await ref
          .read(toggleFavoriteUseCaseProvider)
          .call(userId!, movieId);
      debugPrint('LOG FAVORITE: Lưu thành công vào Database');
      state = AsyncData(updated);
    } catch (e) {
      debugPrint('LOG FAVORITE: Lỗi khi lưu vào Database: $e');
      state = AsyncData(previous);
    }
  }
}

final favoriteIdsProvider =
    AsyncNotifierProvider<FavoriteIdsNotifier, Set<int>>(
      FavoriteIdsNotifier.new,
    );

final favoriteMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  final authState = ref.watch(authStateProvider);
  final userId = authState.user?.id;

  if (userId == null) return <Movie>[];

  ref.watch(favoriteIdsProvider);

  return ref.read(getFavoriteMoviesUseCaseProvider).call(userId);
});
