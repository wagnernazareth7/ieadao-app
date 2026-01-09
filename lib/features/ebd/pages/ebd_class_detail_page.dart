import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/ebd_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/providers/current_user_provider.dart';
import '../../membros/providers/membro_providers.dart';

class EbdClassDetailPage extends ConsumerWidget {
  final String classId;
  const EbdClassDetailPage({super.key, required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(ebdClassesListProvider);
    final membersAsync = ref.watch(membersListProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Diário de Classe'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: classesAsync.when(
        data: (classes) {
          final ebdClass = classes.firstWhere((c) => c.id == classId);
          
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(ebdClass),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('CORPO DOCENTE'),
                      const SizedBox(height: 12),
                      membersAsync.when(
                        data: (membros) {
                          // CORREÇÃO SÉNIOR: Usando teacherIds
                          final professores = membros.where((m) => ebdClass.teacherIds.contains(m.id)).toList();
                          if (professores.isEmpty) return const Text('Nenhum professor atribuído.', style: TextStyle(color: Colors.grey, fontSize: 12));
                          
                          return Column(
                            children: professores.map((p) => ListTile(
                              leading: _buildMiniAvatar(p.photoUrl, p.firstName[0]),
                              title: Text(p.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: const Text('Professor Responsável', style: TextStyle(fontSize: 11)),
                              contentPadding: EdgeInsets.zero,
                            )).toList(),
                          );
                        },
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const Text('Erro ao carregar professores'),
                      ),

                      const SizedBox(height: 32),
                      _buildSectionHeader('ALUNOS MATRICULADOS (${ebdClass.studentIds.length})'),
                      const SizedBox(height: 12),
                      membersAsync.when(
                        data: (membros) {
                          final alunos = membros.where((m) => ebdClass.studentIds.contains(m.id)).toList();
                          if (alunos.isEmpty) return const Text('Nenhum aluno matriculado.', style: TextStyle(color: Colors.grey, fontSize: 12));
                          
                          return Column(
                            children: alunos.map((a) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: _buildMiniAvatar(a.photoUrl, a.firstName[0]),
                                title: Text(a.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                subtitle: Text(a.spiritualStatus ?? 'Membro', style: const TextStyle(fontSize: 10)),
                              ),
                            )).toList(),
                          );
                        },
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const Text('Erro ao carregar alunos'),
                      ),

                      const SizedBox(height: 48),

                      // BOTÃO DE CHAMADA: Disponível para Admin e para o Professor da turma
                      if (userAsync.value?.roles.contains('admin') == true || ebdClass.teacherIds.contains(userAsync.value?.uid))
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () => context.push('/ebd/classes/$classId/attendance'),
                            icon: const Icon(Icons.how_to_reg, color: Colors.white),
                            label: const Text('REALIZAR CHAMADA HOJE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary, 
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro: $err')),
      ),
    );
  }

  Widget _buildHeader(dynamic ebdClass) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
            child: const Text('ESCOLA DOMINICAL', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          Text(ebdClass.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          if (ebdClass.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(ebdClass.description, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniAvatar(String? photoUrl, String initial) {
    if (photoUrl != null && photoUrl.startsWith('data:image')) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: MemoryImage(base64Decode(photoUrl.split(',').last)),
      );
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      child: Text(initial, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1.2));
  }
}
