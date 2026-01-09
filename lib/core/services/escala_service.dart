import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/escala_model.dart';

class EscalaService {
  final _db = FirebaseFirestore.instance.collection('escalas');

  /// Escuta a escala do dia de hoje para um utilizador específico
  Stream<List<Escala>> watchTodayEscala(String userId) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _db
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(todayEnd))
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Escala.fromMap(doc.id, doc.data())).toList());
  }

  /// Cria uma nova escala (Apenas Admin/Direção)
  Future<void> addEscala(Escala escala) async {
    await _db.add(escala.toMap());
  }
}
