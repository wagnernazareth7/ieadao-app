import 'package:cloud_firestore/cloud_firestore.dart';

class Membro {
  final String id;
  final String firstName;
  final String lastName;
  final String gender;
  final String birthDate;
  final String phone;
  final String email;
  final List<String> roles;
  final String role;
  final bool active;
  final bool isBaptized;
  final String baptismDate;
  final String spiritualStatus;
  final String? photoUrl; // NOVO: Foto de perfil (Base64 ou URL)

  Membro({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.birthDate,
    required this.phone,
    required this.email,
    required this.roles,
    required this.role,
    required this.active,
    this.isBaptized = false,
    this.baptismDate = '',
    this.spiritualStatus = 'membro_pleno',
    this.photoUrl,
  });

  String get nome => '$firstName $lastName';

  factory Membro.fromMap(String id, Map<String, dynamic> map) {
    List<String> rolesList = [];
    if (map['roles'] is List) {
      rolesList = List<String>.from(map['roles']);
    } else if (map['role'] is String) {
      rolesList = [map['role']];
    } else {
      rolesList = ['membro'];
    }

    return Membro(
      id: id,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      gender: map['gender'] ?? '',
      birthDate: map['birthDate'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      roles: rolesList,
      role: map['role'] ?? 'membro',
      active: map['active'] ?? true,
      isBaptized: map['isBaptized'] ?? false,
      baptismDate: map['baptismDate'] ?? '',
      spiritualStatus: map['spiritualStatus'] ?? 'membro_pleno',
      photoUrl: map['photoUrl'], // MAPEAMENTO ADICIONADO
    );
  }

  factory Membro.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Membro.fromMap(doc.id, data);
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'birthDate': birthDate,
      'phone': phone,
      'email': email,
      'roles': roles,
      'role': role,
      'active': active,
      'isBaptized': isBaptized,
      'baptismDate': baptismDate,
      'spiritualStatus': spiritualStatus,
      'photoUrl': photoUrl, // GRAVAÇÃO ADICIONADA
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
