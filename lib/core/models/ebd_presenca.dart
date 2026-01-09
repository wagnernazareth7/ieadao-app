class EBDPresenca {
  final String id;
  final String alunoId;
  final bool presente;
  final DateTime data;

  EBDPresenca({
    required this.id,
    required this.alunoId,
    required this.presente,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'alunoId': alunoId,
      'presente': presente,
      'data': data.toIso8601String(),
    };
  }

  factory EBDPresenca.fromMap(String id, Map<String, dynamic> map) {
    return EBDPresenca(
      id: id,
      alunoId: map['alunoId'] ?? '',
      presente: map['presente'] ?? false,
      data: DateTime.parse(map['data'] ?? DateTime.now().toIso8601String()),
    );
  }
}
