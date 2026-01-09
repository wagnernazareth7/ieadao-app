import 'package:cloud_firestore/cloud_firestore.dart';

class Donation {
  final String id;
  final String memberId;
  final String memberName;
  final double amount;
  final String type; // Dízimo, Oferta, Missões
  final DateTime date;

  Donation({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.amount,
    required this.type,
    required this.date,
  });

  factory Donation.fromMap(String id, Map<String, dynamic> map) {
    return Donation(
      id: id,
      memberId: map['memberId'] ?? '',
      memberName: map['memberName'] ?? 'Anónimo',
      amount: (map['amount'] ?? 0).toDouble(),
      type: map['type'] ?? 'Oferta',
      date: (map['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'memberName': memberName,
      'amount': amount,
      'type': type,
      'date': Timestamp.fromDate(date),
    };
  }
}
