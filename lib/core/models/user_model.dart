import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final bool active;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.active,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    // Tratamento robusto para o campo 'active'
    final rawActive = data['active'];
    bool activeValue = true; // valor padrão

    if (rawActive is bool) {
      activeValue = rawActive;
    } else if (rawActive is String) {
      activeValue = rawActive.toLowerCase() == 'true';
    }

    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'member',
      active: activeValue,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'active': active,
    };
  }
}
