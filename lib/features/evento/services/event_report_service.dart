import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../evento_model.dart';
import '../models/event_checkin_model.dart';

class EventReportService {
  
  static int _calculateAge(String birthDate) {
    try {
      if (birthDate.isEmpty) return 0;
      final parts = birthDate.split('/');
      final birth = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      final today = DateTime.now();
      int age = today.year - birth.year;
      if (today.month < birth.month || (today.month == birth.month && today.day < birth.day)) age--;
      return age;
    } catch (_) { return 0; }
  }

  static Future<void> generateAttendanceReport(Evento evento) async {
    final pdf = pw.Document();
    
    final snapshot = await FirebaseFirestore.instance
        .collection('event_checkins')
        .where('eventId', isEqualTo: evento.id)
        .get();

    final checkins = snapshot.docs
        .map((doc) => EventCheckIn.fromMap(doc.id, doc.data()))
        .toList();

    // --- ANÁLISE ESTATÍSTICA ---
    int homens = 0;
    int mulheres = 0;
    int criancas = 0; // 0-12
    int adolescentes = 0; // 13-17
    int jovens = 0; // 18-35
    int adultos = 0; // 36+

    for (var c in checkins) {
      if (c.gender.toLowerCase() == 'masculino' || c.gender.toLowerCase() == 'male') homens++;
      if (c.gender.toLowerCase() == 'feminino' || c.gender.toLowerCase() == 'female') mulheres++;
      
      final age = _calculateAge(c.birthDate);
      if (age > 0 && age <= 12) criancas++;
      else if (age > 12 && age <= 17) adolescentes++;
      else if (age > 17 && age <= 35) jovens++;
      else if (age > 35) adultos++;
    }

    final total = checkins.length;
    final percH = total > 0 ? (homens / total * 100).toStringAsFixed(1) : "0";
    final percM = total > 0 ? (mulheres / total * 100).toStringAsFixed(1) : "0";

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // CABEÇALHO
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start, // CORREÇÃO SÉNIOR
                  children: [
                    pw.Text('IEADAO TSALALA', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Relatório Analítico de Impacto', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.Text(DateFormat('dd/MM/yyyy').format(DateTime.now()), style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // DADOS DO EVENTO
          pw.Text('EVENTO: ${evento.titulo.toUpperCase()}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          pw.Divider(thickness: 0.5),
          pw.SizedBox(height: 20),

          // SECÇÃO 1: RESUMO DEMOGRÁFICO (GÉNERO)
          pw.Text('DISTRIBUIÇÃO POR GÉNERO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              _buildStatBox('HOMENS', '$homens', '$percH%', PdfColors.blue700),
              pw.SizedBox(width: 20),
              _buildStatBox('MULHERES', '$mulheres', '$percM%', PdfColors.pink700),
              pw.SizedBox(width: 20),
              _buildStatBox('TOTAL', '$total', '100%', PdfColors.grey900),
            ],
          ),
          pw.SizedBox(height: 30),

          // SECÇÃO 2: FAIXA ETÁRIA (GRÁFICO EM TABELA)
          pw.Text('COMPOSIÇÃO POR FAIXA ETÁRIA', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: ['Segmento', 'Quantidade', 'Representatividade'],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
            data: [
              ['Crianças (0-12)', '$criancas', '${total > 0 ? (criancas/total*100).toStringAsFixed(1) : 0}%'],
              ['Adolescentes (13-17)', '$adolescentes', '${total > 0 ? (adolescentes/total*100).toStringAsFixed(1) : 0}%'],
              ['Jovens (18-35)', '$jovens', '${total > 0 ? (jovens/total*100).toStringAsFixed(1) : 0}%'],
              ['Adultos (36+)', '$adultos', '${total > 0 ? (adultos/total*100).toStringAsFixed(1) : 0}%'],
            ],
          ),
          pw.SizedBox(height: 40),

          // LISTA NOMINAL
          pw.Text('LISTA DE PRESENÇA (DETALHADA)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: ['Nome do Membro', 'Género', 'Idade', 'Check-in'],
            data: checkins.map((c) => [
              c.memberName,
              c.gender,
              _calculateAge(c.birthDate).toString(),
              DateFormat('HH:mm').format(c.checkInTime)
            ]).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Relatorio_Analitico_${evento.titulo}.pdf'
    );
  }

  static pw.Widget _buildStatBox(String label, String value, String sub, PdfColor color) {
    return pw.Container(
      width: 120,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 1),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 8, color: color, fontWeight: pw.FontWeight.bold)),
          pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text(sub, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
        ],
      ),
    );
  }
}
