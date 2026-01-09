import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/app_user.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider((ref) {
  return ref.read(authServiceProvider).authStateChanges();
});

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  return ref.read(authServiceProvider).getCurrentUser();
});
