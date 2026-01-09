import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../core/models/prayer_request_model.dart';
import '../services/prayer_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/providers/current_user_provider.dart';

class PrayerPage extends ConsumerStatefulWidget {
  const PrayerPage({super.key});

  @override
  ConsumerState<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends ConsumerState<PrayerPage> {
  final _service = PrayerService();
  bool _showOnlyMine = false;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Corrente de Oração'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('Inicie sessão para participar.'));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('Mural Público'),
                      selected: !_showOnlyMine,
                      onSelected: (v) => setState(() => _showOnlyMine = false),
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Meus Pedidos'),
                      selected: _showOnlyMine,
                      onSelected: (v) => setState(() => _showOnlyMine = true),
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: StreamBuilder<List<PrayerRequest>>(
                  stream: _showOnlyMine 
                      ? _service.watchMyPrayers(user.uid) 
                      : _service.watchPublicPrayers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyState();
                    }

                    final prayers = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: prayers.length,
                      itemBuilder: (context, index) => _PrayerCard(
                        prayer: prayers[index], 
                        service: _service,
                        currentUserId: user.uid, // PASSANDO UID PARA O CARD
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro ao carregar: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, userAsync.value?.uid, userAsync.value?.email),
        label: const Text('PEDIR ORAÇÃO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.favorite, color: Colors.white),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.volunteer_activism_outlined, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text('Nenhum pedido neste mural.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, String? uid, String? email) {
    if (uid == null) return;
    
    final textCtrl = TextEditingController();
    bool isAnon = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, 
            left: 24, right: 24, top: 24
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Qual a sua necessidade?', style: AppTextStyles.heading),
              const SizedBox(height: 16),
              TextField(
                controller: textCtrl,
                maxLines: 4,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Escreva aqui o seu motivo...', 
                  border: OutlineInputBorder()
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Pedir como Anónimo'),
                value: isAnon,
                onChanged: (v) => setDialogState(() => isAnon = v),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (textCtrl.text.trim().isEmpty) return;
                    
                    final req = PrayerRequest(
                      id: '',
                      userId: uid,
                      userName: isAnon ? 'Anónimo' : (email?.split('@')[0] ?? 'Membro'),
                      content: textCtrl.text.trim(),
                      isAnonymous: isAnon,
                      createdAt: DateTime.now(),
                    );
                    
                    await _service.addRequest(req);
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('PUBLICAR PEDIDO', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrayerCard extends StatelessWidget {
  final PrayerRequest prayer;
  final PrayerService service;
  final String currentUserId; // NOVO CAMPO

  const _PrayerCard({
    required this.prayer, 
    required this.service,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    // VERIFICAÇÃO DE INTERCESSÃO ÚNICA
    final bool isAlreadyPraying = prayer.prayingUserIds.contains(currentUserId);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(prayer.userName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                Text(DateFormat('dd/MM HH:mm').format(prayer.createdAt), 
                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Text(prayer.content, style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black87)),
            const SizedBox(height: 16),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${prayer.prayingCount} intercedendo', 
                  style: TextStyle(fontSize: 11, color: isAlreadyPraying ? Colors.redAccent : Colors.grey, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () async {
                    // CHAMADA CORRIGIDA: Passando os dois argumentos necessários
                    await service.prayForRequest(prayer.id, isAlreadyPraying);
                    
                    if (context.mounted && !isAlreadyPraying) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Amém! Sua intercessão foi registrada.'), duration: Duration(seconds: 1))
                      );
                    }
                  },
                  icon: Icon(
                    isAlreadyPraying ? Icons.favorite : Icons.favorite_border, 
                    size: 16, 
                    color: isAlreadyPraying ? Colors.redAccent : AppColors.secondary
                  ),
                  label: Text(
                    isAlreadyPraying ? 'ESTOU ORANDO' : 'VOU ORAR', 
                    style: TextStyle(
                      color: isAlreadyPraying ? Colors.redAccent : AppColors.secondary, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 12
                    )
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
