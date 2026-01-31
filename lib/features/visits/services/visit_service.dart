import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/visit_request_model.dart';

class VisitService {
  final _db = FirebaseFirestore.instance.collection('visit_requests');

  /// Envia um novo pedido de visita
  Future<void> submitRequest(VisitRequest request) async {
    await _db.add(request.toMap());
  }

  /// Escuta os pedidos do usuário logado
  Stream<List<VisitRequest>> watchMyRequests(String userId) {
    return _db
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => VisitRequest.fromMap(doc.id, doc.data())).toList());
  }

  /// Escuta todos os pedidos (Para Administração/Diáconos)
  Stream<List<VisitRequest>> watchAllRequests() {
    return _db
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => VisitRequest.fromMap(doc.id, doc.data())).toList());
  }

  /// Atualiza o status ou agenda uma data
  Future<void> updateRequestStatus(String id, VisitStatus status, {DateTime? date}) async {
    await _db.doc(id).update({
      'status': status.name,
      'scheduledDate': date != null ? Timestamp.fromDate(date) : null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
