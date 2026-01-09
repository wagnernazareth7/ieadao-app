import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/membro.dart';

class MembrosRepository {
  // Garantir que a coleção no Firestore se chama exatamente 'membros'
  final _db = FirebaseFirestore.instance.collection('membros');

  Stream<List<Membro>> watchMembros({bool apenasAtivos = true}) {
    // CORREÇÃO: Usar o campo 'active' (boolean) que definimos no modelo
    return _db
        .where('active', isEqualTo: apenasAtivos)
        .snapshots()
        .map(
          (snapshot) =>
          snapshot.docs.map((doc) => Membro.fromFirestore(doc)).toList(),
    );
  }

  Stream<Membro?> watchMembroById(String id) {
    return _db.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Membro.fromFirestore(doc);
    });
  }

  Future<void> addMembro(Membro m) async => await _db.add(m.toMap());

  Future<void> updateMembro(Membro m) async => await _db.doc(m.id).update(m.toMap());

  Future<void> desativarMembro(String id) async {
    await _db.doc(id).update({
      'active': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> ativarMembro(String id) async {
    await _db.doc(id).update({
      'active': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> atualizarCargo(String id, String novoCargo) async {
    await _db.doc(id).update({
      'role': novoCargo,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
