import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart'; // Import corrigido

class DashboardScaffold extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final Widget body;

  const DashboardScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          ...actions,
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // 1️⃣ Executa o logout via serviço centralizado
              await AuthService().logout();
              // O AuthGate detetará a mudança e redirecionará para o Login
            },
          ),
        ],
      ),
      body: body,
    );
  }
}
