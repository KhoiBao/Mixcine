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

class MovieDetailScreen extends ConsumerWidget {
  const MovieDetailScreen({required this.movieId, super.key});

  final int movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieState = ref.watch(movieDetailProvider(movieId));
    final favoriteIds = ref.watch(favoriteIdsProvider).value ?? <int>{};

    return Scaffold(
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
                actions: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: IconButton(
                      onPressed: () => ref
                          .read(favoriteIdsProvider.notifier)
                          .toggle(movie.id),
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? AppColors.danger : Colors.white,
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
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: <Color>[Colors.black87, Colors.transparent],
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
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              imageUrl: movie.posterUrl,
                              width: 130,
                              height: 190,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  movie.title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: <Widget>[
                                    _InfoChip(
                                      icon: Icons.calendar_month_outlined,
                                      label: movie.year,
                                    ),
                                    _InfoChip(
                                      icon: Icons.access_time_outlined,
                                      label: movie.durationLabel,
                                    ),
                                    _InfoChip(
                                      icon: Icons.star_rounded,
                                      label: movie.ratingLabel,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: movie.genres
                                      .map(
                                        (genre) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.surface,
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          child: Text(genre),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: PrimaryButton(
                              label: 'Watch now',
                              icon: Icons.play_arrow_rounded,
                              onPressed: () =>
                                  context.push('/player/${movie.id}'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => ref
                                  .read(favoriteIdsProvider.notifier)
                                  .toggle(movie.id),
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                              label: Text(isFavorite ? 'Saved' : 'Save'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Overview',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        movie.overview,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _RatingSection(movieId: movie.id, ref: ref),
                      const SizedBox(height: 24),
                      _CommentsSection(movieId: movie.id, ref: ref),
                      const SizedBox(height: 24),
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
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Rate this movie',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(10, (index) {
              final rating = index + 1;
              final isSelected = rating <= _currentRating;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentRating = rating.toDouble();
                  });
                  ref
                      .read(movieRatingsProvider.notifier)
                      .setRating(widget.movieId, rating.toDouble());
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.star_rounded,
                    color: isSelected ? AppColors.primary : Colors.grey,
                    size: 24,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _currentRating > 0 ? '$_currentRating/10' : 'Rate now',
            style: Theme.of(context).textTheme.bodySmall,
          ),
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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    // ✓ Get current user from auth provider
    final authState = ref.read(authStateProvider);
    if (authState.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add a comment')),
      );
      return;
    }

    if (_commentController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please write a comment')));
      return;
    }

    final userId = authState.user!.email; // ✓ Use email as unique user ID
    final author =
        authState.user!.fullName ?? authState.user!.email; // ✓ Display name

    ref
        .read(movieCommentsProvider.notifier)
        .addComment(
          widget.movieId,
          userId,
          author,
          _commentController.text,
          0, // Không cho phép rating comment của bản thân
        );

    _commentController.clear();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Comment added successfully')));
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(movieCommentsProvider)[widget.movieId] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Comments', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        // Add Comment Form
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Add your comment',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write your comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _submitComment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Post'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Comments List
        if (comments.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No comments yet',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: comments.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final comment = comments[index];
              return _CommentTile(
                comment: comment,
                movieId: widget.movieId,
                ref: ref,
              );
            },
          ),
      ],
    );
  }
}

class _CommentTile extends ConsumerWidget {
  const _CommentTile({
    required this.comment,
    required this.movieId,
    required this.ref,
  });

  final MovieComment comment;
  final int movieId;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✓ Get current user from auth provider
    final authState = ref.watch(authStateProvider);
    final currentUserId = authState.user?.email;
    final isCommentOwner = comment.userId == currentUserId;

    // ✓ Get current user's rating for this comment
    final userCommentRating =
        ref.watch(
          commentRatingsProvider,
        )['${comment.id}:${currentUserId ?? ''}'] ??
        0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      comment.author,
                      style: Theme.of(context).textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        // ✓ Show interactive stars if NOT the comment owner
                        if (!isCommentOwner)
                          Row(
                            children: List.generate(5, (index) {
                              final rating = index + 1;
                              return GestureDetector(
                                onTap: () {
                                  // ✓ Rate comment
                                  ref
                                      .read(commentRatingsProvider.notifier)
                                      .rateComment(
                                        comment.id,
                                        currentUserId ?? '',
                                        rating.toDouble(),
                                      );
                                },
                                child: Icon(
                                  Icons.star_rounded,
                                  size: 16,
                                  color: rating <= userCommentRating
                                      ? AppColors.primary
                                      : Colors.grey,
                                ),
                              );
                            }),
                          ),
                        if (!isCommentOwner) const SizedBox(width: 8),
                        Text(
                          comment.formattedDate,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // ✓ Show delete button only if current user is the comment owner
              if (isCommentOwner)
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () {
                    ref
                        .read(movieCommentsProvider.notifier)
                        .deleteComment(movieId, comment.id);
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.text,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
