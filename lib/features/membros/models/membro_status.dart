enum MembroStatus {
  ativo,
  inativo,
}

extension MembroStatusX on MembroStatus {
  String get value {
    switch (this) {
      case MembroStatus.ativo:
        return 'ativo';
      case MembroStatus.inativo:
        return 'inativo';
    }
  }

  static MembroStatus fromString(String value) {
    switch (value) {
      case 'ativo':
        return MembroStatus.ativo;
      case 'inativo':
        return MembroStatus.inativo;
      default:
        return MembroStatus.ativo;
    }
  }
}
