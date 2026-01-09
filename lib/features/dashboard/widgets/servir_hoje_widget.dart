import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/escala_model.dart';
import '../../escalas/services/escala_service.dart';
import '../../../core/theme/app_colors.dart';

class ServirHojeWidget extends ConsumerWidget {
  final String userId;
  const ServirHojeWidget({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = EscalaService();

    return StreamBuilder<List<Escala>>(
      stream: service.watchUpcomingEscalas(), 
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final hoje = DateTime.now();
        
        // Filtra a escala para hoje onde o usuário está presente
        final escalaHoje = snapshot.data!.firstWhere(
          (e) => e.data.day == hoje.day && 
                 e.data.month == hoje.month && 
                 e.data.year == hoje.year &&
                 (e.obreirosApoio.contains(userId) || e.pregador.contains(userId) || e.dirigente.contains(userId)),
          // CORREÇÃO SÉNIOR: Incluindo tipoCulto no fallback
          orElse: () => Escala(id: '', data: hoje, tipoCulto: '', pregador: '', dirigente: ''),
        );

        if (escalaHoje.id.isEmpty) return const SizedBox.shrink();

        final String horaFormatada = DateFormat('HH:mm').format(escalaHoje.data);

        return Card(
          elevation: 4,
          shadowColor: AppColors.primary.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('VOCÊ SERVE HOJE!', 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12)),
                      Icon(Icons.volunteer_activism, color: Colors.white.withValues(alpha: 0.5), size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // EXIBE O TIPO DE CULTO REAL
                  Text(escalaHoje.tipoCulto, 
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.white70, size: 14),
                      const SizedBox(width: 6),
                      Text(horaFormatada, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
                      const SizedBox(width: 6),
                      const Text('Igreja Sede', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
