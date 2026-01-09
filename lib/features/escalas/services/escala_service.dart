import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/models/escala_model.dart';
import '../../../core/audit/audit_service.dart';

class EscalaService {
  final _db = FirebaseFirestore.instance.collection('escalas');
  final _audit = AuditService();

  /// Escuta escalas futuras
  Stream<List<Escala>> watchUpcomingEscalas() {
    return _db
        .where('data', isGreaterThanOrEqualTo: DateTime.now())
        .orderBy('data', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Escala.fromMap(doc.id, doc.data())).toList());
  }

  /// Salva ou atualiza uma escala
  Future<void> saveEscala(Escala escala) async {
    final user = FirebaseAuth.instance.currentUser;
    final data = escala.toMap();

    if (escala.id.isEmpty) {
      final docRef = await _db.add(data);
      await _audit.log(
        userId: user?.uid ?? 'system',
        userName: user?.email?.split('@')[0] ?? 'Admin',
        action: 'CRIAR_ESCALA',
        module: 'Escalas',
        description: 'Organizou escala para o dia: ${escala.data}',
      );
    } else {
      await _db.doc(escala.id).update(data);
      await _audit.log(
        userId: user?.uid ?? 'system',
        userName: user?.email?.split('@')[0] ?? 'Admin',
        action: 'EDITAR_ESCALA',
        module: 'Escalas',
        description: 'Alterou escala do dia: ${escala.data}',
      );
    }
  }

  Future<void> deleteEscala(String id) async {
    await _db.doc(id).delete();
  }
}
