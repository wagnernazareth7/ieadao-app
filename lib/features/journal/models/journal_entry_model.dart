import 'package:cloud_firestore/cloud_firestore.dart';

enum JournalType { reflexao, meta, versiculo }

class JournalEntry {
  final String id;
  final String userId;
  final String title;
  final String content;
  final JournalType type;
  final DateTime createdAt;

  JournalEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
  });

  factory JournalEntry.fromMap(String id, Map<String, dynamic> map) {
    return JournalEntry(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? 'Sem Título',
      content: map['content'] ?? '',
      type: JournalType.values.firstWhere((e) => e.name == (map['type'] ?? 'reflexao'), orElse: () => JournalType.reflexao),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'type': type.name,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
