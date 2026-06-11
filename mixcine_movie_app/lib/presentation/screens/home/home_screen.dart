import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_branding.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/entities/movie_section.dart';
import '../../../domain/entities/payment_plan.dart'; // Thêm import
import '../../providers/app_providers.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/subscription_provider.dart'; // Thêm import
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
    _scrollController..removeListener(_onScroll)..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final favoriteIds = ref.watch(favoriteIdsProvider).value ?? <int>{};
    final theme = Theme.of(context);
    
    // KIỂM TRA QUYỀN QUẢNG CÁO
    final subscription = ref.watch(subscriptionProvider);
    final isFree = (subscription?.plan ?? PaymentPlan.free) == PaymentPlan.free;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: AsyncValueBuilder<HomeState>(
          value: homeState,
          onRetry: () => ref.invalidate(homeProvider),
          onData: (data) {
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
                            onProfileTap: () => ref.read(dashboardIndexProvider.notifier).setIndex(3),
                          ),
                          const SizedBox(height: 24),
                          if (data.heroMovie != null)
                            _HeroBanner(
                              movie: data.heroMovie!,
                              onOpenDetails: () => context.push('/movie/${data.heroMovie!.id}'),
                              onPlay: () => context.push('/player/${data.heroMovie!.id}'),
                            ),
                          const SizedBox(height: 32),
                          for (final section in data.sections) ...<Widget>[
                            _SectionHeader(section: section),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 280,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                // Tăng thêm 1 slot nếu là User FREE
                                itemCount: section.movies.length + (isFree ? 1 : 0),
                                separatorBuilder: (context, _) => const SizedBox(width: 14),
                                itemBuilder: (context, index) {
                                  // Chèn quảng cáo vào vị trí số 2 (index 1)
                                  if (isFree && index == 1) {
                                    return const SizedBox(width: 158, child: _Mixi88MiniCard());
                                  }
                                  
                                  // Tính toán lại index phim thực tế
                                  final movieIndex = (isFree && index > 1) ? index - 1 : index;
                                  if (movieIndex >= section.movies.length) return const SizedBox.shrink();
                                  
                                  final movie = section.movies[movieIndex];
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
                            const SizedBox(height: 32),
                          ],
                          Text('Khám phá', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        // Chèn vào vị trí số 3 (index 2) trong Grid Khám phá
                        if (isFree && index == 2) {
                          return const _Mixi88MiniCard();
                        }
                        
                        final movieIndex = (isFree && index > 2) ? index - 1 : index;
                        if (movieIndex >= data.discoverMovies.length) return const SizedBox.shrink();

                        final movie = data.discoverMovies[movieIndex];
                        return MoviePosterCard(
                          movie: movie,
                          isFavorite: favoriteIds.contains(movie.id),
                          onTap: () => context.push('/movie/${movie.id}'),
                          onFavoriteTap: () => ref.read(favoriteIdsProvider.notifier).toggle(movie.id),
                        );
                      }, childCount: data.discoverMovies.length + (isFree ? 1 : 0)),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
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
                                : Text('Hết phim rùi ^_^', style: theme.textTheme.bodyMedium),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// COMPONENT QUẢNG CÁO TROLL
class _Mixi88MiniCard extends StatelessWidget {
  const _Mixi88MiniCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red, Color(0xFF1A1A1A)],
        ),
        boxShadow: [
          BoxShadow(color: Colors.red.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.casino_rounded, color: Colors.white, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    'MIXI88',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      letterSpacing: 2,
                    ),
                  ),
                  const Text(
                    'UY TÍN SỐ 1',
                    style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'NHẬN 88K',
                      style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            // Hiệu ứng nhấp nháy troll
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('💰 Mixi88 hân hạnh tài trợ! Nạp VIP để tắt quảng cáo này.'),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSearchTap, required this.onProfileTap});
  final VoidCallback onSearchTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppBranding.appName.toUpperCase(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      )),
                  const SizedBox(height: 4),
                  Text(AppBranding.homeGreeting, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            InkWell(
              onTap: onProfileTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
                  boxShadow: [
                    if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Icon(Icons.person_outline_rounded, color: theme.colorScheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: onSearchTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
              boxShadow: [
                if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 6)),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: theme.colorScheme.primary, size: 22),
                const SizedBox(width: 14),
                Text('Tìm phim, thể loại...', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.movie, required this.onOpenDetails, required this.onPlay});
  final Movie movie;
  final VoidCallback onOpenDetails;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        image: DecorationImage(image: NetworkImage(movie.backdropUrl), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.9), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.9), borderRadius: BorderRadius.circular(10)),
              child: const Text('PHIM NỔI BẬT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Text(movie.title, style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('${movie.year} • ${movie.durationLabel} • ${movie.ratingLabel}',
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: PrimaryButton(label: 'Xem ngay', icon: Icons.play_arrow_rounded, onPressed: onPlay)),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onOpenDetails,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Chi tiết'),
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(section.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(section.subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
