import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ieadao/core/services/auth_service.dart';
import 'package:ieadao/features/roles/services/role_service.dart';
import 'package:ieadao/features/roles/models/role.dart';
import 'package:ieadao/core/models/app_user.dart';

final currentUserProvider = FutureProvider<({
  AppUser user,
  Role role,
})>((ref) async {
  final authService = AuthService();
  final roleService = RoleService();

  final user = await authService.getCurrentUser();
  if (user == null) {
    throw Exception('Utilizador não autenticado');
  }

  // Note: O modelo RoleModel que criamos usa RoleModel, 
  // mas aqui estamos seguindo o seu Passo 5 que usa 'Role'
  final role = await roleService.getRoleById(user.roleId);
  if (role == null) {
    throw Exception('Role inválido');
  }

  return (user: user, role: role);
});
