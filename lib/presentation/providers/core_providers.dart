import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/auth_service.dart';
import '../../data/services/location_service.dart';
import '../../core/network/dio_client.dart';

/// Global singleton providers for core services.

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final dioClientProvider = Provider<DioClient>((ref) {
  final authService = ref.read(authServiceProvider);
  return DioClient(authService: authService);
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});
