import 'package:cloud_firestore/cloud_firestore.dart';

class EbdCertificate {
  final String id;
  final String memberId;
  final String memberName;
  final String className;
  final double attendanceRate;
  final DateTime issuedAt;

  EbdCertificate({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.className,
    required this.attendanceRate,
    required this.issuedAt,
  });

  factory EbdCertificate.fromMap(String id, Map<String, dynamic> map) {
    return EbdCertificate(
      id: id,
      memberId: map['memberId'] ?? '',
      memberName: map['memberName'] ?? '',
      className: map['className'] ?? '',
      attendanceRate: (map['attendanceRate'] as num?)?.toDouble() ?? 0.0,
      issuedAt: (map['issuedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'memberName': memberName,
      'className': className,
      'attendanceRate': attendanceRate,
      'issuedAt': FieldValue.serverTimestamp(),
    };
  }
}
