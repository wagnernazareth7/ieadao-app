import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/current_user_provider.dart';
import '../../features/auth/login_page.dart';
import '../../features/dashboard/dashboard_router.dart';
import '../theme/app_colors.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      loading: () => Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🛡️ CAMINHO PADRONIZADO (Renomeie o arquivo para logo_igreja.png)
              Image.asset(
                'assets/images/logo_igreja.png',
                width: 240,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
      
      error: (err, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 60, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text('Erro de conexão: $err', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.refresh(currentUserProvider),
                child: const Text('TENTAR NOVAMENTE'),
              ),
            ],
          ),
        ),
      ),
      
      data: (user) {
        if (user == null) return const LoginPage();
        return DashboardRouter(roles: user.roles);
      },
    );
  }
}
