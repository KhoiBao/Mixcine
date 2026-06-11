import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/movie_comment.dart';
import 'app_providers.dart';
import 'auth_provider.dart';

// 1. Quản lý điểm đánh giá (Dùng hiển thị trên UI)
final movieRatingsProvider =
    NotifierProvider<MovieRatingsNotifier, Map<int, double>>(
      MovieRatingsNotifier.new,
    );

class MovieRatingsNotifier extends Notifier<Map<int, double>> {
  @override
  Map<int, double> build() => {};

  void setRating(int movieId, double rating) {
    state = {...state, movieId: rating.clamp(0, 10)};
  }
}

// 2. Quản lý bình luận (Kết nối trực tiếp Supabase)
class MovieCommentsNotifier
    extends FamilyAsyncNotifier<List<MovieComment>, int> {
  @override
  Future<List<MovieComment>> build(int movieId) async {
    // Tự động tải bình luận từ Supabase
    return ref.read(reviewRepositoryProvider).getReviewsForMovie(movieId);
  }

  Future<void> addComment(String text, double rating) async {
    final user = ref.read(authStateProvider).user;

    // KIỂM TRA QUAN TRỌNG: Dùng user.id (UUID) thay vì email để tránh lỗi 22P02
    if (user == null || user.id == null) return;

    try {
      await ref
          .read(reviewRepositoryProvider)
          .addReview(
            arg, // movieId
            user.id!, // UUID chuẩn
            user.fullName ?? user.email,
            text,
            rating,
          );

      // Làm mới danh sách sau khi thêm thành công
      ref.invalidateSelf();
    } catch (e) {
      print('Lỗi thêm bình luận: $e');
    }
  }

  Future<void> deleteComment(int reviewId) async {
    final user = ref.read(authStateProvider).user;
    if (user == null || user.id == null) return;

    try {
      await ref.read(reviewRepositoryProvider).deleteReview(reviewId, user.id!);
      ref.invalidateSelf();
    } catch (e) {
      print('Lỗi xóa bình luận: $e');
    }
  }
}

final movieCommentsProvider =
    AsyncNotifierProvider.family<
      MovieCommentsNotifier,
      List<MovieComment>,
      int
    >(MovieCommentsNotifier.new);
