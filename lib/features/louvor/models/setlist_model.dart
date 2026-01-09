import 'package:cloud_firestore/cloud_firestore.dart';

// Item individual da playlist
class SetlistItem {
  final String musicId;
  final String musicTitle;
  final String? notes; // Ex: "Tom: G", "Início a cappella"
  final int order;

  SetlistItem({
    required this.musicId,
    required this.musicTitle,
    this.notes,
    required this.order,
  });

  factory SetlistItem.fromMap(Map<String, dynamic> map) {
    return SetlistItem(
      musicId: map['musicId'] ?? '',
      musicTitle: map['musicTitle'] ?? '',
      notes: map['notes'],
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'musicId': musicId,
      'musicTitle': musicTitle,
      'notes': notes,
      'order': order,
    };
  }
}

// A playlist completa para um culto
class Setlist {
  final String id;
  final DateTime date; // Data do culto
  final String? ministeringLeader; // O dirigente responsável
  final List<SetlistItem> items;

  Setlist({
    required this.id,
    required this.date,
    this.ministeringLeader,
    this.items = const [],
  });

  factory Setlist.fromMap(String id, Map<String, dynamic> map) {
    var itemsData = (map['items'] as List<dynamic>?) ?? [];
    var parsedItems = itemsData.map((itemMap) => SetlistItem.fromMap(itemMap)).toList();
    // Garante a ordenação
    parsedItems.sort((a, b) => a.order.compareTo(b.order));

    return Setlist(
      id: id,
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ministeringLeader: map['ministeringLeader'],
      items: parsedItems,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'ministeringLeader': ministeringLeader,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }
}
