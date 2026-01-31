import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final List<String> roles;
  final bool active;
  final String? phone;
  final String? address;
  final String? photoUrl;
  final String? birthDate;
  final String? gender;
  final DateTime? createdAt;
  
  final bool isBaptized;
  final String? baptismDate;
  final String? spiritualStatus;

  final String? spiritualParentId;
  final List<String> spiritualChildrenIds;

  AppUser({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.roles,
    required this.active,
    this.phone,
    this.address,
    this.photoUrl,
    this.birthDate,
    this.gender,
    this.createdAt,
    this.isBaptized = false,
    this.baptismDate,
    this.spiritualStatus = 'membro_pleno',
    this.spiritualParentId,
    this.spiritualChildrenIds = const [],
  });

  // ✅ RESTAURADO: Extrai o ID do cargo principal para compatibilidade com os providers
  String get roleId => roles.isNotEmpty ? roles.first : 'membro';

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    List<String> rolesList = [];
    if (map['roles'] is List) {
      rolesList = List<String>.from(map['roles']);
    } else if (map['role'] is String) {
      rolesList = [map['role']];
    } else {
      rolesList = ['membro'];
    }

    return AppUser(
      uid: uid,
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      roles: rolesList,
      active: map['active'] ?? true,
      phone: map['phone'],
      address: map['address'],
      photoUrl: map['photoUrl'],
      birthDate: map['birthDate'],
      gender: map['gender'],
      isBaptized: map['isBaptized'] ?? false,
      baptismDate: map['baptismDate'],
      spiritualStatus: map['spiritualStatus'] ?? 'membro_pleno',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      spiritualParentId: map['spiritualParentId'],
      spiritualChildrenIds: List<String>.from(map['spiritualChildrenIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'roles': roles,
      'role': roles.isNotEmpty ? roles.first : 'membro',
      'active': active,
      'phone': phone,
      'address': address,
      'photoUrl': photoUrl,
      'birthDate': birthDate,
      'gender': gender,
      'isBaptized': isBaptized,
      'baptismDate': baptismDate,
      'spiritualStatus': spiritualStatus,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'spiritualParentId': spiritualParentId,
      'spiritualChildrenIds': spiritualChildrenIds,
    };
  }
}
