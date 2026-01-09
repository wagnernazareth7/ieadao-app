import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/audit_log_model.dart';

final auditLogsProvider = StreamProvider<List<AuditLog>>((ref) {
  return FirebaseFirestore.instance
      .collection('audit_logs')
      .orderBy('timestamp', descending: true) // CORRIGIDO: Nome do campo conforme modelo
      .limit(100) // Limite de segurança para performance
      .snapshots()
      .map((snap) => snap.docs.map((doc) => AuditLog.fromMap(doc.id, doc.data())).toList()); // CORRIGIDO: Chamada do factory conforme modelo
});
