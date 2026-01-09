import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/ebd_turma.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../membros/providers/membros_provider.dart';
import 'ebd_controller.dart';

class EBDAttendancePage extends ConsumerStatefulWidget {
  final EBDTurma turma;

  const EBDAttendancePage({super.key, required this.turma});

  @override
  ConsumerState<EBDAttendancePage> createState() => _EBDAttendancePageState();
}

class _EBDAttendancePageState extends ConsumerState<EBDAttendancePage> {
  late Map<String, bool> _attendance;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _attendance = {for (var id in widget.turma.alunosIds) id: false};
  }

  Future<void> _saveAttendance() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(ebdControllerProvider).saveAttendance(widget.turma.id, _attendance);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Presença registada com sucesso!'), backgroundColor: AppColors.secondary),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // CORREÇÃO: Usar todosMembrosProvider em vez de membrosProvider
    final membrosAsync = ref.watch(todosMembrosProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chamada: ${widget.turma.nome}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: membrosAsync.when(
        data: (membros) {
          final alunosDaTurma = membros.where((m) => widget.turma.alunosIds.contains(m.id)).toList();

          if (alunosDaTurma.isEmpty) {
            return const Center(child: Text('Esta turma ainda não tem alunos matriculados.'));
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.primary.withValues(alpha: 0.05),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Marque os alunos presentes no dia de hoje.',
                        style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: alunosDaTurma.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final aluno = alunosDaTurma[index];
                    return SwitchListTile(
                      title: Text(aluno.nome, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                      subtitle: Text(aluno.role, style: AppTextStyles.caption),
                      secondary: CircleAvatar(child: Text(aluno.nome.isNotEmpty ? aluno.nome[0].toUpperCase() : '?')),
                      activeColor: AppColors.secondary,
                      value: _attendance[aluno.id] ?? false,
                      onChanged: (val) {
                        setState(() {
                          _attendance[aluno.id] = val ?? false;
                        });
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveAttendance,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: _isSaving 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('CONFIRMAR PRESENÇA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro ao carregar alunos: $e')),
      ),
    );
  }
}
