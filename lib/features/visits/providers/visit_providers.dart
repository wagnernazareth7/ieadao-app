import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/service_providers.dart';
import '../../auth/providers/current_user_provider.dart';
import '../models/visit_request_model.dart';

/// Provider que expõe os pedidos do usuário logado (Blindado)
final myVisitsProvider = StreamProvider<List<VisitRequest>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final service = ref.watch(visitServiceProvider);

  return userAsync.maybeWhen(
    data: (user) {
      if (user == null) return Stream.value([]);
      return service.watchMyRequests(user.uid);
    },
    orElse: () => Stream.value([]),
  );
});

/// Provider que expõe TODOS os pedidos (Exclusivo para Administração/Diáconos)
final allVisitsProvider = StreamProvider<List<VisitRequest>>((ref) {
  final service = ref.watch(visitServiceProvider);
  return service.watchAllRequests();
});
