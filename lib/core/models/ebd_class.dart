class EBDClass {
  final String id;
  final String name;
  final String teacherId;
  final List<String> studentsIds;

  EBDClass({
    required this.id,
    required this.name,
    required this.teacherId,
    required this.studentsIds,
  });

  factory EBDClass.fromMap(String id, Map<String, dynamic> map) {
    return EBDClass(
      id: id,
      name: map['name'] ?? '',
      teacherId: map['teacherId'] ?? '',
      studentsIds: List<String>.from(map['studentsIds'] ?? []),
    );
  }

  get students => null;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'teacherId': teacherId,
      'studentsIds': studentsIds,
    };
  }
}
