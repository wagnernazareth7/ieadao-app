// lib/features/home/models/evento.dart
class Evento {
  final String id;
  final String titulo;
  final String descricao;

  Evento({
    required this.id,
    required this.titulo,
    required this.descricao,
  });

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
    };
  }

  factory Evento.fromMap(String id, Map<String, dynamic> map) {
    return Evento(
      id: id,
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
    );
  }
}
