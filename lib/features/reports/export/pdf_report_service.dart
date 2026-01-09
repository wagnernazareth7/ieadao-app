import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfReportService {
  static Future<void> generateMembersReport({
    required int totalMembers,
    required int newMembers,
    required double totalDonations,
  }) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text('Relatório Institucional IEADAO', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Data de Geração: $dateStr'),
            pw.Divider(),
            pw.SizedBox(height: 20),
            pw.Bullet(text: 'Total de Membros Ativos: $totalMembers'),
            pw.Bullet(text: 'Novos Membros (últimos 30 dias): $newMembers'),
            pw.Bullet(text: 'Arrecadação Mensal: ${totalDonations.toStringAsFixed(2)} MZN'),
            pw.SizedBox(height: 40),
            pw.Footer(
              title: pw.Text('Documento assinado digitalmente pelo sistema de gestão IEADAO'),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => pdf.save(), name: 'Relatorio_IEADAO.pdf');
  }
}
