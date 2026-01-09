import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/journal_entry_model.dart';

class JournalService {
  final _db = FirebaseFirestore.instance.collection('journal_entries');

  /// Escuta as entradas do usuário logado com FILTRO RÍGIDO
  Stream<List<JournalEntry>> watchMyJournal(String userId) {
    // Se o ID estiver vazio, retorna lista vazia imediatamente por segurança
    if (userId.isEmpty) return Stream.value([]);

    return _db
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((doc) => JournalEntry.fromMap(doc.id, doc.data())).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  /// Grava uma nova entrada vinculada FORÇADAMENTE ao UID logado
  Future<void> saveEntry(JournalEntry entry) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final Map<String, dynamic> data = entry.toMap();
    
    // BLINDAGEM SÉNIOR: Ignora o que veio do objeto e força o UID do sistema
    data['userId'] = currentUser.uid; 
    data['createdAt'] = Timestamp.now();
    
    await _db.add(data);
  }

  Future<void> deleteEntry(String id) async {
    if (id.isEmpty) return;
    
    // O Firebase já vai barrar via Rules se não for o dono, mas limpamos aqui também
    await _db.doc(id).delete();
  }
}
