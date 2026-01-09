import 'package:cloud_firestore/cloud_firestore.dart';

class Escala {
  final String id;
  final DateTime data;
  final String tipoCulto; // NOVO: Tipo de culto oficial
  final String pregador;
  final String dirigente;
  final String? louvor; // OPCIONAL: Equipe de louvor
  final String? canticos; // OPCIONAL: Lista de hinos
  final String observacoes;
  final List<String> obreirosApoio;

  Escala({
    required this.id,
    required this.data,
    required this.tipoCulto,
    required this.pregador,
    required this.dirigente,
    this.louvor,
    this.canticos,
    this.observacoes = '',
    this.obreirosApoio = const [],
  });

  factory Escala.fromMap(String id, Map<String, dynamic> map) {
    return Escala(
      id: id,
      data: (map['data'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tipoCulto: map['tipoCulto'] ?? 'Culto Público',
      pregador: map['pregador'] ?? '',
      dirigente: map['dirigente'] ?? '',
      louvor: map['louvor'],
      canticos: map['canticos'],
      observacoes: map['observacoes'] ?? '',
      obreirosApoio: List<String>.from(map['obreirosApoio'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'data': Timestamp.fromDate(data),
      'tipoCulto': tipoCulto,
      'pregador': pregador,
      'dirigente': dirigente,
      'louvor': louvor,
      'canticos': canticos,
      'observacoes': observacoes,
      'obreirosApoio': obreirosApoio,
    };
  }
}
