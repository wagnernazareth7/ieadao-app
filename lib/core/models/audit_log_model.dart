import 'package:cloud_firestore/cloud_firestore.dart';

class AuditLog {
  final String id;
  final String userId;
  final String userName;
  final String action; // ex: 'UPDATE_MEMBER', 'DELETE_MESSAGE'
  final String module; // ex: 'Financeiro', 'Membros'
  final String description;
  final DateTime timestamp;

  AuditLog({
    required this.id,
    required this.userId,
    required this.userName,
    required this.action,
    required this.module,
    required this.description,
    required this.timestamp,
  });

  factory AuditLog.fromMap(String id, Map<String, dynamic> map) {
    return AuditLog(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Desconhecido',
      action: map['action'] ?? '',
      module: map['module'] ?? 'Geral',
      description: map['description'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'action': action,
      'module': module,
      'description': description,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
