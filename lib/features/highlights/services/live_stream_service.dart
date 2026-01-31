import 'package:cloud_firestore/cloud_firestore.dart';

class LiveStream {
  final bool isLive;
  final String? url;
  final String? title;
  final int amemCount;
  final int heartCount;
  final DateTime? scheduledStartTime; // NOVO: Hora marcada para o início

  LiveStream({
    required this.isLive, 
    this.url, 
    this.title,
    this.amemCount = 0,
    this.heartCount = 0,
    this.scheduledStartTime,
  });

  factory LiveStream.fromMap(Map<String, dynamic> map) {
    return LiveStream(
      isLive: map['isLive'] ?? false,
      url: map['url'],
      title: map['title'] ?? 'Culto IEADAO Tsalala',
      amemCount: map['amemCount'] ?? 0,
      heartCount: map['heartCount'] ?? 0,
      scheduledStartTime: (map['scheduledStartTime'] as Timestamp?)?.toDate(),
    );
  }
}

class LiveStreamService {
  final _db = FirebaseFirestore.instance.collection('live_stream').doc('config');

  /// Escuta o estado da live em tempo real
  Stream<LiveStream> watchLiveStatus() {
    return _db.snapshots().map((snap) {
      if (!snap.exists) return LiveStream(isLive: false);
      return LiveStream.fromMap(snap.data()!);
    });
  }

  /// Agenda ou Inicia a live
  Future<void> setLiveConfig({
    required bool status, 
    String? url, 
    String? title,
    DateTime? scheduledTime,
  }) async {
    await _db.set({
      'isLive': status,
      'url': url,
      'title': title,
      'scheduledStartTime': scheduledTime != null ? Timestamp.fromDate(scheduledTime) : null,
      'amemCount': status ? 0 : FieldValue.delete(), // Reinicia se estiver iniciando agora
      'heartCount': status ? 0 : FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Limpa as configurações da live
  Future<void> stopLive() async {
    await _db.set({
      'isLive': false,
      'scheduledStartTime': null,
      'url': null,
    }, SetOptions(merge: true));
  }

  /// Adiciona uma reação de Fé (Amém)
  Future<void> sendAmem() async {
    await _db.update({'amemCount': FieldValue.increment(1)});
  }

  /// Adiciona uma reação de Amor (Coração)
  Future<void> sendHeart() async {
    await _db.update({'heartCount': FieldValue.increment(1)});
  }
}
