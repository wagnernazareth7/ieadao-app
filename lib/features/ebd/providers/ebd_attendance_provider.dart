import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ebd_attendance.dart';

final _firestore = FirebaseFirestore.instance;

// Provider para buscar presenças de uma classe numa data específica
final classAttendanceByDateProvider = StreamProvider.family<List<EbdAttendance>, ({String classId, String date})>((ref, params) {
  return _firestore
      .collection('ebd_attendance')
      .where('classId', isEqualTo: params.classId)
      .where('date', isEqualTo: params.date)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => EbdAttendance.fromMap(doc.id, doc.data())).toList());
});

// Provider para buscar o histórico de um membro específico
final memberAttendanceHistoryProvider = StreamProvider.family<List<EbdAttendance>, String>((ref, memberId) {
  return _firestore
      .collection('ebd_attendance')
      .where('memberId', isEqualTo: memberId)
      .orderBy('date', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => EbdAttendance.fromMap(doc.id, doc.data())).toList());
});

// Repositório para marcar presenças
class EbdAttendanceRepository {
  Future<void> markAttendance(EbdAttendance attendance) async {
    // Usamos um ID composto para evitar duplicados no mesmo dia para o mesmo aluno
    final docId = "${attendance.classId}_${attendance.memberId}_${attendance.date}";
    await _firestore.collection('ebd_attendance').doc(docId).set(attendance.toMap(), SetOptions(merge: true));
  }
}

final ebdAttendanceRepositoryProvider = Provider((ref) => EbdAttendanceRepository());
