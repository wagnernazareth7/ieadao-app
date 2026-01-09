import 'package:cloud_firestore/cloud_firestore.dart';

class EventCheckIn {
  final String id;
  final String eventId;
  final String memberId;
  final String memberName;
  final String gender; // NOVO: Para estatísticas
  final String birthDate; // NOVO: Para cálculo de faixa etária
  final DateTime checkInTime;
  final String type; // 'confirmacao_app' ou 'qrcode_checkin'

  EventCheckIn({
    required this.id,
    required this.eventId,
    required this.memberId,
    required this.memberName,
    required this.gender,
    required this.birthDate,
    required this.checkInTime,
    required this.type,
  });

  factory EventCheckIn.fromMap(String id, Map<String, dynamic> map) {
    return EventCheckIn(
      id: id,
      eventId: map['eventId'] ?? '',
      memberId: map['memberId'] ?? '',
      memberName: map['memberName'] ?? 'Membro',
      gender: map['gender'] ?? 'Não informado',
      birthDate: map['birthDate'] ?? '',
      checkInTime: (map['checkInTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: map['type'] ?? 'confirmacao_app',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'memberId': memberId,
      'memberName': memberName,
      'gender': gender,
      'birthDate': birthDate,
      'checkInTime': FieldValue.serverTimestamp(),
      'type': type,
    };
  }
}
