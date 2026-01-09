import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ieadao/features/auth/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../ebd/providers/ebd_providers.dart';
import '../auth/providers/current_user_provider.dart';

class ProfessorDashboard extends ConsumerWidget {
  const ProfessorDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final classesAsync = ref.watch(ebdClassesListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Painel do Professor'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            // CORREÇÃO SÉNIOR: O método correto no seu AuthService é logout()
            onPressed: () async => await AuthService().logout(),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Paz do Senhor, Professor(a)', 
                    style: AppTextStyles.heading.copyWith(color: Colors.white, fontSize: 22)),
                  const SizedBox(height: 4),
                  const Text('Gerencie sua turma e o ensino bíblico.', 
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('MINHAS FERRAMENTAS', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 11, letterSpacing: 1.2)),
                  const SizedBox(height: 16),
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                    children: [
                      _ProfCompactBtn(icon: Icons.forum, label: 'Chat Prof', color: Colors.green, onTap: () => context.push('/chat/professores/Sala dos Professores')),
                      _ProfCompactBtn(icon: Icons.calendar_month, label: 'Agenda', color: Colors.blue, onTap: () => context.push('/agenda')),
                      _ProfCompactBtn(icon: Icons.campaign, label: 'Avisos', color: Colors.orange, onTap: () => context.push('/comunicados')),
                      _ProfCompactBtn(icon: Icons.volunteer_activism, label: 'Ofertas', color: Colors.redAccent, onTap: () => context.push('/donations')),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  const Text('TURMAS SOB MINHA RESPONSABILIDADE', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 11, letterSpacing: 1.2)),
                  const SizedBox(height: 16),

                  classesAsync.when(
                    data: (classes) {
                      final myClasses = classes.where(
                        (c) => c.teacherIds.contains(userAsync.value?.uid ?? '')
                      ).toList();

                      if (myClasses.isEmpty) {
                        return _buildEmptyState();
                      }

                      return Column(
                        children: myClasses.map((t) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1), 
                              child: const Icon(Icons.school, size: 20, color: AppColors.primary)
                            ),
                            title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            subtitle: Text('${t.studentIds.length} Alunos Matriculados', style: const TextStyle(fontSize: 12)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                            onTap: () => context.push('/ebd/classes/${t.id}'),
                          ),
                        )).toList(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Text('Erro ao carregar turmas: $err'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
      child: const Column(
        children: [
          Icon(Icons.info_outline, color: Colors.orange, size: 32),
          SizedBox(height: 12),
          Text('Nenhuma turma vinculada.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text('Contacte a secretaria para ser alocado.', style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ProfCompactBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ProfCompactBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
