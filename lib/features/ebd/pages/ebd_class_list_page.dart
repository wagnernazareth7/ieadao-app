import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/ebd_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/current_user_provider.dart';

class EbdClassListPage extends ConsumerWidget {
  const EbdClassListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final classesAsync = ref.watch(ebdClassesListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Minha Escola Dominical'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro ao carregar perfil: $e')),
        data: (user) {
          if (user == null) return const Center(child: Text('Inicie sessão para ver suas classes.'));

          final String userId = user.uid;
          final userRoles = user.roles.map((r) => r.toLowerCase()).toList();

          return classesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Erro ao carregar classes: $err')),
            data: (classes) {
              
              final List<dynamic> filteredClasses;
              if (userRoles.contains('admin') || userRoles.contains('direcao')) {
                filteredClasses = classes;
              } else {
                // CORREÇÃO SÉNIOR: Usando o nome de campo correto 'teacherIds'
                filteredClasses = classes.where((c) => 
                  c.teacherIds.contains(userId) || 
                  c.studentIds.contains(userId)
                ).toList();
              }

              if (filteredClasses.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school_outlined, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      const Text('Nenhuma turma encontrada.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text('Certifique-se que a secretaria o matriculou em uma classe.', 
                          textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 11)),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredClasses.length,
                itemBuilder: (context, index) {
                  final ebdClass = filteredClasses[index];
                  // CORREÇÃO SÉNIOR: Usando o nome de campo correto 'teacherIds'
                  final bool isProfessor = ebdClass.teacherIds.contains(userId);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        backgroundColor: (isProfessor ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.1),
                        child: Icon(
                          isProfessor ? Icons.assignment_ind : Icons.school, 
                          color: isProfessor ? AppColors.secondary : AppColors.primary, 
                          size: 20
                        ),
                      ),
                      title: Text(ebdClass.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(
                        isProfessor 
                          ? 'Você é Professor desta Classe' 
                          : 'Você é Aluno nesta Classe', 
                        style: const TextStyle(fontSize: 11)
                      ),
                      trailing: const Icon(Icons.chevron_right, size: 18),
                      onTap: () => context.push('/ebd/classes/${ebdClass.id}'),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
