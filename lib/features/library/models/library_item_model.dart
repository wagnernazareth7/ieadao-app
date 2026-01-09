import 'package:cloud_firestore/cloud_firestore.dart';

enum LibraryType { pdf, audio, video, link }

class LibraryItem {
  final String id;
  final String title;
  final String description;
  final String category; // ex: 'Estudos Bíblicos', 'EBD', 'Harpa'
  final String fileUrl;
  final LibraryType type;
  final DateTime createdAt;

  LibraryItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.fileUrl,
    required this.type,
    required this.createdAt,
  });

  factory LibraryItem.fromMap(String id, Map<String, dynamic> map) {
    return LibraryItem(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Geral',
      fileUrl: map['fileUrl'] ?? '',
      type: LibraryType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'pdf'),
        orElse: () => LibraryType.pdf,
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'fileUrl': fileUrl,
      'type': type.name,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
