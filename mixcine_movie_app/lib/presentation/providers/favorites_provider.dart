import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/movie.dart';
import 'app_providers.dart';
import 'auth_provider.dart'; // ✓ Import auth provider

class FavoriteIdsNotifier extends AsyncNotifier<Set<int>> {
  @override
  Future<Set<int>> build() async {
    // ✓ WATCH instead of READ - rebuild when auth state changes
    final authState = ref.watch(authStateProvider);
    final userId = authState.user?.email;

    if (userId == null) return <int>{};

    return ref.read(getFavoriteIdsUseCaseProvider).call(userId);
  }

  Future<void> toggle(int movieId) async {
    // ✓ Get current user from auth provider
    final authState = ref.read(authStateProvider);
    final userId = authState.user?.email;

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
      // ✓ Pass userId to toggle
      final updated = await ref
          .read(toggleFavoriteUseCaseProvider)
          .call(userId, movieId);
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
  // ✓ WATCH instead of READ - rebuild when auth state changes
  final authState = ref.watch(authStateProvider);
  final userId = authState.user?.email;

  if (userId == null) return <Movie>[];

  // ✓ Watch favoriteIdsProvider to trigger rebuild when favorites change
  ref.watch(favoriteIdsProvider);

  // ✓ Pass userId to get favorite movies
  return ref.read(getFavoriteMoviesUseCaseProvider).call(userId);
});
