import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../models/ebd_class.dart';
import '../models/ebd_attendance.dart';
import '../services/ebd_attendance_service.dart';
import '../../membros/providers/membro_providers.dart';

class EbdMonthlyReportPage extends ConsumerStatefulWidget {
  final EbdClass turma;
  const EbdMonthlyReportPage({super.key, required this.turma});

  @override
  ConsumerState<EbdMonthlyReportPage> createState() => _EbdMonthlyReportPageState();
}

class _EbdMonthlyReportPageState extends ConsumerState<EbdMonthlyReportPage> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final attendanceService = EbdAttendanceService();
    final membersAsync = ref.watch(membersListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Frequência: ${widget.turma.name}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. SELETOR DE MÊS
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('MÊS DE REFERÊNCIA', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () => _pickMonth(context),
                  icon: const Icon(Icons.calendar_month, color: Colors.white),
                  label: Text(DateFormat('MMMM yyyy').format(_selectedMonth).toUpperCase(), 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // 2. LISTA DE FREQUÊNCIA
          Expanded(
            child: StreamBuilder<List<EbdAttendance>>(
              stream: attendanceService.watchAttendanceByClass(widget.turma.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Sem registros de presença para esta turma.'));

                final allAttendance = snapshot.data!;
                final monthFilter = DateFormat('yyyy-MM').format(_selectedMonth);
                
                final monthAttendance = allAttendance.where((a) => 
                  a.date.startsWith(monthFilter)
                ).toList();

                return membersAsync.when(
                  data: (members) {
                    final students = members.where((m) => widget.turma.studentIds.contains(m.id)).toList();
                    
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        final studentHistory = monthAttendance.where((a) => a.memberId == student.id).toList();
                        final presents = studentHistory.where((a) => a.present).length;
                        final totalAulas = studentHistory.length;
                        final percent = totalAulas > 0 ? (presents / totalAulas) * 100 : 0.0;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getPercentColor(percent).withValues(alpha: 0.1),
                              child: Text('${percent.toInt()}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getPercentColor(percent))),
                            ),
                            title: Text('${student.firstName} ${student.lastName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text('$presents presenças em $totalAulas domingos', style: const TextStyle(fontSize: 11)),
                            trailing: Icon(Icons.circle, size: 12, color: _getPercentColor(percent)),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Text('Erro ao carregar lista de alunos.'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _pickMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() => _selectedMonth = picked);
    }
  }

  Color _getPercentColor(double p) {
    if (p >= 75) return Colors.green;
    if (p >= 50) return Colors.orange;
    return Colors.red;
  }
}
