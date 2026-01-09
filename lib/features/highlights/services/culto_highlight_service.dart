import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/culto_highlight_model.dart';

class CultoHighlightService {
  final _db = FirebaseFirestore.instance.collection('highlights');
  final _storage = FirebaseStorage.instance;

  /// Upload genérico para qualquer tipo de arquivo (image, video, audio)
  Future<String> uploadFile(File file, String folder, String fileName) async {
    final ref = _storage.ref().child('highlights/$folder/$fileName');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> publishHighlight(CultoHighlight highlight) async {
    await _db.add(highlight.toMap());
  }

  Stream<List<CultoHighlight>> watchHighlights() {
    return _db.orderBy('createdAt', descending: true).snapshots().map(
      (snap) => snap.docs.map((doc) => CultoHighlight.fromMap(doc.id, doc.data())).toList(),
    );
  }
}
