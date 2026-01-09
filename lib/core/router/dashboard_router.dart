import 'package:flutter/material.dart';
import '../../features/dashboard/direcao_dashboard.dart'; // AGORA É O PAINEL UNIVERSAL
import '../../features/dashboard/member_dashboard.dart';
import '../../core/theme/app_colors.dart';

class DashboardRouter extends StatefulWidget {
  final List<String> roles;
  const DashboardRouter({super.key, required this.roles});

  @override
  State<DashboardRouter> createState() => _DashboardRouterState();
}

class _DashboardRouterState extends State<DashboardRouter> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final normalizedRoles = widget.roles.map((r) => r.toLowerCase().trim()).toList();
    
    final bool hasServiceTab = normalizedRoles.any((r) => 
      r != 'membro' && r.isNotEmpty
    );

    if (!hasServiceTab) {
      return const MembroDashboard();
    }

    // ABORDAGEM SÉNIOR: Rota única para o Painel de Serviço Inteligente
    final List<Widget> pages = [
      const MembroDashboard(),
      DiretoriaDashboard(roles: normalizedRoles), // Sempre carrega o painel unificado
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_mosaic_outlined), activeIcon: Icon(Icons.auto_awesome_mosaic), label: 'Comunidade'),
          BottomNavigationBarItem(icon: Icon(Icons.miscellaneous_services_outlined), activeIcon: Icon(Icons.miscellaneous_services), label: 'Serviço'),
        ],
      ),
    );
  }
}
