import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/movie.dart';
import 'app_providers.dart';

class FavoriteIdsNotifier extends AsyncNotifier<Set<int>> {
  @override
  Future<Set<int>> build() async {
    return ref.read(getFavoriteIdsUseCaseProvider).call();
  }

  Future<void> toggle(int movieId) async {
    final previous = state.value ?? <int>{};
    final optimistic = <int>{...previous};

    if (optimistic.contains(movieId)) {
      optimistic.remove(movieId);
    } else {
      optimistic.add(movieId);
    }

    state = AsyncData(optimistic);

    try {
      final updated = await ref.read(toggleFavoriteUseCaseProvider).call(movieId);
      state = AsyncData(updated);
    } catch (_) {
      state = AsyncData(previous);
    }
  }
}

final favoriteIdsProvider =
    AsyncNotifierProvider<FavoriteIdsNotifier, Set<int>>(FavoriteIdsNotifier.new);

final favoriteMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  ref.watch(favoriteIdsProvider);
  return ref.read(getFavoriteMoviesUseCaseProvider).call();
});
