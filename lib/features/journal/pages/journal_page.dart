import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/journal_service.dart';
import '../models/journal_entry_model.dart';
import '../providers/journal_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/providers/current_user_provider.dart';

class JournalPage extends ConsumerWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. ESCUTA O PROVIDER BLINDADO (Filtrado por UID no Core)
    final journalAsync = ref.watch(myJournalProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meu Diário Espiritual'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('Inicie sessão para ver o seu diário.'));

          return journalAsync.when(
            data: (entries) {
              if (entries.isEmpty) return _buildEmptyState();

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: entries.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) => _JournalCard(
                  entry: entries[index], 
                  service: ref.read(journalServiceProvider)
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Erro ao carregar diário: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro de autenticação: $e')),
      ),
      floatingActionButton: userAsync.maybeWhen(
        data: (user) => user != null ? FloatingActionButton.extended(
          onPressed: () => _showAddDialog(context, ref, user.uid),
          label: const Text('NOVA REFLEXÃO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          icon: const Icon(Icons.edit, color: Colors.white),
          backgroundColor: AppColors.secondary,
        ) : null,
        orElse: () => null,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book_outlined, size: 80, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('Seu diário está em branco.', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
          const Text('Comece hoje a sua jornada de reflexão.', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref, String userId) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    JournalType selectedType = JournalType.reflexao;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('O que está no seu coração?', style: AppTextStyles.heading),
                const SizedBox(height: 20),
                DropdownButtonFormField<JournalType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Tipo de Registo', border: OutlineInputBorder()),
                  items: JournalType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()))).toList(),
                  onChanged: (v) => setDialogState(() => selectedType = v!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Título ou Tema', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentCtrl,
                  maxLines: 5,
                  decoration: const InputDecoration(hintText: 'Escreva a sua meditação aqui...', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (titleCtrl.text.isEmpty || contentCtrl.text.isEmpty) return;
                      final entry = JournalEntry(
                        id: '',
                        userId: userId, // GARANTIA SÉNIOR: Vinculado ao UID real do logado
                        title: titleCtrl.text.trim(),
                        content: contentCtrl.text.trim(),
                        type: selectedType,
                        createdAt: DateTime.now(),
                      );
                      await ref.read(journalServiceProvider).saveEntry(entry);
                      if (context.mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('GUARDAR NO DIÁRIO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _JournalCard extends StatelessWidget {
  final JournalEntry entry;
  final JournalService service;
  const _JournalCard({required this.entry, required this.service});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy').format(entry.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(entry.type).withOpacity(0.1),
          child: Icon(_getTypeIcon(entry.type), color: _getTypeColor(entry.type), size: 20),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(entry.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
            Text(dateStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(entry.content, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
          onPressed: () => _confirmDelete(context),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Reflexão?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () async {
              await service.deleteEntry(entry.id);
              if (context.mounted) Navigator.pop(context);
            }, 
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(JournalType type) {
    switch (type) {
      case JournalType.reflexao: return Icons.self_improvement;
      case JournalType.meta: return Icons.flag;
      case JournalType.versiculo: return Icons.menu_book;
    }
  }

  Color _getTypeColor(JournalType type) {
    switch (type) {
      case JournalType.reflexao: return Colors.blue;
      case JournalType.meta: return Colors.green;
      case JournalType.versiculo: return Colors.orange;
    }
  }
}
