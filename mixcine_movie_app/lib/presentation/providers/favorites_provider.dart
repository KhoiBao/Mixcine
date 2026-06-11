import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/movie.dart';
import 'app_providers.dart';
import 'auth_provider.dart';

class FavoriteIdsNotifier extends AsyncNotifier<Set<int>> {
  @override
  Future<Set<int>> build() async {
    final authState = ref.watch(authStateProvider);
    // SỬA: Phải dùng .id (mã UUID chuẩn của Supabase) thay vì .email
    final userId = authState.user?.id;

    if (userId == null) return <int>{};

    return ref.read(getFavoriteIdsUseCaseProvider).call(userId);
  }

  Future<void> toggle(int movieId) async {
    final authState = ref.read(authStateProvider);
    final userId = authState.user?.id;

    if (userId == null) return;

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
      state = AsyncData(updated);
    } catch (_) {
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
