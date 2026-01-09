import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/current_user_provider.dart';
import '../../features/auth/login_page.dart';
import '../../features/dashboard/dashboard_router.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1️⃣ Observa o provedor que carrega o utilizador + dados do Firestore
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      // Enquanto carrega os dados do Firestore, mostra um loader
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      // Se houver erro (ex: falta de internet ou erro nas regras do Firestore)
      error: (err, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Erro de autenticação: $err', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(currentUserProvider),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
      data: (user) {
        // Se o utilizador não estiver logado ou o documento no Firestore não existir
        if (user == null) {
          return const LoginPage();
        }

        // CORREÇÃO SÉNIOR: Passando a lista de cargos (roles) para o DashboardRouter
        return DashboardRouter(roles: user.roles);
      },
    );
  }
}
