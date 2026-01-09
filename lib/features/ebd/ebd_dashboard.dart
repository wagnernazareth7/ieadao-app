import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../membros/providers/membros_provider.dart';
import 'ebd_controller.dart';

class EBDDashboardPage extends ConsumerWidget {
  const EBDDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ebdAsync = ref.watch(turmasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escola Dominical'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        onPressed: () => context.push('/ebd/form'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ebdAsync.when(
        data: (classes) {
          if (classes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Nenhuma turma cadastrada.', style: AppTextStyles.body),
                ],
              ),
            );
          }

          final totalAlunos = classes.fold(0, (sum, item) => sum + item.alunosIds.length);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resumo Estatístico
                Row(
                  children: [
                    _StatBox(label: 'Turmas', value: classes.length.toString(), color: AppColors.primary),
                    const SizedBox(width: 12),
                    _StatBox(label: 'Alunos Totais', value: totalAlunos.toString(), color: AppColors.secondary),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Minhas Turmas', style: AppTextStyles.heading),
                const SizedBox(height: 12),
                
                // Lista de Cards de Turmas
                ...classes.map((turma) => Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(Icons.class_, color: AppColors.primary),
                        ),
                        title: Text(turma.nome, style: AppTextStyles.subHeading?.copyWith(fontWeight: FontWeight.bold) ?? const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Professor: ${turma.professor}', style: AppTextStyles.body),
                        trailing: Text('${turma.alunosIds.length} Alunos', style: AppTextStyles.caption),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.how_to_reg, size: 18),
                              label: const Text('PRESENÇA'),
                              onPressed: () => context.push('/ebd/presenca', extra: turma),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('EDITAR'),
                              onPressed: () => context.push('/ebd/form', extra: turma),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro ao carregar EBD: $err')),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.heading.copyWith(color: color, fontSize: 24)),
            Text(label, style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
