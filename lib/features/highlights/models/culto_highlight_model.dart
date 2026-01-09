import 'package:cloud_firestore/cloud_firestore.dart';

class CultoHighlight {
  final String id;
  final DateTime data;
  final String domingoDoMes;
  
  // Secções com títulos editáveis e conteúdos
  final Map<String, dynamic> content;
  final DateTime createdAt;

  CultoHighlight({
    required this.id,
    required this.data,
    required this.domingoDoMes,
    required this.content,
    required this.createdAt,
  });

  factory CultoHighlight.fromMap(String id, Map<String, dynamic> map) {
    return CultoHighlight(
      id: id,
      data: (map['data'] as Timestamp).toDate(),
      domingoDoMes: map['domingoDoMes'] ?? '',
      content: Map<String, dynamic>.from(map['content'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'data': Timestamp.fromDate(data),
      'domingoDoMes': domingoDoMes,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
