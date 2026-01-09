import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'ebd_attendence_page.dart';
import 'ebd_form_page.dart';

class EBDListPage extends ConsumerWidget {
  const EBDListPage({super.key});

  ProviderListenable<dynamic>? get ebdClassesProvider => null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final turmasAsync = ref.watch(ebdClassesProvider!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escola Dominical'),
        backgroundColor: AppColors.primary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const EBDFormPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: turmasAsync.when(
        data: (turmas) {
          if (turmas.isEmpty) {
            return const Center(child: Text('Nenhuma turma cadastrada'));
          }

          return ListView.builder(
            itemCount: turmas.length,
            itemBuilder: (_, index) {
              final turma = turmas[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(turma.name, style: AppTextStyles.heading),
                  subtitle: Text('Professor: ${turma.teacherName}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EBDFormPage(turma: turma),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () {
                          // Aqui abriremos a página de presença
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EBDAttendancePage(turma: turma),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro: $err')),
      ),
    );
  }
}
