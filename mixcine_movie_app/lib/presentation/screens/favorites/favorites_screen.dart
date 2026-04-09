import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/favorites_provider.dart';
import '../../widgets/async_value_builder.dart';
import '../../widgets/branded_screen_header.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/movie_poster_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteMovies = ref.watch(favoriteMoviesProvider);
    final favoriteIds = ref.watch(favoriteIdsProvider).value ?? <int>{};

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth >= 900
              ? 4
              : constraints.maxWidth >= 600
                  ? 3
                  : 2;

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const BrandedScreenHeader(
                  title: 'Thích Phim',
                  subtitle: 'Phim bro thích đều ở đây á homie',
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: AsyncValueBuilder(
                    value: favoriteMovies,
                    onData: (movies) {
                      if (movies.isEmpty) {
                        return const EmptyStateView(
                          icon: Icons.favorite_border,
                          title: 'Trống vắng',
                          subtitle: 'Yêu ai thì bấm tim',
                        );
                      }

                      return GridView.builder(
                        itemCount: movies.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 18,
                          childAspectRatio: 0.58,
                        ),
                        itemBuilder: (context, index) {
                          final movie = movies[index];
                          return MoviePosterCard(
                            movie: movie,
                            isFavorite: favoriteIds.contains(movie.id),
                            onTap: () => context.push('/movie/${movie.id}'),
                            onFavoriteTap: () => ref.read(favoriteIdsProvider.notifier).toggle(movie.id),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
