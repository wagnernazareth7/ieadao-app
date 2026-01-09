enum UserRole {
  admin,
  direcao,
  professor,
  membro;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
          (e) => e.name == value,
      orElse: () => UserRole.membro,
    );
  }
}
