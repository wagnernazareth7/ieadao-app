import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/analytics/analytics_provider.dart';
import 'widgets/members_growth_chart.dart';
import 'export/pdf_report_service.dart';
import 'export/excel_report_service.dart';

class ReportsDashboardPage extends ConsumerWidget {
  const ReportsDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalMembersAsync = ref.watch(totalMembersProvider);
    final donationsAsync = ref.watch(monthlyDonationsProvider);
    final totalEventsAsync = ref.watch(totalEventsProvider);
    
    final List<int> growthData = [10, 15, 12, 20, 25, 30, 28];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inteligência Institucional'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Visão Geral', style: AppTextStyles.heading),
            const SizedBox(height: 16),
            
            // Gráfico de Crescimento
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CRESCIMENTO DE MEMBROS (ESTIMADO)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 20),
                  Expanded(child: MembersGrowthChart(monthlyData: growthData)),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Text('Principais Indicadores', style: AppTextStyles.heading),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    label: 'Membros Ativos', 
                    value: totalMembersAsync.when(data: (d) => d.toString(), loading: () => '...', error: (_,__) => '!'), 
                    color: Colors.blue
                  )
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    label: 'Eventos Ativos', 
                    value: totalEventsAsync.when(data: (d) => d.toString(), loading: () => '...', error: (_,__) => '!'), 
                    color: Colors.orange
                  )
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoCard(
              label: 'Arrecadação Realtime', 
              value: donationsAsync.when(data: (d) => '${d.toStringAsFixed(2)} MZN', loading: () => '...', error: (_,__) => '!'), 
              color: Colors.teal,
              fullWidth: true,
            ),

            const SizedBox(height: 40),
            const Text('Relatórios Oficiais', style: AppTextStyles.heading),
            const SizedBox(height: 12),
            const Text('Gere documentos para reuniões ou arquivos.', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 24),
            
            // BOTÕES DE EXPORTAÇÃO ATIVADOS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      PdfReportService.generateMembersReport(
                        totalMembers: totalMembersAsync.value ?? 0,
                        newMembers: totalEventsAsync.value ?? 0, // Usando eventos como indicador temporário
                        totalDonations: donationsAsync.value ?? 0.0,
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 18),
                    label: const Text('PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 15)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ExcelReportService.generateMembersExcel(
                        totalMembers: totalMembersAsync.value ?? 0,
                        newMembers: totalEventsAsync.value ?? 0,
                        totalDonations: donationsAsync.value ?? 0.0,
                      );
                    },
                    icon: const Icon(Icons.table_view, color: Colors.white, size: 18),
                    label: const Text('EXCEL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 15)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool fullWidth;

  const _InfoCard({required this.label, required this.value, required this.color, this.fullWidth = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTextStyles.heading.copyWith(color: color, fontSize: 24)),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
