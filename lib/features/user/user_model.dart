class UserModel {
  final String uid;
  final String email;
  final String nome;
  final DateTime criadoEm;

  UserModel({
    required this.uid,
    required this.email,
    required this.nome,
    required this.criadoEm,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      nome: map['nome'] ?? '',
      criadoEm: DateTime.parse(map['criadoEm']),
    );
  }

  bool? get active => null;

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nome': nome,
      'criadoEm': criadoEm.toIso8601String(),
    };
  }
}
