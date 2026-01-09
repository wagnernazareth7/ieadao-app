import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/music_model.dart';

class CoralService {
  final _db = FirebaseFirestore.instance;

  /// --- GESTÃO DE MÚSICAS ---
  
  Stream<List<Music>> watchRepertoire() {
    return _db.collection('coral_music')
        .orderBy('title')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Music.fromMap(doc.id, doc.data())).toList());
  }

  Future<void> addMusic(Music music) async {
    await _db.collection('coral_music').add(music.toMap());
  }

  /// --- GESTÃO DE ENSAIOS ---

  Stream<QuerySnapshot> watchNextRehearsal() {
    return _db.collection('eventos')
        .where('categoria', isEqualTo: 'Coral')
        .where('data', isGreaterThanOrEqualTo: DateTime.now())
        .orderBy('data')
        .limit(1)
        .snapshots();
  }

  Future<void> scheduleRehearsal(DateTime date, String description) async {
    await _db.collection('eventos').add({
      'titulo': 'Ensaio do Coral',
      'descricao': description,
      'data': Timestamp.fromDate(date),
      'local': 'Igreja Sede',
      'categoria': 'Coral',
      'createdBy': 'Líder Coral',
    });
  }
}
