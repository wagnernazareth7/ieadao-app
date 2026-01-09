import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/member_service.dart';
import '../models/membro.dart';
import '../../../core/theme/app_colors.dart';

class AniversariantesWidget extends ConsumerWidget {
  const AniversariantesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = MemberService();

    return StreamBuilder<List<Membro>>(
      stream: service.watchBirthdaysToday(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final aniversariantes = snapshot.data!;

        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.cake, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'ANIVERSARIANTES DE HOJE!',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...aniversariantes.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.amber.withValues(alpha: 0.3),
                      child: Text(
                        m.firstName[0],
                        style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${m.firstName} ${m.lastName}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Lógica para enviar saudação (ex: abrir chat ou whatsapp)
                      },
                      child: const Text('PARABENIZAR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber)),
                    ),
                  ],
                ),
              )).toList(),
            ],
          ),
        );
      },
    );
  }
}
