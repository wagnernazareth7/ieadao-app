import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../evento/evento_controller.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventosAsync = ref.watch(todosEventosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Administrador'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bem-vindo, Administrador', style: AppTextStyles.heading),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(child: _StatCard(title: 'Membros', value: '150')),
                const SizedBox(width: 8),
                Expanded(
                  child: eventosAsync.when(
                    data: (eventos) => _StatCard(
                      title: 'Eventos',
                      value: eventos.length.toString(),
                    ),
                    loading: () => const _StatCard(title: 'Eventos', value: '...'),
                    error: (_, __) => const _StatCard(title: 'Eventos', value: '!'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: _StatCard(title: 'Doações', value: '50')),
                SizedBox(width: 8),
                Expanded(child: _StatCard(title: 'EBD', value: '8')),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Eventos Recentes', style: AppTextStyles.subHeading),
                TextButton(
                  onPressed: () => context.push('/eventos'),
                  child: const Text('Ver Todos'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const _EventList(),
            const SizedBox(height: 24),
            Text('Avisos', style: AppTextStyles.subHeading),
            const SizedBox(height: 8),
            const _NoticeList(),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.heading),
            const SizedBox(height: 8),
            Text(title, style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}

class _EventList extends ConsumerWidget {
  const _EventList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventosAsync = ref.watch(todosEventosProvider);

    return eventosAsync.when(
      data: (eventos) {
        if (eventos.isEmpty) {
          return const Card(
            child: ListTile(
              title: Text('Nenhum evento recente'),
            ),
          );
        }
        return Column(
          children: eventos.take(3).map((e) {
            // CORREÇÃO: e.data já é DateTime, não precisa de tryParse
            final dt = e.data;
            final dataFormatada = "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";

            return Card(
              child: ListTile(
                title: Text(e.titulo),
                subtitle: Text('Data: $dataFormatada'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => context.push('/eventos/${e.id}'),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Erro ao carregar eventos: $err'),
    );
  }
}

class _NoticeList extends StatelessWidget {
  const _NoticeList();

  @override
  Widget build(BuildContext context) {
    final avisos = [
      'Aviso geral: Culto especial no domingo',
      'Aviso de secretaria: Atualizar cadastros'
    ];

    return Column(
      children: avisos
          .map((a) => Card(
        child: ListTile(
          title: Text(a),
        ),
      ))
          .toList(),
    );
  }
}
