import 'package:cloud_firestore/cloud_firestore.dart';

class PrayerRequest {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final bool isAnonymous;
  final bool isPublic;
  final List<String> prayingUserIds; // NOVO: Lista de IDs únicos que estão orando
  final DateTime createdAt;

  PrayerRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    this.isAnonymous = false,
    this.isPublic = true,
    this.prayingUserIds = const [],
    required this.createdAt,
  });

  // Getter para manter compatibilidade com a UI antiga
  int get prayingCount => prayingUserIds.length;

  factory PrayerRequest.fromMap(String id, Map<String, dynamic> map) {
    return PrayerRequest(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['isAnonymous'] == true ? 'Anónimo' : (map['userName'] ?? 'Membro'),
      content: map['content'] ?? '',
      isAnonymous: map['isAnonymous'] ?? false,
      isPublic: map['isPublic'] ?? true,
      prayingUserIds: List<String>.from(map['prayingUserIds'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'content': content,
      'isAnonymous': isAnonymous,
      'isPublic': isPublic,
      'prayingUserIds': prayingUserIds,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
