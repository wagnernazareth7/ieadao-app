import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String description; // Para que foi utilizado
  final double amount; // Quanto foi utilizado
  final String category; // Ex: Manutenção, Social, Eventos
  final DateTime date; // Quando foi utilizado
  final String authorizedBy; // Quem autorizou

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    required this.authorizedBy,
  });

  factory Expense.fromMap(String id, Map<String, dynamic> map) {
    return Expense(
      id: id,
      description: map['description'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      category: map['category'] ?? 'Geral',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      authorizedBy: map['authorizedBy'] ?? 'Direção',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'authorizedBy': authorizedBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
