import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/audit/audit_service.dart';
import '../../core/models/audit_log_model.dart';

class AuditLogsPage extends ConsumerStatefulWidget {
  const AuditLogsPage({super.key});

  @override
  ConsumerState<AuditLogsPage> createState() => _AuditLogsPageState();
}

class _AuditLogsPageState extends ConsumerState<AuditLogsPage> {
  String _selectedFilter = 'Todos';
  final List<String> _filters = ['Todos', 'Financeiro', 'Membros', 'EBD', 'Agenda', 'Escalas'];

  @override
  Widget build(BuildContext context) {
    final auditService = AuditService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Auditoria do Sistema'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. FILTROS RÁPIDOS DINÂMICOS
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: AppColors.primary,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _filters.map((f) => GestureDetector(
                  onTap: () => setState(() => _selectedFilter = f),
                  child: _FilterBadge(label: f, isActive: _selectedFilter == f),
                )).toList(),
              ),
            ),
          ),

          // 2. LISTA DE LOGS COM FILTRAGEM REAL
          Expanded(
            child: StreamBuilder<List<AuditLog>>(
              stream: auditService.watchLogs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhum log registrado ainda.'));
                }

                // LÓGICA DE FILTRO SÉNIOR
                final allLogs = snapshot.data!;
                final filteredLogs = _selectedFilter == 'Todos' 
                    ? allLogs 
                    : allLogs.where((log) => log.module.toLowerCase() == _selectedFilter.toLowerCase()).toList();

                if (filteredLogs.isEmpty) {
                  return Center(
                    child: Text('Nenhum registro para "$_selectedFilter" ainda.', style: const TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredLogs.length,
                  itemBuilder: (context, index) {
                    final log = filteredLogs[index];
                    return _AuditCard(log: log);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditCard extends StatelessWidget {
  final AuditLog log;
  const _AuditCard({required this.log});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ModuleBadge(module: log.module),
                Text(
                  DateFormat('dd/MM HH:mm').format(log.timestamp),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(log.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text('Por: ${log.userName}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBadge extends StatelessWidget {
  final String label;
  final bool isActive;
  const _FilterBadge({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label, 
        style: TextStyle(
          color: isActive ? AppColors.primary : Colors.white70, 
          fontSize: 12, 
          fontWeight: FontWeight.bold
        )
      ),
    );
  }
}

class _ModuleBadge extends StatelessWidget {
  final String module;
  const _ModuleBadge({required this.module});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (module.toLowerCase()) {
      case 'financeiro': color = Colors.green; break;
      case 'membros': color = Colors.blue; break;
      case 'ebd': color = Colors.orange; break;
      case 'agenda': color = Colors.purple; break;
      default: color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(module.toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}
