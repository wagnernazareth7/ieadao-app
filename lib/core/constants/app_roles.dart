class AppRoles {
  static const admin = 'admin';
  static const direcao = 'direcao';
  static const secretaria = 'secretaria';
  static const professor = 'professor';
  static const member = 'membro'; // CORREÇÃO: Alinhado com a base de dados
  static const coral = 'coral';
  static const dirigente = 'dirigente';
  static const comunicacao = 'comunicacao';

  static const all = [
    admin,
    direcao,
    secretaria,
    professor,
    member,
    coral,
    dirigente,
    comunicacao,
  ];

  static String getName(String role) {
    switch (role) {
      case admin: return 'Administrador';
      case direcao: return 'Direção';
      case secretaria: return 'Secretaria';
      case professor: return 'Professor EBD';
      case member: return 'Membro';
      case coral: return 'Coral';
      case dirigente: return 'Dirigente';
      case comunicacao: return 'Comunicação';
      default: return 'Membro';
    }
  }
}
