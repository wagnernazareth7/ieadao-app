import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../models/ebd_class.dart';
import '../../membros/models/membro.dart';
import '../../membros/providers/membro_providers.dart';
import '../providers/ebd_providers.dart';

class EbdPromotionAlertsWidget extends ConsumerWidget {
  const EbdPromotionAlertsWidget({super.key});

  int _calculateAge(String birthDate) {
    try {
      final parts = birthDate.split('/');
      final birth = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      final today = DateTime.now();
      int age = today.year - birth.year;
      if (today.month < birth.month || (today.month == birth.month && today.day < birth.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return -1; // Data inválida
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(ebdClassesListProvider);
    final membersAsync = ref.watch(membersListProvider);

    return classesAsync.when(
      data: (classes) => membersAsync.when(
        data: (members) {
          final List<Map<String, dynamic>> suggestions = [];

          for (var turma in classes) {
            final alunosNestaTurma = members.where((m) => turma.studentIds.contains(m.id)).toList();
            
            for (var aluno in alunosNestaTurma) {
              final age = _calculateAge(aluno.birthDate);
              if (age == -1) continue;

              // LÓGICA DE ALERTA: Se a idade do aluno for maior que a idade máxima da classe
              if (age > turma.maxAge) {
                suggestions.add({
                  'aluno': aluno,
                  'turmaAtual': turma,
                  'idade': age,
                });
              }
            }
          }

          if (suggestions.isEmpty) return const SizedBox.shrink();

          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
                    SizedBox(width: 8),
                    Text('SUGESTÕES DE PROMOÇÃO', 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.orange, letterSpacing: 1.2)),
                  ],
                ),
                const SizedBox(height: 12),
                ...suggestions.take(3).map((s) {
                  final Membro aluno = s['aluno'];
                  final EbdClass turma = s['turmaAtual'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 14, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${aluno.firstName} (${s['idade']} anos) ultrapassou a idade da classe ${turma.name}.',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                        TextButton(
                          onPressed: () {}, // Futuro: Abrir diálogo de movimentação
                          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                          child: const Text('MOVER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
