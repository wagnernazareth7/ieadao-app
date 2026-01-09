import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:path_provider/path_provider.dart';


class ExcelReportService {
  static Future<void> generateMembersExcel({
    required int totalMembers,
    required int newMembers,
    required double totalDonations,
  }) async {
    final excel = Excel.createExcel();
    
    // O Excel cria uma folha 'Sheet1' por padrão, vamos usar a nossa
    final sheet = excel['Relatorio'];

    // 1. Cabeçalho (Usando CellValue para compatibilidade com Excel 4.x)
    sheet.appendRow([
      TextCellValue('Relatório Institucional IEADAO'),
    ]);
    
    sheet.appendRow([
      TextCellValue('Gerado em'),
      TextCellValue(DateTime.now().toString().split('.')[0]),
    ]);
    
    sheet.appendRow([null]); // Linha vazia

    // 2. Cabeçalho da Tabela
    sheet.appendRow([
      TextCellValue('INDICADOR'),
      TextCellValue('VALOR'),
    ]);

    // 3. Dados Reais
    sheet.appendRow([
      TextCellValue('Total de Membros'),
      IntCellValue(totalMembers),
    ]);
    
    sheet.appendRow([
      TextCellValue('Novos Membros (30 dias)'),
      IntCellValue(newMembers),
    ]);
    
    sheet.appendRow([
      TextCellValue('Arrecadação Mensal (MZN)'),
      DoubleCellValue(totalDonations),
    ]);

    // 4. Lógica de Salvamento e Partilha Multi-plataforma
    if (kIsWeb) {
      // No Flutter Web, este método gera o download no navegador automaticamente
      excel.save(fileName: 'Relatorio_IEADAO.xlsx');
    } else {
      // No Mobile/Desktop, precisamos gravar o ficheiro no sistema de ficheiros
      final List<int>? fileBytes = excel.save();
      if (fileBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/Relatorio_IEADAO.xlsx';
        final file = File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
        
        // ABRE O MENU DE PARTILHA (WhatsApp, E-mail, etc)
        await Share.shareXFiles(
          [XFile(filePath)], 
          text: 'Relatório Institucional IEADAO - Gerado em ${DateTime.now().toString().split('.')[0]}'
        );
      }
    }
  }
}
