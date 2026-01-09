import 'package:cloud_firestore/cloud_firestore.dart';

class OrderOfServiceItem {
  final String label;
  final bool isCompleted;
  final DateTime? completedAt;

  OrderOfServiceItem({
    required this.label,
    this.isCompleted = false,
    this.completedAt,
  });

  factory OrderOfServiceItem.fromMap(Map<String, dynamic> map) {
    return OrderOfServiceItem(
      label: map['label'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'isCompleted': isCompleted,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
}

class OrderOfService {
  final String id;
  final String title; // NOVO: Nome do culto (ex: Culto de Jovens)
  final DateTime date;
  final List<OrderOfServiceItem> items;
  final bool isLive;

  OrderOfService({
    required this.id,
    required this.title,
    required this.date,
    required this.items,
    this.isLive = false,
  });

  factory OrderOfService.fromMap(String id, Map<String, dynamic> map) {
    var itemsData = (map['items'] as List<dynamic>?) ?? [];
    return OrderOfService(
      id: id,
      title: map['title'] ?? 'Culto Geral',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      items: itemsData.map((i) => OrderOfServiceItem.fromMap(i)).toList(),
      isLive: map['isLive'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': Timestamp.fromDate(date),
      'items': items.map((i) => i.toMap()).toList(),
      'isLive': isLive,
    };
  }
}
