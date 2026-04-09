import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/api_config.dart';
import '../../core/config/app_config.dart';
import '../../core/services/app_preferences.dart';
import '../../data/datasources/favorites_local_data_source.dart';
import '../../data/datasources/mock_movie_data_source.dart';
import '../../data/datasources/movie_remote_data_source.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../domain/usecases/get_discover_movies_usecase.dart';
import '../../domain/usecases/get_favorite_ids_usecase.dart';
import '../../domain/usecases/get_favorite_movies_usecase.dart';
import '../../domain/usecases/get_home_sections_usecase.dart';
import '../../domain/usecases/get_movie_detail_usecase.dart';
import '../../domain/usecases/search_movies_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';

final appPreferencesProvider = Provider<AppPreferences>((ref) {
  return AppPreferences();
});

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: ApiConfig.tmdbBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
});

final mockMovieDataSourceProvider = Provider<MockMovieDataSource>((ref) {
  return MockMovieDataSource();
});

final movieRemoteDataSourceProvider = Provider<MovieRemoteDataSource>((ref) {
  return MovieRemoteDataSource(ref.watch(dioProvider));
});

final favoritesLocalDataSourceProvider = Provider<FavoritesLocalDataSource>((ref) {
  return FavoritesLocalDataSource();
});

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  return MovieRepositoryImpl(
    mockDataSource: ref.watch(mockMovieDataSourceProvider),
    remoteDataSource: ref.watch(movieRemoteDataSourceProvider),
    favoritesLocalDataSource: ref.watch(favoritesLocalDataSourceProvider),
  );
});

final getHomeSectionsUseCaseProvider = Provider<GetHomeSectionsUseCase>((ref) {
  return GetHomeSectionsUseCase(ref.watch(movieRepositoryProvider));
});

final getDiscoverMoviesUseCaseProvider = Provider<GetDiscoverMoviesUseCase>((ref) {
  return GetDiscoverMoviesUseCase(ref.watch(movieRepositoryProvider));
});

final getMovieDetailUseCaseProvider = Provider<GetMovieDetailUseCase>((ref) {
  return GetMovieDetailUseCase(ref.watch(movieRepositoryProvider));
});

final searchMoviesUseCaseProvider = Provider<SearchMoviesUseCase>((ref) {
  return SearchMoviesUseCase(ref.watch(movieRepositoryProvider));
});

final getFavoriteIdsUseCaseProvider = Provider<GetFavoriteIdsUseCase>((ref) {
  return GetFavoriteIdsUseCase(ref.watch(movieRepositoryProvider));
});

final toggleFavoriteUseCaseProvider = Provider<ToggleFavoriteUseCase>((ref) {
  return ToggleFavoriteUseCase(ref.watch(movieRepositoryProvider));
});

final getFavoriteMoviesUseCaseProvider = Provider<GetFavoriteMoviesUseCase>((ref) {
  return GetFavoriteMoviesUseCase(ref.watch(movieRepositoryProvider));
});

class DashboardIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

final dashboardIndexProvider = NotifierProvider<DashboardIndexNotifier, int>(
  DashboardIndexNotifier.new,
);
