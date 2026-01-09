import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firestore_service.dart';
import '../models/ebd_attendance.dart';
import '../../../core/audit/audit_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EbdAttendanceService {
  final _attendance = FirestoreService.firestore.collection('ebd_attendance');
  final _audit = AuditService();

  /// Escuta presenças por turma com ordenação resiliente
  Stream<List<EbdAttendance>> watchAttendanceByClass(String classId) {
    return _attendance
        .where('classId', isEqualTo: classId)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => EbdAttendance.fromMap(doc.id, doc.data())).toList();
      // Ordenação no cliente para evitar desaparecimento de itens com data nula
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  Stream<List<EbdAttendance>> watchAttendanceByMember(String memberId) {
    return _attendance
        .where('memberId', isEqualTo: memberId)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => EbdAttendance.fromMap(doc.id, doc.data())).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  /// Regista uma presença com log de auditoria corrigido
  Future<void> markAttendance(EbdAttendance attendance) async {
    final docId = "${attendance.classId}_${attendance.memberId}_${attendance.date}";
    await _attendance.doc(docId).set(attendance.toMap(), SetOptions(merge: true));

    final user = FirebaseAuth.instance.currentUser;

    // CORREÇÃO SÉNIOR: Alinhamento com a assinatura do AuditService
    await _audit.log(
      userId: user?.uid ?? 'system',
      userName: user?.email?.split('@')[0] ?? 'Sistema',
      action: 'MARCAR_PRESENCA',
      module: 'EBD',
      description: 'Registou presença: Aluno ${attendance.memberId} em ${attendance.date}',
    );
  }
}