import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/ebd_turma.dart';
import '../../core/models/ebd_presenca.dart';

final _firestore = FirebaseFirestore.instance;

// Stream de todas as turmas ativas
final turmasProvider = StreamProvider<List<EBDTurma>>((ref) {
  return _firestore
      .collection('ebd_turmas')
      .where('ativa', isEqualTo: true)
      .snapshots()
      .map((snapshot) =>
      snapshot.docs.map((doc) => EBDTurma.fromMap(doc.id, doc.data())).toList());
});

// Stream das presenças de uma turma hoje
final presencasHojeProvider = StreamProvider.family<List<EBDPresenca>, String>((ref, turmaId) {
  final hoje = DateTime.now();
  final inicioDoDia = DateTime(hoje.year, hoje.month, hoje.day).toIso8601String();
  
  return _firestore
      .collection('ebd_turmas')
      .doc(turmaId)
      .collection('presencas')
      .where('data', isGreaterThanOrEqualTo: inicioDoDia)
      .snapshots()
      .map((snapshot) =>
      snapshot.docs.map((doc) => EBDPresenca.fromMap(doc.id, doc.data())).toList());
});

class EBDController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> criarTurma({required String nome, required String professor}) async {
    await _db.collection('ebd_turmas').add({
      'nome': nome,
      'professor': professor,
      'alunosIds': [],
      'ativa': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> editarTurma(EBDTurma turma) async {
    await _db.collection('ebd_turmas').doc(turma.id).update(turma.toMap());
  }

  Future<void> deleteTurma(String turmaId) async {
    await _db.collection('ebd_turmas').doc(turmaId).delete();
  }

  // Atalho para marcar presença individual (Resolvendo erro na página)
  Future<void> marcarPresenca({
    required String turmaId,
    required String alunoId,
    required bool presente,
  }) async {
    await saveAttendance(turmaId, {alunoId: presente});
  }

  Future<void> saveAttendance(String turmaId, Map<String, bool> attendance) async {
    final batch = _db.batch();
    final hoje = DateTime.now();
    final dataId = "${hoje.year}-${hoje.month}-${hoje.day}";

    attendance.forEach((alunoId, presente) {
      final docRef = _db
          .collection('ebd_turmas')
          .doc(turmaId)
          .collection('presencas')
          .doc('$dataId-$alunoId');

      batch.set(docRef, {
        'alunoId': alunoId,
        'presente': presente,
        'data': hoje.toIso8601String(),
      }, SetOptions(merge: true));
    });

    await batch.commit();
  }
}

final ebdControllerProvider = Provider<EBDController>((ref) => EBDController());
