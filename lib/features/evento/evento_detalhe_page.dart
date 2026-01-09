import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../auth/providers/current_user_provider.dart';
import 'evento_model.dart';
import 'models/event_checkin_model.dart';
import 'services/event_report_service.dart';

class EventoDetalhePage extends ConsumerWidget {
  final String eventoId;
  const EventoDetalhePage({super.key, required this.eventoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;
    final bool canReport = user?.roles.any((r) => ['admin', 'secretaria'].contains(r.toLowerCase())) ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detalhes do Evento'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('eventos').doc(eventoId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final evento = Evento.fromMap(snapshot.data!.id, snapshot.data!.data() as Map<String, dynamic>);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(evento),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SOBRE O EVENTO', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12, letterSpacing: 1.2)),
                      const SizedBox(height: 12),
                      Text(evento.descricao, style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87)),
                      
                      const SizedBox(height: 32),
                      _buildImpactCard(context, eventoId),

                      const SizedBox(height: 40),

                      // BOTÃO DINÂMICO (CONFIRMAR OU CANCELAR)
                      if (user != null)
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('event_checkins')
                              .where('eventId', isEqualTo: eventoId)
                              .where('memberId', isEqualTo: user.uid)
                              .snapshots(),
                          builder: (context, snap) {
                            final bool alreadyConfirmed = snap.hasData && snap.data!.docs.isNotEmpty;

                            return Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: alreadyConfirmed 
                                      ? () => _cancelParticipation(context, snap.data!.docs.first.id)
                                      : () => _confirmParticipation(context, eventoId, user),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: alreadyConfirmed ? Colors.redAccent : AppColors.primary, 
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                                    ),
                                    child: Text(
                                      alreadyConfirmed ? 'CANCELAR MINHA PRESENÇA' : 'CONFIRMAR MINHA PRESENÇA', 
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                                    ),
                                  ),
                                ),
                                if (alreadyConfirmed)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text('Você já confirmou presença neste evento.', 
                                      style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            );
                          },
                        ),

                      if (canReport) ...[
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),
                        const Text('GESTÃO ADMINISTRATIVA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed: () => _openQrScanner(context, eventoId),
                            icon: const Icon(Icons.qr_code_scanner),
                            label: const Text('CHECK-IN POR QR CODE'),
                            style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () => EventReportService.generateAttendanceReport(evento),
                            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                            label: const Text('GERAR RELATÓRIO DE IMPACTO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Evento evento) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
            child: Text(evento.categoria.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          Text(evento.titulo, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(DateFormat('dd/MM/yyyy HH:mm').format(evento.data), style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(width: 20),
              const Icon(Icons.location_on_outlined, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(evento.local, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImpactCard(BuildContext context, String eventId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('event_checkins').where('eventId', isEqualTo: eventId).snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          child: Row(
            children: [
              const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.how_to_reg, color: Colors.white)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$count MEMBROS', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text('Confirmados até o momento', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmParticipation(BuildContext context, String eventId, dynamic user) async {
    try {
      await FirebaseFirestore.instance.collection('event_checkins').add({
        'eventId': eventId,
        'memberId': user.uid,
        'memberName': user.email.split('@')[0].toUpperCase(),
        'gender': user.gender ?? 'Não informado',
        'birthDate': user.birthDate ?? '',
        'checkInTime': FieldValue.serverTimestamp(),
        'type': 'confirmacao_app',
      });
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Presença Confirmada!')));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  /// NOVO: Método para Cancelar Presença
  void _cancelParticipation(BuildContext context, String checkinId) async {
    try {
      await FirebaseFirestore.instance.collection('event_checkins').doc(checkinId).delete();
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Presença cancelada com sucesso.')));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao cancelar: $e')));
    }
  }

  void _openQrScanner(BuildContext context, String eventId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: MobileScanner(
          onDetect: (capture) async {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              final String memberId = barcodes.first.displayValue ?? '';
              final userDoc = await FirebaseFirestore.instance.collection('users').doc(memberId).get();
              final userData = userDoc.data();

              await FirebaseFirestore.instance.collection('event_checkins').add({
                'eventId': eventId,
                'memberId': memberId,
                'memberName': userData?['email']?.split('@')[0].toUpperCase() ?? 'MEMBRO QR',
                'gender': userData?['gender'] ?? 'Não informado',
                'birthDate': userData?['birthDate'] ?? '',
                'checkInTime': FieldValue.serverTimestamp(),
                'type': 'qrcode_checkin',
              });
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Check-in Realizado!')));
              }
            }
          },
        ),
      ),
    );
  }
}
