import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/expense_model.dart';
import '../donation_controller.dart';
import '../services/expense_service.dart';
import '../services/report_export_service.dart';

class DonationsAdminDashboardPage extends ConsumerStatefulWidget {
  const DonationsAdminDashboardPage({super.key});

  @override
  ConsumerState<DonationsAdminDashboardPage> createState() => _DonationsAdminDashboardPageState();
}

class _DonationsAdminDashboardPageState extends ConsumerState<DonationsAdminDashboardPage> {
  final _expenseService = ExpenseService();

  @override
  Widget build(BuildContext context) {
    final donationsAsync = ref.watch(allDonationsProvider);
    final exportService = ReportExportService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestão de Caixa'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          donationsAsync.maybeWhen(
            data: (list) => list.isEmpty ? const SizedBox.shrink() : IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              onPressed: () => exportService.exportToPdf(list),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: donationsAsync.when(
        data: (donations) {
          return StreamBuilder<List<Expense>>(
            stream: _expenseService.watchExpenses(),
            builder: (context, expenseSnap) {
              final expenses = expenseSnap.data ?? [];
              
              final totalEntradas = donations.fold(0.0, (sum, item) => sum + item.amount);
              final totalSaidas = expenses.fold(0.0, (sum, item) => sum + item.amount);
              final saldoDisponivel = totalEntradas - totalSaidas;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- PAINEL DE BALANÇO REAL ---
                    _buildBalanceCard(totalEntradas, totalSaidas, saldoDisponivel),
                    
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('AÇÕES FINANCEIRAS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2)),
                        TextButton.icon(
                          onPressed: () => _showAddExpenseDialog(context),
                          icon: const Icon(Icons.remove_circle_outline, size: 16, color: Colors.redAccent),
                          label: const Text('REGISTAR SAÍDA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // --- GRÁFICO DE COMPARAÇÃO ---
                    SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          barGroups: [
                            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: totalEntradas, color: Colors.green, width: 25, borderRadius: BorderRadius.circular(4))]),
                            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: totalSaidas, color: Colors.redAccent, width: 25, borderRadius: BorderRadius.circular(4))]),
                          ],
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                        ),
                      ),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _Legend(label: 'Entradas', color: Colors.green),
                        SizedBox(width: 20),
                        _Legend(label: 'Saídas', color: Colors.redAccent),
                      ],
                    ),

                    const SizedBox(height: 40),
                    const Text('HISTÓRICO DE SAÍDAS', style: AppTextStyles.heading),
                    const SizedBox(height: 12),
                    if (expenses.isEmpty)
                      const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Nenhuma saída registrada.', style: TextStyle(color: Colors.grey, fontSize: 12))))
                    else
                      ...expenses.take(5).map((e) => _ExpenseTile(expense: e)),

                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }

  Widget _buildBalanceCard(double entradas, double saidas, double saldo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 15)],
      ),
      child: Column(
        children: [
          const Text('SALDO EM CAIXA', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 8),
          Text('${saldo.toStringAsFixed(2)} MZN', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BalanceStat(label: 'ENTRADAS', value: entradas, color: Colors.greenAccent),
              Container(width: 1, height: 30, color: Colors.white24),
              _BalanceStat(label: 'SAÍDAS', value: saidas, color: Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String category = 'Manutenção';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Registar Utilização de Fundo', style: AppTextStyles.heading),
            const SizedBox(height: 20),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descrição (Para quê?)', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Valor (Quanto?)', border: OutlineInputBorder(), prefixText: 'MZN ')),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: category,
              items: ['Manutenção', 'Social', 'Eventos', 'Administrativo'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => category = v!,
              decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (descCtrl.text.isEmpty || amountCtrl.text.isEmpty) return;
                  await _expenseService.addExpense(Expense(
                    id: '',
                    description: descCtrl.text.trim(),
                    amount: double.parse(amountCtrl.text),
                    category: category,
                    date: DateTime.now(),
                    authorizedBy: 'Direção Sede',
                  ));
                  if (mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text('CONFIRMAR SAÍDA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _BalanceStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('${value.toStringAsFixed(2)}', style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final String label;
  final Color color;
  const _Legend({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  const _ExpenseTile({required this.expense});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        leading: const CircleAvatar(backgroundColor: Colors.redAccent, child: Icon(Icons.outbox, color: Colors.white, size: 16)),
        title: Text(expense.description, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${expense.category} • ${DateFormat('dd/MM/yyyy').format(expense.date)}'),
        trailing: Text('- ${expense.amount.toStringAsFixed(2)} MT', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
