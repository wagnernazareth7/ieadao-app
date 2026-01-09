class Role {
  final String id;
  final String name;
  final Map<String, bool> permissions;

  Role({
    required this.id,
    required this.name,
    required this.permissions,
  });

  factory Role.fromMap(String id, Map<String, dynamic> map) {
    return Role(
      id: id,
      name: map['name'] ?? '',
      permissions: Map<String, bool>.from(map['permissions'] ?? {}),
    );
  }

  bool can(String permission) {
    return permissions[permission] ?? false;
  }
}
