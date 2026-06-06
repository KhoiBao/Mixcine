import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/movie.dart';
import 'app_providers.dart';

final movieDetailProvider = FutureProvider.family<Movie, int>((ref, movieId) {
  return ref.read(getMovieDetailUseCaseProvider).call(movieId);
});
