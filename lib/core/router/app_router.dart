import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/screens/main_shell.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/discover/discover_screen.dart';
import '../../presentation/screens/favourites/favourites_screen.dart';
import '../../presentation/screens/collections/collections_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../data/models/business_model.dart';
import '../../presentation/screens/business/business_detail_screen.dart';
import '../../presentation/screens/attraction/attraction_detail_screen.dart';
import '../../presentation/screens/category/category_screen.dart';
import '../../data/models/category_model.dart';
import '../../presentation/screens/notification/notifications_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // ── Auth routes ──
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),

      // ── Main tab shell ──
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/discover',
            builder: (context, state) => const DiscoverScreen(),
          ),
          GoRoute(
            path: '/favourites',
            builder: (context, state) => const FavouritesScreen(),
          ),
          GoRoute(
            path: '/collections',
            builder: (context, state) => const CollectionsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // ── Detail screens ──
      GoRoute(
        path: '/search',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/business/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => BusinessDetailScreen(
          businessId: int.parse(state.pathParameters['id']!),
          initialBusiness: state.extra as BusinessModel?,
        ),
      ),
      GoRoute(
        path: '/attraction/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => AttractionDetailScreen(
          id: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/category/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => CategoryScreen(
          id: int.parse(state.pathParameters['id']!),
          initialCategory: state.extra as CategoryModel?,
        ),
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
});
