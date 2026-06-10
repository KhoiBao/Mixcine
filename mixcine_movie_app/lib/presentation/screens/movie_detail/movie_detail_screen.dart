import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/movie_comment.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/movie_detail_provider.dart';
import '../../providers/rating_comment_provider.dart';
import '../../widgets/async_value_builder.dart';
import '../../widgets/primary_button.dart';
import '../../providers/content_access_provider.dart';

class MovieDetailScreen extends ConsumerWidget {
  const MovieDetailScreen({required this.movieId, super.key});

  final int movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final movieState = ref.watch(movieDetailProvider(movieId));
    final favoriteIds = ref.watch(favoriteIdsProvider).value ?? <int>{};
    final contentAccess = ref.watch(contentAccessProvider);
    final int userTier = contentAccess.userTier;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AsyncValueBuilder(
        value: movieState,
        onRetry: () => ref.invalidate(movieDetailProvider(movieId)),
        onData: (movie) {
          final isFavorite = favoriteIds.contains(movie.id);

          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                pinned: true,
                expandedHeight: 320,
                backgroundColor: theme.scaffoldBackgroundColor,
                surfaceTintColor: Colors.transparent,
                leading: BackButton(color: isDark ? Colors.white : Colors.black),
                actions: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: IconButton(
                      onPressed: () => ref.read(favoriteIdsProvider.notifier).toggle(movie.id),
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? AppColors.primary : (isDark ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      CachedNetworkImage(
                        imageUrl: movie.backdropUrl,
                        fit: BoxFit.cover,
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: <Color>[
                              theme.scaffoldBackgroundColor.withOpacity(0.9),
                              Colors.transparent
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: CachedNetworkImage(
                              imageUrl: movie.posterUrl,
                              width: 130,
                              height: 190,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  movie.title,
                                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: <Widget>[
                                    _InfoChip(icon: Icons.calendar_today_rounded, label: movie.year),
                                    _InfoChip(icon: Icons.access_time_rounded, label: movie.durationLabel),
                                    _InfoChip(icon: Icons.star_rounded, label: movie.ratingLabel, isAccent: true),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: movie.genres
                                      .map((genre) => Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: colorScheme.primary.withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(100),
                                              border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
                                            ),
                                            child: Text(
                                              genre,
                                              style: TextStyle(color: colorScheme.primary, fontSize: 11, fontWeight: FontWeight.w600),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: PrimaryButton(
                              label: 'Xem ngay',
                              icon: Icons.play_arrow_rounded,
                              onPressed: () {
                                if (userTier < movie.requiredTier) {
                                  _showPremiumDialog(context, movie.requiredTier);
                                } else {
                                  context.push('/player/${movie.id}');
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                side: BorderSide(color: isFavorite ? AppColors.primary : colorScheme.outline),
                              ),
                              onPressed: () => ref.read(favoriteIdsProvider.notifier).toggle(movie.id),
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                size: 20,
                                color: isFavorite ? AppColors.primary : null,
                              ),
                              label: Text(
                                isFavorite ? 'Đã lưu' : 'Lưu lại',
                                style: TextStyle(color: isFavorite ? AppColors.primary : null),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text('Nội dung phim', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(
                        movie.overview,
                        style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.6),
                      ),
                      const SizedBox(height: 32),
                      _RatingSection(movieId: movie.id, ref: ref),
                      const SizedBox(height: 32),
                      _CommentsSection(movieId: movie.id, ref: ref),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPremiumDialog(BuildContext context, int requiredTier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Nội dung Premium'),
        content: Text(requiredTier == 2
            ? 'Phim này yêu cầu gói VIP (720p). Hãy nâng cấp tài khoản để thưởng thức nhé!'
            : 'Phim bom tấn đặc sắc này yêu cầu gói Vippro. Nâng cấp ngay nào!'),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Để sau')),
          FilledButton(
            onPressed: () {
              context.pop();
              context.push('/subscription');
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Nâng cấp ngay'),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, this.isAccent = false});
  final IconData icon;
  final String label;
  final bool isAccent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isAccent ? Colors.amber : AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _RatingSection extends ConsumerStatefulWidget {
  const _RatingSection({required this.movieId, required this.ref});
  final int movieId;
  final WidgetRef ref;
  @override
  ConsumerState<_RatingSection> createState() => _RatingSectionState();
}

class _RatingSectionState extends ConsumerState<_RatingSection> {
  late double _currentRating;
  @override
  void initState() {
    super.initState();
    _currentRating = ref.read(movieRatingsProvider)[widget.movieId] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Đánh giá phim này', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(10, (index) {
              final rating = index + 1;
              final isSelected = rating <= _currentRating;
              return GestureDetector(
                onTap: () {
                  setState(() => _currentRating = rating.toDouble());
                  ref.read(movieRatingsProvider.notifier).setRating(widget.movieId, rating.toDouble());
                },
                child: Icon(
                  Icons.star_rounded,
                  color: isSelected ? Colors.amber : theme.colorScheme.outline,
                  size: 26,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(_currentRating > 0 ? '$_currentRating / 10 điểm' : 'Hãy cho điểm phim này',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
        ],
      ),
    );
  }
}

class _CommentsSection extends ConsumerStatefulWidget {
  const _CommentsSection({required this.movieId, required this.ref});
  final int movieId;
  final WidgetRef ref;
  @override
  ConsumerState<_CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends ConsumerState<_CommentsSection> {
  final TextEditingController _commentController = TextEditingController();

  void _submitComment() {
    final authState = ref.read(authStateProvider);
    if (authState.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng đăng nhập để bình luận')));
      return;
    }
    if (_commentController.text.trim().isEmpty) return;

    ref.read(movieCommentsProvider.notifier).addComment(
      widget.movieId,
      authState.user!.email,
      authState.user!.fullName ?? authState.user!.email,
      _commentController.text.trim(),
      0,
    );
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(movieCommentsProvider)[widget.movieId] ?? [];
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bình luận', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextField(
          controller: _commentController,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Cảm nhận của bạn về phim...',
            filled: true,
            fillColor: theme.cardTheme.color,
            suffixIcon: IconButton(
              onPressed: _submitComment,
              icon: const Icon(Icons.send_rounded, color: AppColors.primary),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (comments.isEmpty)
          const Center(child: Text('Chưa có bình luận nào. Hãy là người đầu tiên!'))
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: comments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, index) => _CommentTile(comment: comments[index], movieId: widget.movieId),
          ),
      ],
    );
  }
}

class _CommentTile extends ConsumerWidget {
  const _CommentTile({required this.comment, required this.movieId});
  final MovieComment comment;
  final int movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isOwner = comment.userId == ref.watch(authStateProvider).user?.email;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Text(comment.author[0].toUpperCase(), style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comment.author, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    Text(comment.formattedDate, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                  onPressed: () => ref.read(movieCommentsProvider.notifier).deleteComment(movieId, comment.id),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(comment.text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
