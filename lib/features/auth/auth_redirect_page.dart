import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/router/dashboard_router.dart';

class AuthRedirectPage extends StatefulWidget {
  const AuthRedirectPage({super.key});

  @override
  State<AuthRedirectPage> createState() => _AuthRedirectPageState();
}

class _AuthRedirectPageState extends State<AuthRedirectPage> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _redirectUser();
  }

  Future<void> _redirectUser() async {
    try {
      final user = await _authService.getCurrentUser();

      if (mounted) {
        if (user != null) {
          // CORREÇÃO SÉNIOR: Usamos o construtor padrão do DashboardRouter passando a lista de roles
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => DashboardRouter(roles: user.roles),
            ),
          );
        } else {
          // Fallback para login se não houver usuário
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Erro de redirecionamento: $e');
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text('Sincronizando perfil ministerial...', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
