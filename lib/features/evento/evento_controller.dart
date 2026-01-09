import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'evento_model.dart';
import '../../core/audit/audit_service.dart';

final _firestore = FirebaseFirestore.instance;

// Stream de todos os eventos futuros e recentes
final todosEventosProvider = StreamProvider<List<Evento>>((ref) {
  return _firestore
      .collection('eventos')
      .orderBy('data', descending: false)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => Evento.fromMap(doc.id, doc.data())).toList());
});

class EventoController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _audit = AuditService();

  /// Salva ou atualiza um evento com registo de log consolidado
  Future<void> salvarEvento(Evento evento) async {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.email?.split('@')[0] ?? 'Sistema';

    if (evento.id.isEmpty) {
      final docRef = await _db.collection('eventos').add(evento.toMap());
      
      // CORREÇÃO SÉNIOR: Registro na Auditoria Centralizada
      await _audit.log(
        userId: user?.uid ?? 'system',
        userName: userName,
        action: 'CRIAR_EVENTO',
        module: 'Agenda',
        description: 'Publicou novo evento: ${evento.titulo}',
      );
    } else {
      await _db.collection('eventos').doc(evento.id).update(evento.toMap());
      
      await _audit.log(
        userId: user?.uid ?? 'system',
        userName: userName,
        action: 'EDITAR_EVENTO',
        module: 'Agenda',
        description: 'Alterou detalhes do evento: ${evento.titulo}',
      );
    }
  }

  /// Elimina um evento com registo de log consolidado
  Future<void> eliminarEvento(String id, String titulo) async {
    await _db.collection('eventos').doc(id).delete();

    final user = FirebaseAuth.instance.currentUser;
    await _audit.log(
      userId: user?.uid ?? 'system',
      userName: user?.email?.split('@')[0] ?? 'Sistema',
      action: 'ELIMINAR_EVENTO',
      module: 'Agenda',
      description: 'Removeu permanentemente o evento: $titulo',
    );
  }
}

final eventoControllerProvider = Provider((ref) => EventoController());
