import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/attraction_repository.dart';
import '../../data/repositories/business_repository.dart';
import '../../data/repositories/home_repository.dart';
import '../../data/repositories/review_repository.dart';
import '../../data/repositories/search_repository.dart';
import 'core_providers.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.read(dioClientProvider));
});

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return BusinessRepository(ref.read(dioClientProvider));
});

final attractionRepositoryProvider = Provider<AttractionRepository>((ref) {
  return AttractionRepository(ref.read(dioClientProvider));
});

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(ref.read(dioClientProvider));
});

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository(ref.read(dioClientProvider));
});
