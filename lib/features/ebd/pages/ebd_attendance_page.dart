import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ebd_class.dart';
import '../models/ebd_attendance.dart';
import '../providers/ebd_providers.dart';
import '../../membros/providers/membro_providers.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class EbdAttendancePage extends ConsumerStatefulWidget {
  final String classId;

  const EbdAttendancePage({super.key, required this.classId});

  @override
  ConsumerState<EbdAttendancePage> createState() => _EbdAttendancePageState();
}

class _EbdAttendancePageState extends ConsumerState<EbdAttendancePage> {
  DateTime _selectedDate = DateTime.now();
  final Map<String, bool> _attendanceMap = {};
  bool _isSaving = false;

  String get _formattedDate => DateFormat('yyyy-MM-dd').format(_selectedDate);

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(ebdClassesListProvider);
    final membersAsync = ref.watch(membersListProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fazer Chamada'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: classesAsync.when(
        data: (classes) {
          final ebdClass = classes.firstWhere((c) => c.id == widget.classId);
          
          return Column(
            children: [
              // Seletor de Data
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.primary.withValues(alpha: 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Data da Aula:', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: () => _selectDate(context),
                      icon: const Icon(Icons.calendar_month),
                      label: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                    ),
                  ],
                ),
              ),

              // Lista de Alunos
              Expanded(
                child: membersAsync.when(
                  data: (membros) {
                    final alunos = membros.where((m) => ebdClass.studentIds.contains(m.id)).toList();
                    
                    if (alunos.isEmpty) {
                      return const Center(child: Text('Nenhum aluno matriculado nesta turma.'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: alunos.length,
                      itemBuilder: (context, index) {
                        final aluno = alunos[index];
                        return SwitchListTile(
                          title: Text(aluno.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                          secondary: CircleAvatar(child: Text(aluno.firstName[0].toUpperCase())),
                          value: _attendanceMap[aluno.id] ?? false,
                          activeColor: AppColors.secondary,
                          onChanged: (val) {
                            setState(() => _attendanceMap[aluno.id] = val ?? false);
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Erro ao carregar alunos: $e'),
                ),
              ),

              // Botão Salvar
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : () => _saveAttendance(ebdClass.studentIds),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isSaving 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('SALVAR PRESENÇAS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro: $err')),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Opcional: Aqui podes limpar o mapa ou carregar presenças existentes para esta data
      });
    }
  }

  Future<void> _saveAttendance(List<String> allStudentIds) async {
    setState(() => _isSaving = true);
    final service = ref.read(ebdAttendanceServiceProvider);
    final professorUid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

    try {
      for (var studentId in allStudentIds) {
        final attendance = EbdAttendance(
          id: '', // Definido pelo serviço
          classId: widget.classId,
          memberId: studentId,
          date: _formattedDate,
          present: _attendanceMap[studentId] ?? false,
          markedBy: professorUid,
          createdAt: DateTime.now(),
        );
        await service.markAttendance(attendance);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Presenças registadas com sucesso!'), backgroundColor: AppColors.secondary),
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
}
