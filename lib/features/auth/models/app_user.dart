class AppUser {
  final String id;
  final String email;
  final String name;
  final String role;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  // Converte os dados do Firestore para o objeto AppUser
  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'membro',
    );
  }

  // Converte o objeto AppUser para um mapa para gravar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
    };
  }
}
