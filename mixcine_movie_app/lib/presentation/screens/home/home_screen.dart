import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_branding.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/entities/movie_section.dart';
import '../../providers/app_providers.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/home_provider.dart';
import '../../widgets/async_value_builder.dart';
import '../../widgets/movie_poster_card.dart';
import '../../widgets/primary_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 500) {
      ref.read(homeProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final favoriteIds = ref.watch(favoriteIdsProvider).value ?? <int>{};

    return SafeArea(
      child: AsyncValueBuilder<HomeState>(
        value: homeState,
        onRetry: () => ref.invalidate(homeProvider),
        onData: (data) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 900
                  ? 4
                  : constraints.maxWidth >= 600
                      ? 3
                      : 2;

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(homeProvider);
                  await ref.read(homeProvider.future);
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _Header(
                              onSearchTap: () => ref.read(dashboardIndexProvider.notifier).setIndex(1),
                            ),
                            const SizedBox(height: 24),
                            if (data.heroMovie != null)
                              _HeroBanner(
                                movie: data.heroMovie!,
                                onOpenDetails: () => context.push('/movie/${data.heroMovie!.id}'),
                                onPlay: () => context.push('/player/${data.heroMovie!.id}'),
                              ),
                            const SizedBox(height: 28),
                            for (final section in data.sections) ...<Widget>[
                              _SectionHeader(section: section),
                              const SizedBox(height: 14),
                              SizedBox(
                                height: 280,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: section.movies.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                                  itemBuilder: (context, index) {
                                    final movie = section.movies[index];
                                    return SizedBox(
                                      width: 158,
                                      child: MoviePosterCard(
                                        movie: movie,
                                        isFavorite: favoriteIds.contains(movie.id),
                                        onTap: () => context.push('/movie/${movie.id}'),
                                        onFavoriteTap: () => ref.read(favoriteIdsProvider.notifier).toggle(movie.id),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                            Text(
                              'Browse all',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Nà ná na nà na',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final movie = data.discoverMovies[index];
                            return MoviePosterCard(
                              movie: movie,
                              isFavorite: favoriteIds.contains(movie.id),
                              onTap: () => context.push('/movie/${movie.id}'),
                              onFavoriteTap: () => ref.read(favoriteIdsProvider.notifier).toggle(movie.id),
                            );
                          },
                          childCount: data.discoverMovies.length,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 18,
                          childAspectRatio: 0.58,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: data.isLoadingMore
                              ? const CircularProgressIndicator()
                              : data.hasMore
                                  ? const SizedBox.shrink()
                                  : Text(
                                      'Hết phim (^)>',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppBranding.appName.toUpperCase(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppBranding.homeGreeting,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppBranding.homeSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.person_outline),
            ),
          ],
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: onSearchTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.search, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Text(
                  'Search movies, genres, or your mood',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.movie,
    required this.onOpenDetails,
    required this.onPlay,
  });

  final Movie movie;
  final VoidCallback onOpenDetails;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: DecorationImage(
          image: NetworkImage(movie.backdropUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: <Color>[Colors.black87, Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                'Featured tonight',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              movie.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${movie.year} • ${movie.durationLabel} • ${movie.ratingLabel}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Expanded(
                  child: PrimaryButton(
                    label: 'Play',
                    icon: Icons.play_arrow_rounded,
                    onPressed: onPlay,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onOpenDetails,
                    child: const Text('Details'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.section});

  final MovieSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(section.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(section.subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
