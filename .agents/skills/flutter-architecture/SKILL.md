---
name: flutter-architecture
description: Flutter project architecture patterns and setup conventions for the 5STR Business Discovery Platform rebuild
---

# Flutter Architecture Skill

## Overview

This skill defines the architecture patterns, project conventions, and setup procedures for building the 5STR Business Discovery Platform in Flutter. The app is a feature-rich business discovery platform targeting Bangladesh, connecting to an existing Laravel backend API.

## Architecture: Clean Architecture with Riverpod

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│  (Screens, Widgets, Providers)      │
├─────────────────────────────────────┤
│          Domain Layer               │
│  (Repositories Interfaces, Entities)│
├─────────────────────────────────────┤
│           Data Layer                │
│  (Models, API Service, Cache)       │
└─────────────────────────────────────┘
```

### Layer Responsibilities

#### Data Layer (`lib/data/`)
- **Models**: JSON-serializable data classes with `fromJson`/`toJson`
- **Repositories**: Concrete implementations that call API and manage caching
- **Services**: Low-level services (HTTP client, local storage, location)

#### Presentation Layer (`lib/presentation/`)
- **Providers**: Riverpod providers managing state for each feature
- **Screens**: Full page widgets organized by feature
- **Widgets**: Reusable UI components (cards, modals, common)

#### Core Layer (`lib/core/`)
- **Config**: API endpoints, app constants, theme configuration
- **Network**: Dio client setup with interceptors
- **Router**: GoRouter route definitions
- **Theme**: ThemeData definitions for light/dark mode
- **Utils**: Helper functions (date formatting, distance calc, image utils)

## Project Setup Steps

### 1. Create Flutter Project

```bash
flutter create --org com.fivestr --project-name five_str ./
```

### 2. Core Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  
  # Navigation
  go_router: ^14.2.0
  
  # Networking
  dio: ^5.4.3+1
  
  # Local Storage
  shared_preferences: ^2.2.3
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Location
  geolocator: ^12.0.0
  geocoding: ^3.0.0
  
  # UI Components
  cached_network_image: ^3.3.1
  flutter_svg: ^2.0.10+1
  shimmer: ^3.0.0
  smooth_page_indicator: ^1.1.0
  flutter_staggered_grid_view: ^0.7.0
  
  # Maps
  flutter_map: ^6.1.0
  latlong2: ^0.9.1
  
  # Image Handling
  image_picker: ^1.0.7
  
  # Icons
  ionicons: ^0.2.2
  
  # Utilities
  intl: ^0.19.0
  url_launcher: ^6.2.5
  flutter_rating_bar: ^4.0.1
  google_sign_in: ^6.2.1
  
  # Environment
  flutter_dotenv: ^5.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.2
  build_runner: ^2.4.9
  riverpod_generator: ^2.4.0
  hive_generator: ^2.0.1
```

### 3. Environment Configuration

Create `.env` file:
```
API_BASE_URL=http://127.0.0.1:8000
```

Load in `main.dart`:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(const ProviderScope(child: FiveStrApp()));
}
```

### 4. Dio Client Setup

```dart
// lib/core/network/dio_client.dart
class DioClient {
  late final Dio _dio;
  
  DioClient({required AuthService authService}) {
    _dio = Dio(BaseOptions(
      baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await authService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await authService.clearToken();
          // Navigate to login
        }
        handler.next(error);
      },
    ));
  }
}
```

### 5. GoRouter Configuration

```dart
// lib/core/router/app_router.dart
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/discover', builder: (_, __) => const DiscoverScreen()),
          GoRoute(path: '/favourites', builder: (_, __) => const FavouritesScreen()),
          GoRoute(path: '/collections', builder: (_, __) => const CollectionsScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
      GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
      GoRoute(path: '/business/:id', builder: (_, state) => BusinessDetailScreen(id: state.pathParameters['id']!)),
      GoRoute(path: '/attraction/:id', builder: (_, state) => AttractionDetailScreen(id: state.pathParameters['id']!)),
      GoRoute(path: '/category/:id', builder: (_, state) => CategoryScreen(id: state.pathParameters['id']!)),
      GoRoute(path: '/collection/:id', builder: (_, state) => CollectionDetailScreen(id: state.pathParameters['id']!)),
      GoRoute(path: '/offering/:businessId/:offeringId', builder: (_, state) => OfferingDetailScreen(
        businessId: state.pathParameters['businessId']!,
        offeringId: state.pathParameters['offeringId']!,
      )),
      GoRoute(path: '/offer/:id', builder: (_, state) => OfferDetailScreen(id: state.pathParameters['id']!)),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/reviews/write', builder: (_, __) => const WriteReviewScreen()),
      // ... more routes
    ],
  );
});
```

## Model Pattern

All models should follow this pattern:

```dart
class BusinessModel {
  final int id;
  final String businessName;
  final String slug;
  final String? description;
  final String? area;
  final String? city;
  final String overallRating;
  final int priceRange;
  final String? categoryName;
  final bool isVerified;
  final String? distanceKm;
  final BusinessImages? images;
  final CategoryInfo? category;

  const BusinessModel({
    required this.id,
    required this.businessName,
    required this.slug,
    this.description,
    this.area,
    this.city,
    required this.overallRating,
    required this.priceRange,
    this.categoryName,
    this.isVerified = false,
    this.distanceKm,
    this.images,
    this.category,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'] as int,
      businessName: json['business_name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      area: json['area'] as String?,
      city: json['city'] as String?,
      overallRating: json['overall_rating']?.toString() ?? '0',
      priceRange: json['price_range'] as int? ?? 0,
      categoryName: json['category_name'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      distanceKm: json['distance_km']?.toString(),
      images: json['images'] != null ? BusinessImages.fromJson(json['images']) : null,
      category: json['category'] != null ? CategoryInfo.fromJson(json['category']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'business_name': businessName,
    'slug': slug,
    'description': description,
    // ... etc
  };
}
```

## Provider Pattern

```dart
// lib/presentation/providers/home_provider.dart

// State class
class HomeState {
  final bool isLoading;
  final String? error;
  final List<BannerModel> banners;
  final List<CategoryModel> topServices;
  final List<BusinessModel> popularNearby;
  final List<BusinessModel> featuredBusinesses;
  final List<AttractionModel> featuredAttractions;
  // ... etc

  const HomeState({
    this.isLoading = true,
    this.error,
    this.banners = const [],
    this.topServices = const [],
    this.popularNearby = const [],
    this.featuredBusinesses = const [],
    this.featuredAttractions = const [],
  });

  HomeState copyWith({...}) => HomeState(...);
}

// Provider
class HomeNotifier extends StateNotifier<HomeState> {
  final HomeRepository _repository;
  
  HomeNotifier(this._repository) : super(const HomeState());

  Future<void> loadHomeData({
    required double latitude,
    required double longitude,
    int radius = 10,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.getHomeData(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
      state = state.copyWith(
        isLoading: false,
        banners: response.banners,
        topServices: response.topServices,
        popularNearby: response.popularNearby,
        // ... etc
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(ref.read(homeRepositoryProvider));
});
```

## Key Implementation Notes

1. **Always check `success` field** in API responses before accessing `data`
2. **Handle nullable fields** — many API fields can be null
3. **Image URLs** may be relative paths — prepend base URL if needed
4. **Location validation** — always check Bangladesh bounds before API calls
5. **Token persistence** — store auth token in SharedPreferences, load on app start
6. **Pull-to-refresh** — implement on all list screens
7. **Infinite scroll** — implement pagination on all paginated endpoints
8. **Skeleton loading** — show skeletons during initial data fetch, not spinners
9. **Error recovery** — show retry buttons on error states
10. **Offline support** — cache critical data (home screen, categories) locally
