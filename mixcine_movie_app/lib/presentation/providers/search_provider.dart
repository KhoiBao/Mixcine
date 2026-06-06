import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/movie.dart';
import 'app_providers.dart';

class SearchState {
  const SearchState({
    required this.query,
    required this.results,
    required this.isLoading,
  });

  final String query;
  final List<Movie> results;
  final bool isLoading;

  factory SearchState.initial() {
    return const SearchState(
      query: '',
      results: <Movie>[],
      isLoading: false,
    );
  }

  SearchState copyWith({
    String? query,
    List<Movie>? results,
    bool? isLoading,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  Timer? _debounce;

  @override
  SearchState build() {
    ref.onDispose(() {
      _debounce?.cancel();
    });
    return SearchState.initial();
  }

  void updateQuery(String value) {
    state = state.copyWith(query: value);
    _debounce?.cancel();

    if (value.trim().isEmpty) {
      state = SearchState.initial();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 350), () async {
      state = state.copyWith(isLoading: true);
      final result = await ref.read(searchMoviesUseCaseProvider).call(value);
      state = state.copyWith(results: result, isLoading: false);
    });
  }

  void clear() {
    _debounce?.cancel();
    state = SearchState.initial();
  }
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(SearchNotifier.new);
