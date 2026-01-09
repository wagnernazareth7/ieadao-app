import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/membro.dart';
import '../../../core/providers/service_providers.dart'; // Importa o serviceProvider centralizado

/// Provider reativo para a lista TOTAL de membros (Ativos e Inativos)
/// O Administrador precisa de ambos para a gestão completa através de abas (Tabs)
final membersListProvider = StreamProvider<List<Membro>>((ref) {
  // CORREÇÃO: Usamos o service provider que já está definido no core/providers/service_providers.dart
  final service = ref.watch(memberServiceProvider);
  
  // Buscamos todos os registros para permitir filtros dinâmicos na UI (Ativos/Inativos)
  return service.watchMembers(activeOnly: false); 
});

/// Provider para buscar um membro específico pelo ID
final memberByIdProvider = FutureProvider.family<Membro?, String>((ref, id) {
  final service = ref.watch(memberServiceProvider);
  return service.getMemberById(id);
});

/// Provider para os aniversariantes do dia
/// Otimizado para alimentar o banner festivo do Dashboard
final birthdaysTodayProvider = StreamProvider<List<Membro>>((ref) {
  final service = ref.watch(memberServiceProvider);
  return service.watchBirthdaysToday();
});
