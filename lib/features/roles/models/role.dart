class Role {
  final String id;
  final String name;
  final List<String> permissions;

  Role({
    required this.id,
    required this.name,
    required this.permissions,
  });

  factory Role.fromMap(String id, Map<String, dynamic> map) {
    return Role(
      id: id,
      name: map['name'] ?? '',
      permissions: List<String>.from(map['permissions'] ?? []),
    );
  }
}
