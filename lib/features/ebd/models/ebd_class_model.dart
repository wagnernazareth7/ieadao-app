import 'package:cloud_firestore/cloud_firestore.dart';

class EbdClass {
  final String id;
  final String name;
  final String description;
  final int minAge;
  final int maxAge;
  final List<String> teacherIds; // IDs dos professores
  final List<String> studentIds; // IDs dos alunos

  EbdClass({
    required this.id,
    required this.name,
    this.description = '',
    this.minAge = 0,
    this.maxAge = 99,
    this.teacherIds = const [],
    this.studentIds = const [],
  });

  factory EbdClass.fromMap(String id, Map<String, dynamic> map) {
    return EbdClass(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      minAge: map['minAge'] ?? 0,
      maxAge: map['maxAge'] ?? 99,
      teacherIds: List<String>.from(map['teacherIds'] ?? []),
      studentIds: List<String>.from(map['studentIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'minAge': minAge,
      'maxAge': maxAge,
      'teacherIds': teacherIds,
      'studentIds': studentIds,
    };
  }
}
