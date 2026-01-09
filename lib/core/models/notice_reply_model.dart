import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeReply {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;

  NoticeReply({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  factory NoticeReply.fromMap(String id, Map<String, dynamic> map) {
    return NoticeReply(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Membro',
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
