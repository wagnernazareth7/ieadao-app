import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'ebd_controller.dart';
import 'ebd_form_page.dart';

class EBDHomePage extends ConsumerWidget {
  const EBDHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // CORREÇÃO: Usar o provider real definido no ebd_controller.dart
    final turmasAsync = ref.watch(turmasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escola Dominical'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: turmasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro: $err', style: AppTextStyles.body)),
        data: (turmas) {
          if (turmas.isEmpty) {
            return const Center(child: Text('Nenhuma turma encontrada'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: turmas.length,
            itemBuilder: (context, index) {
              final turma = turmas[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(turma.nome, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Text('Professor(a): ${turma.professor}', style: AppTextStyles.body),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.primary),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EBDFormPage(turma: turma),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Confirmação'),
                              content: const Text('Deseja realmente deletar esta turma?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Deletar'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await ref.read(ebdControllerProvider).deleteTurma(turma.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Turma deletada com sucesso')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const EBDFormPage()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
