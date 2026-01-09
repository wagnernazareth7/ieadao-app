import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id; // Firestore usa IDs do tipo String
  final String channel;
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.channel,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  factory Message.fromMap(String id, Map<String, dynamic> map) {
    return Message(
      id: id,
      channel: map['channel'] ?? '',
      userId: map['user_id'] ?? map['userId'] ?? '', // Suporte a ambos os padrões
      userName: map['user_name'] ?? map['userName'] ?? 'Membro',
      content: map['content'] ?? '',
      createdAt: (map['created_at'] ?? map['createdAt']) is Timestamp 
          ? (map['created_at'] ?? map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'channel': channel,
      'userId': userId,
      'userName': userName,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
