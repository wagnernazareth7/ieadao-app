import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/current_user_provider.dart';
import '../services/journal_service.dart';
import '../models/journal_entry_model.dart';

final journalServiceProvider = Provider((ref) => JournalService());

/// PROVIDER BLINDADO: Escuta apenas o diário do utilizador autenticado
final myJournalProvider = StreamProvider<List<JournalEntry>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final service = ref.watch(journalServiceProvider);

  return userAsync.maybeWhen(
    data: (user) {
      if (user == null) return Stream.value([]);
      // Sincronização rigorosa com o UID do utilizador logado
      return service.watchMyJournal(user.uid);
    },
    orElse: () => Stream.value([]),
  );
});
