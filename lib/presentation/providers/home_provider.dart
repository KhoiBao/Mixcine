import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_section.dart';
import 'app_providers.dart';

class HomeState {
  const HomeState({
    required this.sections,
    required this.discoverMovies,
    required this.nextPage,
    required this.hasMore,
    required this.isLoadingMore,
  });

  final List<MovieSection> sections;
  final List<Movie> discoverMovies;
  final int nextPage;
  final bool hasMore;
  final bool isLoadingMore;

  Movie? get heroMovie {
    if (discoverMovies.isNotEmpty) {
      return discoverMovies.first;
    }
    if (sections.isNotEmpty && sections.first.movies.isNotEmpty) {
      return sections.first.movies.first;
    }
    return null;
  }

  HomeState copyWith({
    List<MovieSection>? sections,
    List<Movie>? discoverMovies,
    int? nextPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return HomeState(
      sections: sections ?? this.sections,
      discoverMovies: discoverMovies ?? this.discoverMovies,
      nextPage: nextPage ?? this.nextPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class HomeNotifier extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    final sections = await ref.read(getHomeSectionsUseCaseProvider).call();
    final discover = await ref.read(getDiscoverMoviesUseCaseProvider).call(page: 1);

    return HomeState(
      sections: sections,
      discoverMovies: discover.items,
      nextPage: 2,
      hasMore: discover.hasMore,
      isLoadingMore: false,
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final discover = await ref.read(getDiscoverMoviesUseCaseProvider).call(
            page: current.nextPage,
          );

      state = AsyncData(
        current.copyWith(
          discoverMovies: <Movie>[...current.discoverMovies, ...discover.items],
          nextPage: current.nextPage + 1,
          hasMore: discover.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }
}

final homeProvider = AsyncNotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);
