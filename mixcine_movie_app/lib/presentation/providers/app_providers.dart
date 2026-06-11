import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/api_config.dart';
import '../../core/services/app_preferences.dart';
import '../../data/datasources/favorites_local_data_source.dart';
import '../../data/datasources/mock_movie_data_source.dart';
import '../../data/datasources/movie_remote_data_source.dart';
import '../../data/datasources/watch_history_local_data_source.dart';
import '../../data/datasources/review_local_data_source.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../data/repositories/watch_history_repository_impl.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../domain/repositories/watch_history_repository.dart';
import '../../domain/repositories/review_repository.dart';
import '../../domain/usecases/get_discover_movies_usecase.dart';
import '../../domain/usecases/get_favorite_ids_usecase.dart';
import '../../domain/usecases/get_favorite_movies_usecase.dart';
import '../../domain/usecases/get_home_sections_usecase.dart';
import '../../domain/usecases/get_movie_detail_usecase.dart';
import '../../domain/usecases/search_movies_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';

final appPreferencesProvider = Provider<AppPreferences>((ref) => AppPreferences());

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: ApiConfig.tmdbBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));
});

final mockMovieDataSourceProvider = Provider<MockMovieDataSource>((ref) => MockMovieDataSource());
final movieRemoteDataSourceProvider = Provider<MovieRemoteDataSource>((ref) => MovieRemoteDataSource(ref.watch(dioProvider)));

// FAVORITES
final favoritesLocalDataSourceProvider = Provider<FavoritesLocalDataSource>((ref) => FavoritesLocalDataSource());
final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  return MovieRepositoryImpl(
    mockDataSource: ref.watch(mockMovieDataSourceProvider),
    remoteDataSource: ref.watch(movieRemoteDataSourceProvider),
    favoritesLocalDataSource: ref.watch(favoritesLocalDataSourceProvider),
  );
});

// WATCH HISTORY
final watchHistoryDataSourceProvider = Provider<WatchHistoryLocalDataSource>((ref) => WatchHistoryLocalDataSource());
final watchHistoryRepositoryProvider = Provider<WatchHistoryRepository>((ref) {
  return WatchHistoryRepositoryImpl(localDataSource: ref.watch(watchHistoryDataSourceProvider));
});

// REVIEWS
final reviewDataSourceProvider = Provider<ReviewLocalDataSource>((ref) => ReviewLocalDataSource());
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepositoryImpl(localDataSource: ref.watch(reviewDataSourceProvider));
});

// USE CASES
final getHomeSectionsUseCaseProvider = Provider<GetHomeSectionsUseCase>((ref) => GetHomeSectionsUseCase(ref.watch(movieRepositoryProvider)));
final getDiscoverMoviesUseCaseProvider = Provider<GetDiscoverMoviesUseCase>((ref) => GetDiscoverMoviesUseCase(ref.watch(movieRepositoryProvider)));
final getMovieDetailUseCaseProvider = Provider<GetMovieDetailUseCase>((ref) => GetMovieDetailUseCase(ref.watch(movieRepositoryProvider)));
final searchMoviesUseCaseProvider = Provider<SearchMoviesUseCase>((ref) => SearchMoviesUseCase(ref.watch(movieRepositoryProvider)));
final getFavoriteIdsUseCaseProvider = Provider<GetFavoriteIdsUseCase>((ref) => GetFavoriteIdsUseCase(ref.watch(movieRepositoryProvider)));
final toggleFavoriteUseCaseProvider = Provider<ToggleFavoriteUseCase>((ref) => ToggleFavoriteUseCase(ref.watch(movieRepositoryProvider)));
final getFavoriteMoviesUseCaseProvider = Provider<GetFavoriteMoviesUseCase>((ref) => GetFavoriteMoviesUseCase(ref.watch(movieRepositoryProvider)));

class DashboardIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void setIndex(int index) => state = index;
}

final dashboardIndexProvider = NotifierProvider<DashboardIndexNotifier, int>(DashboardIndexNotifier.new);
