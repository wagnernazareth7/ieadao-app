import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/ebd_turma.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'ebd_controller.dart';

class EBDPresencaPage extends ConsumerWidget {
  final EBDTurma turma;

  const EBDPresencaPage({super.key, required this.turma});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // CORREÇÃO: Usando o provider atualizado presencasHojeProvider
    final presencasAsync = ref.watch(presencasHojeProvider(turma.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Presenças - ${turma.nome}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: presencasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro ao carregar presenças: $err')),
        data: (presencas) {
          if (presencas.isEmpty) {
            return const Center(child: Text('Nenhuma presença registrada hoje.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: presencas.length,
            itemBuilder: (context, index) {
              final presenca = presencas[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text('Aluno: ${presenca.alunoId}', style: AppTextStyles.body),
                  trailing: Checkbox(
                    activeColor: AppColors.secondary,
                    value: presenca.presente,
                    onChanged: (value) {
                      if (value != null) {
                        // O método marcarPresenca foi adicionado ao controlador para este atalho
                        ref.read(ebdControllerProvider).marcarPresenca(
                          turmaId: turma.id,
                          alunoId: presenca.alunoId,
                          presente: value,
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
