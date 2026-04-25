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
  final bool showMinCharsMessage;
  final bool searchWholeBangladesh;

  const SearchState({
    this.query = '',
    this.isLoading = false,
    this.error,
    this.results,
    this.suggestions = const [],
    this.showMinCharsMessage = false,
    this.searchWholeBangladesh = false,
  });

  SearchState copyWith({
    String? query,
    bool? isLoading,
    String? error,
    SearchResults? results,
    List<SearchSuggestion>? suggestions,
    bool? showMinCharsMessage,
    bool? searchWholeBangladesh,
    bool clearError = false,
    bool clearResults = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      results: clearResults ? null : (results ?? this.results),
      suggestions: suggestions ?? this.suggestions,
      showMinCharsMessage: showMinCharsMessage ?? this.showMinCharsMessage,
      searchWholeBangladesh: searchWholeBangladesh ?? this.searchWholeBangladesh,
    );
  }

  /// True when we have results and all categories are empty.
  bool get hasNoResults =>
      results != null &&
      results!.businesses.isEmpty &&
      results!.offerings.isEmpty &&
      results!.attractions.isEmpty;
}

class SearchNotifier extends StateNotifier<SearchState> {
  final SearchRepository _repository;
  final Ref _ref;
  Timer? _debounceTimer;
  Timer? _suggestTimer;

  SearchNotifier(this._repository, this._ref) : super(const SearchState());

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _suggestTimer?.cancel();
    super.dispose();
  }

  /// Called on every keystroke.
  void setQuery(String text) {
    if (state.query == text) return;

    _debounceTimer?.cancel();
    _suggestTimer?.cancel();

    if (text.isEmpty) {
      state = const SearchState(); // reset everything
      return;
    }

    if (text.length == 1) {
      state = state.copyWith(
        query: text,
        showMinCharsMessage: true,
        clearResults: true,
        clearError: true,
        suggestions: [],
      );
      return;
    }

    // text.length >= 2
    state = state.copyWith(
      query: text,
      showMinCharsMessage: false,
      isLoading: true,
      clearError: true,
    );

    // Fetch suggestions quickly (400ms)
    _suggestTimer = Timer(const Duration(milliseconds: 400), () {
      _fetchSuggestions(text);
    });

    // Debounce full search (800ms)
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _performSearch(text);
    });
  }

  /// Toggle between local search and whole-Bangladesh search.
  void toggleSearchScope() {
    final newValue = !state.searchWholeBangladesh;
    state = state.copyWith(searchWholeBangladesh: newValue);

    // Re-trigger search if there's an active query
    if (state.query.length >= 2) {
      _debounceTimer?.cancel();
      state = state.copyWith(isLoading: true);
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        _performSearch(state.query);
      });
    }
  }

  /// Perform a full search.
  Future<void> _performSearch(String query) async {
    if (query.length < 2) {
      state = state.copyWith(isLoading: false);
      return;
    }

    try {
      final location = _ref.read(locationProvider).apiCoordinates;
      final results = await _repository.search(
        query: query,
        latitude: state.searchWholeBangladesh ? null : location.latitude,
        longitude: state.searchWholeBangladesh ? null : location.longitude,
        sort: 'rating',
        limit: 10,
      );

      // Only update if query hasn't changed while we were waiting
      if (state.query == query) {
        state = state.copyWith(
          isLoading: false,
          results: results,
          clearError: true,
        );
      }
    } catch (e) {
      if (state.query == query) {
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
        );
      }
    }
  }

  /// Fetch autocomplete suggestions.
  Future<void> _fetchSuggestions(String query) async {
    try {
      final suggestions = await _repository.getSuggestions(query);
      if (state.query == query) {
        state = state.copyWith(suggestions: suggestions);
      }
    } catch (_) {
      // Ignore suggestion errors
    }
  }

  /// Submit a search explicitly (e.g., from suggestion tap or keyboard submit).
  Future<void> performSearch([String? overrideQuery]) async {
    final query = overrideQuery ?? state.query;
    if (query.isEmpty) return;

    _debounceTimer?.cancel();
    _suggestTimer?.cancel();

    state = state.copyWith(
      query: query,
      isLoading: true,
      clearError: true,
      showMinCharsMessage: false,
      suggestions: [],
    );

    await _performSearch(query);
  }

  /// Clear everything.
  void clearSearch() {
    _debounceTimer?.cancel();
    _suggestTimer?.cancel();
    state = SearchState(searchWholeBangladesh: state.searchWholeBangladesh);
  }
}

final searchProvider =
    StateNotifierProvider.autoDispose<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref.read(searchRepositoryProvider), ref);
});
