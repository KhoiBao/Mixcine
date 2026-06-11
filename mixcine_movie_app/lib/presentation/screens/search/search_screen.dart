import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/favorites_provider.dart';
import '../../providers/search_provider.dart';
import '../../widgets/branded_screen_header.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/movie_poster_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final favoriteIds = ref.watch(favoriteIdsProvider).value ?? <int>{};
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth >= 600 ? 3 : 2;

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const BrandedScreenHeader(title: 'Tìm kiếm', subtitle: 'Khám phá kho phim khổng lồ'),
                  const SizedBox(height: 24),
                  
                  // 💡 Thanh tìm kiếm hiện đại
                  TextField(
                    controller: _controller,
                    onChanged: ref.read(searchProvider.notifier).updateQuery,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Tên phim, đạo diễn, thể loại...',
                      prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
                      suffixIcon: searchState.query.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _controller.clear();
                                ref.read(searchProvider.notifier).clear();
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 💡 Nhãn thể loại (Chips)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <String>['Khoa học - viễn tưởng', 'Drama', 'Hành động', 'Hài', 'Gia đình', 'Phiêu lưu', 'Giả tưởng', 'Hoạt hình', 'Kinh dị', 'Lịch sử', 'GAY cấn', 'Tội phạm', 'Tài liệu', 'Huyền bí', 'Âm nhạc', 'Lãng mạn', 'Chiến tranh'].map((genre) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            label: Text(genre),
                            onPressed: () {
                              _controller.text = genre;
                              ref.read(searchProvider.notifier).updateQuery(genre);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (searchState.query.isEmpty) {
                          return const EmptyStateView(
                            icon: Icons.travel_explore_rounded,
                            title: 'Bắt đầu khám phá',
                            subtitle: 'Nhập tên phim bạn muốn xem ngay.',
                          );
                        }

                        if (searchState.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (searchState.results.isEmpty) {
                          return const EmptyStateView(
                            icon: Icons.search_off_rounded,
                            title: 'Không tìm thấy phim',
                            subtitle: 'Thử lại với từ khóa khác nhé.',
                          );
                        }

                        return GridView.builder(
                          itemCount: searchState.results.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 18,
                            childAspectRatio: 0.58,
                          ),
                          itemBuilder: (context, index) {
                            final movie = searchState.results[index];
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
      ),
    );
  }
}
