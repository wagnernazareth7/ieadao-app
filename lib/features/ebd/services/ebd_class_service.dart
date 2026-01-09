import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firestore_service.dart';
import '../models/ebd_class.dart';

class EbdClassService {
  final _classes = FirestoreService.firestore.collection('ebd_classes');

  /// Escuta mudanças nas turmas ativas
  Stream<List<EbdClass>> watchClasses() {
    return _classes
        .where('active', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => EbdClass.fromMap(doc.id, doc.data())).toList());
  }

  /// Cria uma nova turma
  Future<void> createClass(EbdClass ebdClass) async {
    await _classes.add(ebdClass.toMap());
  }

  /// Atualiza dados de uma turma (incluindo alunos e professores)
  Future<void> updateClass(String id, Map<String, dynamic> data) async {
    await _classes.doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Desativação lógica da turma
  Future<void> deactivateClass(String id) async {
    await _classes.doc(id).update({'active': false});
  }
}
