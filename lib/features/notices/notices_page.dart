import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'notices_controller.dart';
import '../../core/models/notice_model.dart';

class NoticesPage extends ConsumerWidget {
  const NoticesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticesAsync = ref.watch(allNoticesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Avisos e Comunicados'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: noticesAsync.when(
        data: (notices) {
          // FILTRO SÉNIOR: Membro só vê o que não expirou
          final activeNotices = notices.where((n) {
            if (n.expiresAt == null) return true;
            return n.expiresAt!.isAfter(DateTime.now());
          }).toList();

          if (activeNotices.isEmpty) {
            return const Center(child: Text('Nenhum comunicado ativo no momento.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeNotices.length,
            itemBuilder: (context, index) {
              final n = activeNotices[index];
              final dataStr = DateFormat('dd/MM HH:mm').format(n.date);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  // CORREÇÃO: Abre a página de resposta/detalhes
                  onTap: () => context.push('/comunicados/${n.id}'),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(n.title, 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            const Icon(Icons.forum_outlined, size: 16, color: AppColors.secondary),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(n.content, maxLines: 2, overflow: TextOverflow.ellipsis, 
                          style: const TextStyle(fontSize: 13, color: Colors.black87)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(dataStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            const Text('VER E RESPONDER', 
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro ao carregar avisos.')),
      ),
    );
  }
}
