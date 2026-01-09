import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/notice_model.dart';

final _firestore = FirebaseFirestore.instance;

// Stream de todos os avisos (Ordenados por data descendente)
final allNoticesProvider = StreamProvider<List<Notice>>((ref) {
  return _firestore
      .collection('notices')
      .orderBy('date', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => Notice.fromMap(doc.id, doc.data())).toList());
});

class NoticesController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveNotice(Notice notice) async {
    if (notice.id.isEmpty) {
      await _db.collection('notices').add(notice.toMap());
    } else {
      await _db.collection('notices').doc(notice.id).update(notice.toMap());
    }
  }

  Future<void> deleteNotice(String id) async {
    await _db.collection('notices').doc(id).delete();
  }
}

final noticesControllerProvider = Provider((ref) => NoticesController());
