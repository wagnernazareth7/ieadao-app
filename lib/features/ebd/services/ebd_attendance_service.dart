import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firestore_service.dart';
import '../models/ebd_attendance.dart';
import '../models/ebd_certificate_model.dart';
import '../../../core/audit/audit_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EbdAttendanceService {
  final _attendance = FirestoreService.firestore.collection('ebd_attendance');
  final _certificates = FirestoreService.firestore.collection('ebd_certificates');
  final _audit = AuditService();

  /// Escuta presenças por turma
  Stream<List<EbdAttendance>> watchAttendanceByClass(String classId) {
    return _attendance
        .where('classId', isEqualTo: classId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => EbdAttendance.fromMap(doc.id, doc.data())).toList());
  }

  /// NOVO: Escuta presenças por membro (CORREÇÃO PARA O PROVIDER)
  Stream<List<EbdAttendance>> watchAttendanceByMember(String memberId) {
    return _attendance
        .where('memberId', isEqualTo: memberId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) => EbdAttendance.fromMap(doc.id, doc.data())).toList();
          // Ordena por data (mais recente primeiro) no cliente
          list.sort((a, b) => b.date.compareTo(a.date));
          return list;
        });
  }

  /// Calcula percentagem e emite certificado se >= 80%
  Future<EbdCertificate?> checkAndIssueCertificate({
    required String memberId, 
    required String memberName,
    required String classId, 
    required String className,
    required int totalLessons
  }) async {
    if (totalLessons == 0) return null;

    final query = await _attendance
        .where('memberId', isEqualTo: memberId)
        .where('classId', isEqualTo: classId)
        .where('present', isEqualTo: true)
        .get();

    final presents = query.docs.length;
    final rate = (presents / totalLessons) * 100;

    if (rate >= 80) {
      final cert = EbdCertificate(
        id: '', 
        memberId: memberId, 
        memberName: memberName,
        className: className, 
        attendanceRate: rate, 
        issuedAt: DateTime.now()
      );
      
      final docRef = await _certificates.add(cert.toMap());
      
      await _audit.log(
        userId: memberId,
        userName: memberName,
        action: 'CERTIFICADO_EMITIDO',
        module: 'EBD',
        description: 'Atingiu ${rate.toStringAsFixed(1)}% de presença em $className',
      );

      return EbdCertificate.fromMap(docRef.id, cert.toMap());
    }
    return null;
  }

  /// Escuta certificados do usuário
  Stream<List<EbdCertificate>> watchMyCertificates(String memberId) {
    return _certificates
        .where('memberId', isEqualTo: memberId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => EbdCertificate.fromMap(doc.id, doc.data())).toList());
  }

  /// Regista uma presença
  Future<void> markAttendance(EbdAttendance attendance) async {
    final docId = "${attendance.classId}_${attendance.memberId}_${attendance.date}";
    await _attendance.doc(docId).set(attendance.toMap(), SetOptions(merge: true));

    final user = FirebaseAuth.instance.currentUser;
    await _audit.log(
      userId: user?.uid ?? 'system',
      userName: user?.email?.split('@')[0] ?? 'Sistema',
      action: 'MARCAR_PRESENCA',
      module: 'EBD',
      description: 'Registou presença: Aluno ${attendance.memberId} em ${attendance.date}',
    );
  }
}
