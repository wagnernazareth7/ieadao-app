import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ieadao/core/theme/app_colors.dart';
import 'package:ieadao/core/theme/app_text_styles.dart';
import 'package:ieadao/core/services/auth_service.dart';
import '../../core/analytics/analytics_provider.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalMembers = ref.watch(totalMembersProvider);
    final monthlyFinance = ref.watch(monthlyDonationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Administração Central'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.amberAccent),
            onPressed: () => context.push('/ia-assistente'),
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: () async => await AuthService().logout()),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Painel de Controlo', style: AppTextStyles.heading.copyWith(color: Colors.white, fontSize: 22)),
                  const SizedBox(height: 4),
                  const Text('Gestão estratégica e monitorização.', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Membros',
                          value: totalMembers.when(data: (d) => d.toString(), loading: () => '...', error: (_,__) => '!'),
                          icon: Icons.people,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Finanças',
                          value: monthlyFinance.when(data: (d) => '${d.toStringAsFixed(0)}', loading: () => '...', error: (_,__) => '!'),
                          icon: Icons.monetization_on,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // GRID ADMIN COMPACTO - DISCIPULADO ADICIONADO
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.8,
                    children: [
                      _AdminIconBtn(label: 'Membros', icon: Icons.group, color: Colors.blue, onTap: () => context.push('/membros')),
                      _AdminIconBtn(label: 'Agenda', icon: Icons.calendar_today, color: Colors.orange, onTap: () => context.push('/agenda')),
                      _AdminIconBtn(label: 'EBD Admin', icon: Icons.school, color: Colors.green, onTap: () => context.push('/ebd-admin')),
                      _AdminIconBtn(label: 'Financeiro', icon: Icons.volunteer_activism, color: Colors.redAccent, onTap: () => context.push('/donations-admin')),
                      _AdminIconBtn(label: 'Família Fé', icon: Icons.favorite, color: Colors.pink, onTap: () => context.push('/discipulado')), // NOVO
                      _AdminIconBtn(label: 'Escalas', icon: Icons.event_note, color: Colors.teal, onTap: () => context.push('/escala-admin')),
                      _AdminIconBtn(label: 'Auditoria', icon: Icons.history, color: Colors.blueGrey, onTap: () => context.push('/audit')),
                      _AdminIconBtn(label: 'Avisos', icon: Icons.campaign, color: Colors.deepOrange, onTap: () => context.push('/comunicados-admin')),
                      _AdminIconBtn(label: 'Património', icon: Icons.inventory_2, color: Colors.blueGrey, onTap: () => context.push('/inventario')),
                      _AdminIconBtn(label: 'Biblioteca', icon: Icons.library_books, color: Colors.brown, onTap: () => context.push('/biblioteca-admin')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _AdminIconBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _AdminIconBtn({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(label, 
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
