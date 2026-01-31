import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'notices_controller.dart';
import '../../core/models/notice_model.dart';
import '../auth/providers/current_user_provider.dart';

class NoticesPage extends ConsumerWidget {
  const NoticesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticesAsync = ref.watch(allNoticesProvider);
    final userAsync = ref.watch(currentUserProvider);

    final bool canAdd = userAsync.maybeWhen(
      data: (user) {
        if (user == null) return false;
        final roles = user.roles.map((r) => r.toLowerCase().trim()).toList();
        return roles.contains('admin') || roles.contains('comunicacao') || roles.contains('direcao');
      },
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Avisos e Comunicados'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      
      floatingActionButton: canAdd ? FloatingActionButton.extended(
        onPressed: () => _showAddNoticeDialog(context, ref),
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.add_comment, color: Colors.white),
        label: const Text('NOVO AVISO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ) : null,

      body: noticesAsync.when(
        data: (notices) {
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

  void _showAddNoticeDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    final user = ref.read(currentUserProvider).value;

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
            const Text('Emitir Comunicado Oficial', style: AppTextStyles.heading),
            const SizedBox(height: 24),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título do Aviso')),
            const SizedBox(height: 16),
            TextField(controller: contentCtrl, maxLines: 5, decoration: const InputDecoration(labelText: 'Conteúdo do Aviso')),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  if (titleCtrl.text.isEmpty || contentCtrl.text.isEmpty) return;
                  
                  final newNotice = Notice(
                    id: '',
                    title: titleCtrl.text.trim(),
                    content: contentCtrl.text.trim(),
                    author: user?.firstName ?? 'Comunicação', // CORREÇÃO SÉNIOR
                    date: DateTime.now(),
                    priority: false,
                  );

                  // CORREÇÃO SÉNIOR: Usando o controller correto para salvar
                  await ref.read(noticesControllerProvider).saveNotice(newNotice);
                  
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('PUBLICAR COMUNICADO'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
