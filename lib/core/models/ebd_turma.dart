import 'package:cloud_firestore/cloud_firestore.dart';

class EBDTurma {
  final String id;
  final String nome;
  final String professor;
  final List<String> alunosIds;
  final bool ativa;

  EBDTurma({
    required this.id,
    required this.nome,
    required this.professor,
    required this.alunosIds,
    this.ativa = true,
  });

  factory EBDTurma.fromMap(String id, Map<String, dynamic> map) {
    return EBDTurma(
      id: id,
      nome: map['nome'] ?? '',
      professor: map['professor'] ?? '',
      alunosIds: List<String>.from(map['alunosIds'] ?? []),
      ativa: map['ativa'] ?? true,
    );
  }

  factory EBDTurma.fromFirestore(DocumentSnapshot doc) {
    return EBDTurma.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'professor': professor,
      'alunosIds': alunosIds,
      'ativa': ativa,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
