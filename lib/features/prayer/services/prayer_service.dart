import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ieadao/core/models/prayer_request_model.dart';

class PrayerService {
  final _db = FirebaseFirestore.instance.collection('prayer_requests');

  /// Escuta pedidos de oração públicos
  Stream<List<PrayerRequest>> watchPublicPrayers() {
    return _db
        .where('isPublic', isEqualTo: true)
        .snapshots(includeMetadataChanges: true)
        .map((snap) {
          final list = snap.docs.map((doc) {
            final data = doc.data();
            if (data['createdAt'] == null) data['createdAt'] = Timestamp.now();
            return PrayerRequest.fromMap(doc.id, data);
          }).toList();

          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  /// Escuta pedidos de oração do próprio utilizador
  Stream<List<PrayerRequest>> watchMyPrayers(String userId) {
    return _db
        .where('userId', isEqualTo: userId)
        .snapshots(includeMetadataChanges: true)
        .map((snap) {
          final list = snap.docs.map((doc) {
            final data = doc.data();
            if (data['createdAt'] == null) data['createdAt'] = Timestamp.now();
            return PrayerRequest.fromMap(doc.id, data);
          }).toList();

          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Future<void> addRequest(PrayerRequest request) async {
    final Map<String, dynamic> data = request.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _db.add(data);
  }

  /// CORREÇÃO SÉNIOR: Lógica de Intercessão Única (Toggle)
  Future<void> prayForRequest(String requestId, bool alreadyPraying) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = _db.doc(requestId);

    if (alreadyPraying) {
      // Se já estava orando, remove o ID da lista
      await docRef.update({
        'prayingUserIds': FieldValue.arrayRemove([user.uid]),
      });
    } else {
      // Se não estava orando, adiciona o ID à lista (Unicidade garantida pelo Firestore)
      await docRef.update({
        'prayingUserIds': FieldValue.arrayUnion([user.uid]),
      });
    }
  }
}
