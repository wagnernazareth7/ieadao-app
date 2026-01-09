import 'dart:typed_data'; // Import necessário para Uint8List
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:ieadao/core/models/donation_model.dart';

class ReportExportService {
  
  /// GERA RELATÓRIO PDF PROFISSIONAL
  Future<void> exportToPdf(List<Donation> donations) async {
    final pdf = pw.Document();
    final total = donations.fold(0.0, (sum, item) => sum + item.amount);

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('RELATORIO FINANCEIRO - IEADAO TSALALA')),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Data', 'Membro', 'Categoria', 'Valor'],
            data: donations.map((d) => [
              DateFormat('dd/MM/yyyy').format(d.date),
              d.memberName,
              d.type,
              '${d.amount.toStringAsFixed(2)} MZN'
            ]).toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text('ARRECADAÇÃO TOTAL: ${total.toStringAsFixed(2)} MZN', 
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  /// GERA PLANILHA EXCEL PARA CONTABILIDADE
  Future<void> exportToExcel(List<Donation> donations) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Financeiro'];

    sheet.appendRow([
      TextCellValue('Data'), 
      TextCellValue('Membro'), 
      TextCellValue('Categoria'), 
      TextCellValue('Valor')
    ]);

    for (var d in donations) {
      sheet.appendRow([
        TextCellValue(DateFormat('dd/MM/yyyy').format(d.date)),
        TextCellValue(d.memberName),
        TextCellValue(d.type),
        DoubleCellValue(d.amount)
      ]);
    }

    // CORREÇÃO SÉNIOR: Conversão explícita para Uint8List
    final List<int>? excelBytes = excel.encode();
    if (excelBytes != null) {
      await Printing.sharePdf(
        bytes: Uint8List.fromList(excelBytes), 
        filename: 'Relatorio_Financeiro_IEADAO.xlsx'
      );
    }
  }
}
