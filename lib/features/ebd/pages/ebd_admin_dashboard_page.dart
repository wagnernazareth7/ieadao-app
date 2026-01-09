import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/ebd_providers.dart';
import '../../membros/providers/membro_providers.dart';
import '../widgets/ebd_promotion_alerts_widget.dart';
import '../../membros/models/membro.dart';
import '../models/ebd_class.dart'; // CORREÇÃO SÉNIOR: Importando o arquivo correto
import '../../auth/providers/current_user_provider.dart';

class EbdAdminDashboardPage extends ConsumerWidget {
  const EbdAdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(ebdClassesListProvider);
    final membersAsync = ref.watch(membersListProvider);
    final userAsync = ref.watch(currentUserProvider);
    final currentUser = userAsync.value;

    // LÓGICA DE PODER MINISTERIAL
    final userRoles = currentUser?.roles.map((r) => r.toLowerCase().trim()).toList() ?? [];
    final bool isProfessor = userRoles.contains('professor');
    final bool isAdminOrDirecao = userRoles.contains('admin') || userRoles.contains('direcao') || userRoles.contains('diretor') || userRoles.contains('secretaria');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Administração EBD'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alertas de Promoção: Apenas para a Direção
            if (isAdminOrDirecao) const EbdPromotionAlertsWidget(),

            if (isAdminOrDirecao) ...[
              const Text('INDICADORES EDUCACIONAIS', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12, letterSpacing: 1.2)),
              const SizedBox(height: 12),
              classesAsync.when(
                data: (classes) {
                  final totalAlunos = classes.fold(0, (acc, c) => acc + c.studentIds.length);
                  return Row(
                    children: [
                      _EbdStatBox(label: 'Turmas Ativas', value: classes.length.toString(), icon: Icons.school, color: Colors.blue),
                      const SizedBox(width: 12),
                      _EbdStatBox(label: 'Membros Inscritos', value: totalAlunos.toString(), icon: Icons.people, color: Colors.green),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Erro ao carregar indicadores'),
              ),
              const SizedBox(height: 32),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TURMAS E ALOCAÇÃO', style: AppTextStyles.heading),
                if (isAdminOrDirecao)
                  TextButton.icon(
                    onPressed: () => context.push('/ebd/novo'),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('NOVA TURMA'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            classesAsync.when(
              data: (allClasses) {
                // FILTRO DE PROFESSOR: Se não for admin, vê apenas a sua turma
                final displayClasses = isAdminOrDirecao 
                    ? allClasses 
                    : allClasses.where((c) => c.teacherIds.contains(currentUser?.uid ?? '')).toList();

                if (displayClasses.isEmpty) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Nenhuma turma atribuída a você.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayClasses.length,
                  itemBuilder: (context, i) {
                    final turma = displayClasses[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(Icons.class_outlined, color: AppColors.primary, size: 20),
                        ),
                        title: Text(turma.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${turma.studentIds.length} alunos inscritos', style: const TextStyle(fontSize: 12)),
                        children: [
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildActionRow(Icons.group_add, 'Gerir Alunos', () => context.push('/ebd/edit', extra: turma)),
                                _buildActionRow(Icons.bar_chart, 'Ver Frequência Mensal', () => context.push('/ebd/report', extra: turma)),
                                if (isAdminOrDirecao)
                                  _buildActionRow(Icons.edit, 'Editar Detalhes da Turma', () => context.push('/ebd/edit', extra: turma)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const Text('Erro ao carregar turmas.'),
            ),

            const SizedBox(height: 32),

            // ALOCAÇÃO DE MEMBROS: Exclusivo para Direção
            if (isAdminOrDirecao) ...[
              const Text('MEMBROS NÃO ALOCADOS', style: AppTextStyles.heading),
              const SizedBox(height: 12),
              membersAsync.when(
                data: (allMembers) {
                  final allClasses = classesAsync.value ?? [];
                  final semClasse = allMembers.where((m) {
                    return !allClasses.any((c) => c.studentIds.contains(m.id));
                  }).toList();

                  if (semClasse.isEmpty) {
                    return const Card(
                      child: ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.green),
                        title: Text('Tudo em ordem'),
                        subtitle: Text('Todos os membros estão alocados em turmas.'),
                      ),
                    );
                  }

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.info_outline, color: Colors.orange),
                      title: Text('${semClasse.length} Membros sem Classe'),
                      subtitle: const Text('Atribua membros a turmas agora.'),
                      trailing: TextButton(
                        onPressed: () => _showAllocationDialog(context, semClasse, allClasses), 
                        child: const Text('VER TODOS')
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAllocationDialog(BuildContext context, List<Membro> semClasse, List<EbdClass> classes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Atribuir Classe EBD', style: AppTextStyles.heading),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: semClasse.length,
                itemBuilder: (context, index) {
                  final m = semClasse[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(m.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.add_link, color: AppColors.primary),
                      onTap: () => _selectTargetClass(context, m, classes),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectTargetClass(BuildContext context, Membro m, List<EbdClass> classes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Alocar ${m.firstName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: classes.map((c) => ListTile(
            title: Text(c.name),
            onTap: () async {
              await FirebaseFirestore.instance.collection('ebd_classes').doc(c.id).update({
                'studentIds': FieldValue.arrayUnion([m.id])
              });
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${m.firstName} alocado em ${c.name}!')));
              }
            },
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildActionRow(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.chevron_right, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _EbdStatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _EbdStatBox({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
