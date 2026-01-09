import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/membros_repository.dart';
import '../models/membro.dart';

final membrosRepositoryProvider = Provider(
      (ref) => MembrosRepository(),
);

// Retorna todos os membros para contagem
final todosMembrosProvider = StreamProvider<List<Membro>>((ref) {
  final repo = ref.watch(membrosRepositoryProvider);
  return repo.watchMembros(apenasAtivos: true);
});

final membrosProviderByStatus = StreamProvider.family<List<Membro>, bool>((ref, apenasAtivos) {
  final repo = ref.watch(membrosRepositoryProvider);
  return repo.watchMembros(apenasAtivos: apenasAtivos);
});

final membroPorIdProvider = StreamProvider.family<Membro?, String>((ref, id) {
  final repo = ref.watch(membrosRepositoryProvider);
  return repo.watchMembroById(id);
});
