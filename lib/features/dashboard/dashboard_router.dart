import 'package:flutter/material.dart';
import 'direcao_dashboard.dart'; // Será transformado no Dashboard Unificado
import 'member_dashboard.dart';
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
    final normalizedRoles = widget.roles.map((r) => r.toLowerCase()).toList();
    
    // QUALQUER CARGO além de membro agora tem acesso à aba de Serviço
    final bool hasServiceTab = normalizedRoles.any((r) => 
      ['admin', 'direcao', 'secretaria', 'comunicacao', 'professor', 'coral', 'dirigente'].contains(r)
    );

    if (!hasServiceTab) {
      return const MembroDashboard();
    }

    final List<Widget> pages = [
      const MembroDashboard(), // Comunidade
      DiretoriaDashboard(roles: normalizedRoles), // Dashboard Dinâmico de Serviço
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_mosaic_outlined), activeIcon: Icon(Icons.auto_awesome_mosaic), label: 'Comunidade'),
          BottomNavigationBarItem(icon: Icon(Icons.miscellaneous_services_outlined), activeIcon: Icon(Icons.miscellaneous_services), label: 'Serviço'),
        ],
      ),
    );
  }
}
