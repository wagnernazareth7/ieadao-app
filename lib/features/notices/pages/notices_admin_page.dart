import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:ieadao/features/notices/notices_controller.dart';
import 'package:ieadao/core/models/notice_model.dart';

class NoticesAdminPage extends ConsumerWidget {
  const NoticesAdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticesAsync = ref.watch(allNoticesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestão de Comunicados'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNoticeForm(context, ref),
        label: const Text('NOVO AVISO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.campaign, color: Colors.white),
        backgroundColor: AppColors.secondary,
      ),
      body: noticesAsync.when(
        data: (notices) {
          if (notices.isEmpty) return const Center(child: Text('Nenhum comunicado publicado.'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notices.length,
            itemBuilder: (context, index) {
              final notice = notices[index];
              final isExpired = notice.expiresAt != null && notice.expiresAt!.isBefore(DateTime.now());

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (isExpired ? Colors.grey : AppColors.primary).withValues(alpha: 0.1),
                    child: Icon(Icons.info_outline, color: isExpired ? Colors.grey : AppColors.primary, size: 20),
                  ),
                  title: Text(notice.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Por: ${notice.author}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      Text(notice.content, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: () => _showNoticeForm(context, ref, notice: notice)),
                      IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent), onPressed: () => _confirmDelete(context, ref, notice)),
                    ],
                  ),
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

  void _showNoticeForm(BuildContext context, WidgetRef ref, {Notice? notice}) {
    final titleCtrl = TextEditingController(text: notice?.title);
    final contentCtrl = TextEditingController(text: notice?.content);
    DateTime? selectedExpiry = notice?.expiresAt;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notice == null ? 'Publicar Novo Aviso' : 'Editar Aviso', style: AppTextStyles.heading),
              const SizedBox(height: 20),
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título do Aviso', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: contentCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Conteúdo', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.timer_outlined, color: AppColors.primary),
                title: const Text('Tempo de Exposição', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: Text(
                  selectedExpiry == null ? 'Ficar exposto permanentemente' : 'Expirar em: ${DateFormat('dd/MM/yyyy').format(selectedExpiry!)}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedExpiry ?? DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setModalState(() => selectedExpiry = date);
                  },
                  child: const Text('ALTERAR'),
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (titleCtrl.text.isEmpty) return;
                    
                    final user = FirebaseAuth.instance.currentUser;
                    final db = FirebaseFirestore.instance.collection('notices');
                    
                    final data = {
                      'title': titleCtrl.text.trim(),
                      'content': contentCtrl.text.trim(),
                      'expiresAt': selectedExpiry != null ? Timestamp.fromDate(selectedExpiry!) : null,
                      'date': notice?.date != null ? Timestamp.fromDate(notice!.date) : FieldValue.serverTimestamp(),
                      // CORREÇÃO SÉNIOR: Identifica quem realmente partilhou o aviso
                      'author': notice?.author ?? user?.email?.split('@')[0].toUpperCase() ?? 'ADMINISTRAÇÃO',
                    };

                    if (notice == null) {
                      await db.add(data);
                    } else {
                      await db.doc(notice.id).update(data);
                    }
                    
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('GUARDAR COMUNICADO', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Notice notice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Aviso?'),
        content: Text('Tem certeza que deseja remover o comunicado: "${notice.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('notices').doc(notice.id).delete();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
