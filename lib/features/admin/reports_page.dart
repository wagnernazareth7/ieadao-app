import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/analytics/analytics_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuta apenas os providers existentes e reativos (StreamProviders)
    final totalMembers = ref.watch(totalMembersProvider);
    final totalEvents = ref.watch(totalEventsProvider);
    final donations = ref.watch(monthlyDonationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inteligência Ministerial'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Visão Geral da Igreja', style: AppTextStyles.heading),
            const SizedBox(height: 16),
            
            _ReportCard(
              title: 'Membros Ativos',
              value: totalMembers.when(data: (d) => d.toString(), loading: () => '...', error: (_, __) => '!'),
              icon: Icons.people,
              color: Colors.blue,
            ),
            
            _ReportCard(
              title: 'Eventos na Agenda',
              value: totalEvents.when(data: (d) => d.toString(), loading: () => '...', error: (_, __) => '!'),
              icon: Icons.event,
              color: Colors.orange,
            ),

            const SizedBox(height: 32),
            const Text('Balanço Financeiro', style: AppTextStyles.heading),
            const SizedBox(height: 16),
            
            _ReportCard(
              title: 'Arrecadação Total',
              value: donations.when(data: (d) => '${d.toStringAsFixed(2)} MZN', loading: () => '...', error: (_, __) => '!'),
              icon: Icons.monetization_on,
              color: Colors.teal,
            ),

            const SizedBox(height: 40),
            const Card(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Os dados acima são sincronizados em tempo real com a base de dados central da IEADAO Tsalala.',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ReportCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        trailing: Text(value, style: AppTextStyles.heading.copyWith(color: color, fontSize: 18)),
      ),
    );
  }
}
