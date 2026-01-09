import 'package:cloud_firestore/cloud_firestore.dart';

enum ItemStatus { novo, bom, regular, danificado, em_manutencao }

class InventoryItem {
  final String id;
  final String name;
  final String description;
  final String category; // ex: 'Som', 'Instrumentos', 'Mobiliário'
  final ItemStatus status;
  final double purchaseValue;
  final DateTime purchaseDate;
  final String responsibleUid;
  final DateTime createdAt;

  InventoryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.status,
    required this.purchaseValue,
    required this.purchaseDate,
    required this.responsibleUid,
    required this.createdAt,
  });

  factory InventoryItem.fromMap(String id, Map<String, dynamic> map) {
    return InventoryItem(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Geral',
      status: ItemStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'bom'),
        orElse: () => ItemStatus.bom,
      ),
      purchaseValue: (map['purchaseValue'] ?? 0).toDouble(),
      purchaseDate: (map['purchaseDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      responsibleUid: map['responsibleUid'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'status': status.name,
      'purchaseValue': purchaseValue,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'responsibleUid': responsibleUid,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
