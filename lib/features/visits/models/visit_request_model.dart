import 'package:cloud_firestore/cloud_firestore.dart';

enum VisitStatus { pendente, agendada, concluida, cancelada }

enum VisitType { enfermidade, aconselhamento, oracao, social }

class VisitRequest {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String address;
  final VisitType type;
  final String observation;
  final VisitStatus status;
  final DateTime? scheduledDate;
  final DateTime createdAt;

  VisitRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.address,
    required this.type,
    required this.observation,
    this.status = VisitStatus.pendente,
    this.scheduledDate,
    required this.createdAt,
  });

  factory VisitRequest.fromMap(String id, Map<String, dynamic> map) {
    return VisitRequest(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Membro',
      userPhone: map['userPhone'] ?? '',
      address: map['address'] ?? '',
      type: VisitType.values.firstWhere((e) => e.name == map['type'], orElse: () => VisitType.oracao),
      observation: map['observation'] ?? '',
      status: VisitStatus.values.firstWhere((e) => e.name == map['status'], orElse: () => VisitStatus.pendente),
      scheduledDate: (map['scheduledDate'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'address': address,
      'type': type.name,
      'observation': observation,
      'status': status.name,
      'scheduledDate': scheduledDate != null ? Timestamp.fromDate(scheduledDate!) : null,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
