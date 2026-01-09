import 'package:cloud_firestore/cloud_firestore.dart';

class Notice {
  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime date;
  final DateTime? expiresAt; // NOVO: Data de expiração
  final bool priority;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.date,
    this.expiresAt,
    this.priority = false,
  });

  factory Notice.fromMap(String id, Map<String, dynamic> map) {
    return Notice(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      author: map['author'] ?? 'Administração',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate(),
      priority: map['priority'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'author': author,
      'date': Timestamp.fromDate(date),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'priority': priority,
    };
  }
}
