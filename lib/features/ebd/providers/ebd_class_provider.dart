import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ebd_class.dart';

final _firestore = FirebaseFirestore.instance;

// Provider para todas as classes (Admin/Direção)
final allEbdClassesProvider = StreamProvider<List<EbdClass>>((ref) {
  return _firestore
      .collection('ebd_classes')
      .where('active', isEqualTo: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => EbdClass.fromMap(doc.id, doc.data())).toList());
});

// Provider para as classes de um professor específico
final myEbdClassesProvider = StreamProvider<List<EbdClass>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  return _firestore
      .collection('ebd_classes')
      .where('active', isEqualTo: true)
      .where('professorIds', arrayContains: user.uid)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => EbdClass.fromMap(doc.id, doc.data())).toList());
});

// Repositório para ações de escrita
class EbdClassRepository {
  Future<void> saveClass(EbdClass ebdClass) async {
    final docRef = _firestore.collection('ebd_classes').doc(ebdClass.id.isEmpty ? null : ebdClass.id);
    await docRef.set(ebdClass.toMap(), SetOptions(merge: true));
  }

  Future<void> toggleClassStatus(String id, bool active) async {
    await _firestore.collection('ebd_classes').doc(id).update({'active': active});
  }
}

final ebdClassRepositoryProvider = Provider((ref) => EbdClassRepository());
