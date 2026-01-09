import 'package:cloud_firestore/cloud_firestore.dart';

class RoleModel {
  final String id;
  final String name;
  final List<String> permissions;

  RoleModel({
    required this.id,
    required this.name,
    required this.permissions,
  });

  // Converte um documento do Firestore para o modelo RoleModel
  factory RoleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return RoleModel(
      id: doc.id,
      name: data['name'] ?? '',
      permissions: List<String>.from(data['permissions'] ?? []),
    );
  }

  // Converte o modelo para um mapa (útil para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'permissions': permissions,
    };
  }
}
