import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/search_repository.dart';
import 'location_provider.dart';
import 'repository_providers.dart';

class SearchState {
  final String query;
  final bool isLoading;
  final String? error;
  final SearchResults? results;
  final List<SearchSuggestion> suggestions;

  const SearchState({
    this.query = '',
    this.isLoading = false,
    this.error,
    this.results,
    this.suggestions = const [],
  });

  SearchState copyWith({
    String? query,
    bool? isLoading,
    String? error,
    SearchResults? results,
    List<SearchSuggestion>? suggestions,
  }) {
    return SearchState(
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      results: results ?? this.results,
      suggestions: suggestions ?? this.suggestions,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final SearchRepository _repository;
  final Ref _ref;
  Timer? _debounceTimer;

  SearchNotifier(this._repository, this._ref) : super(const SearchState());

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void setQuery(String query) {
    if (state.query == query) return;

    state = state.copyWith(query: query);

    _debounceTimer?.cancel();
    if (query.length >= 2) {
      _debounceTimer = Timer(const Duration(milliseconds: 400), () {
        _fetchSuggestions(query);
      });
    } else {
      state = state.copyWith(suggestions: [], results: null);
    }
  }

  Future<void> _fetchSuggestions(String query) async {
    try {
      final suggestions = await _repository.getSuggestions(query);
      if (state.query == query) {
        state = state.copyWith(suggestions: suggestions);
      }
    } catch (_) {
      // Ignore errors for suggestions
    }
  }

  Future<void> performSearch() async {
    if (state.query.isEmpty) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final location = _ref.read(locationProvider).apiCoordinates;
      final results = await _repository.search(
        query: state.query,
        latitude: location.latitude,
        longitude: location.longitude,
      );

      state = state.copyWith(
        isLoading: false,
        results: results,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearSearch() {
    state = const SearchState();
  }
}

final searchProvider = StateNotifierProvider.autoDispose<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref.read(searchRepositoryProvider), ref);
});
