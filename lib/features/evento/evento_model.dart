import 'package:cloud_firestore/cloud_firestore.dart';

class Evento {
  final String id;
  final String titulo;
  final String descricao;
  final String local;
  final DateTime data;
  final String categoria;

  Evento({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.local,
    required this.data,
    required this.categoria,
  });

  factory Evento.fromMap(String id, Map<String, dynamic> map) {
    // Lógica robusta para tratar data como Timestamp ou String (ISO 8601)
    final rawData = map['data'];
    DateTime parsedData;

    if (rawData is Timestamp) {
      parsedData = rawData.toDate();
    } else if (rawData is String) {
      parsedData = DateTime.tryParse(rawData) ?? DateTime.now();
    } else {
      parsedData = DateTime.now();
    }

    return Evento(
      id: id,
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
      local: map['local'] ?? 'Igreja Sede',
      data: parsedData,
      categoria: map['categoria'] ?? 'Culto',
    );
  }

  factory Evento.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Evento.fromMap(doc.id, data);
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'local': local,
      'data': Timestamp.fromDate(data), // Garante que salva como Timestamp no Firestore
      'categoria': categoria,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
