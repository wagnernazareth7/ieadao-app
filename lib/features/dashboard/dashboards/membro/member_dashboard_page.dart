import 'package:flutter/material.dart';

class MemberDashboardPage extends StatelessWidget {
  const MemberDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bem-vindo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _DashboardItem(
            icon: Icons.event,
            title: 'Próximos Eventos',
          ),
          _DashboardItem(
            icon: Icons.campaign,
            title: 'Avisos',
          ),
          _DashboardItem(
            icon: Icons.volunteer_activism,
            title: 'Pedidos de Oração',
          ),
        ],
      ),
    );
  }
}

class _DashboardItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const _DashboardItem({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {},
      ),
    );
  }
}
