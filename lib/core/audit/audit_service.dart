import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/audit_log_model.dart';

class AuditService {
  final _db = FirebaseFirestore.instance.collection('audit_logs');

  /// Grava uma nova ação na auditoria
  Future<void> log({
    required String userId,
    required String userName,
    required String action,
    required String module,
    required String description,
  }) async {
    final log = AuditLog(
      id: '',
      userId: userId,
      userName: userName,
      action: action,
      module: module,
      description: description,
      timestamp: DateTime.now(),
    );

    await _db.add(log.toMap());
  }

  /// Escuta os logs em tempo real (ordenados pelo mais recente)
  Stream<List<AuditLog>> watchLogs() {
    return _db.orderBy('timestamp', descending: true).snapshots().map(
      (snap) => snap.docs.map((doc) => AuditLog.fromMap(doc.id, doc.data())).toList(),
    );
  }
}
