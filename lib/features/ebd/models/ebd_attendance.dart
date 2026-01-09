import 'package:cloud_firestore/cloud_firestore.dart';

class EbdAttendance {
  final String id;
  final String classId;
  final String memberId;
  final String date; // Formato YYYY-MM-DD para facilitar buscas por data
  final bool present;
  final String markedBy; // UID do professor/admin que marcou
  final DateTime createdAt;

  EbdAttendance({
    required this.id,
    required this.classId,
    required this.memberId,
    required this.date,
    required this.present,
    required this.markedBy,
    required this.createdAt,
  });

  factory EbdAttendance.fromMap(String id, Map<String, dynamic> map) {
    return EbdAttendance(
      id: id,
      classId: map['classId'] ?? '',
      memberId: map['memberId'] ?? '',
      date: map['date'] ?? '',
      present: map['present'] ?? false,
      markedBy: map['markedBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'memberId': memberId,
      'date': date,
      'present': present,
      'markedBy': markedBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
