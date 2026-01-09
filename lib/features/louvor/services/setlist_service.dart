import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/setlist_model.dart';

class SetlistService {
  final _db = FirebaseFirestore.instance.collection('setlists');

  /// Cria ou atualiza uma setlist completa.
  Future<void> saveSetlist(Setlist setlist) async {
    if (setlist.id.isEmpty) {
      await _db.add(setlist.toMap());
    } else {
      await _db.doc(setlist.id).update(setlist.toMap());
    }
  }

  /// Escuta as próximas setlists agendadas.
  Stream<List<Setlist>> watchUpcomingSetlists() {
    return _db
        .where('date', isGreaterThanOrEqualTo: DateTime.now())
        .orderBy('date', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Setlist.fromMap(doc.id, doc.data())).toList());
  }

  /// Busca uma setlist específica por ID.
  Stream<Setlist?> watchSetlistById(String id) {
    return _db.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Setlist.fromMap(doc.id, doc.data()!);
    });
  }

  /// Deleta uma setlist.
  Future<void> deleteSetlist(String id) async {
    await _db.doc(id).delete();
  }
}
