import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/review_model.dart';

class ReviewLocalDataSource {
  final _client = Supabase.instance.client;

  Future<void> addReview(
    int movieId,
    String userId, // Phải là UUID
    String authorName,
    String comment,
    double rating,
  ) async {
    await _client.from('reviews').insert({
      'movie_id': movieId,
      'user_id': userId,
      'author_name': authorName,
      'comment': comment,
      'rating': rating,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<List<ReviewModel>> getReviewsForMovie(int movieId) async {
    final response = await _client
        .from('reviews')
        .select()
        .eq('movie_id', movieId)
        .order('created_at', ascending: false);

    return (response as List).map((map) => ReviewModel.fromMap(map)).toList();
  }

  Future<void> deleteReview(int reviewId, String currentUserId) async {
    await _client
        .from('reviews')
        .delete()
        .eq('id', reviewId)
        .eq('user_id', currentUserId); // currentUserId phải là UUID
  }
}
