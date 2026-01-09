import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ieadao/features/auth/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../coral/services/coral_service.dart';
import '../../../core/models/music_model.dart';

class CoralDashboard extends ConsumerWidget {
  const CoralDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = CoralService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Painel do Coral'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () async => await AuthService().logout()),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // CABEÇALHO PREMIUM
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Paz do Senhor, Levita', style: AppTextStyles.heading.copyWith(color: Colors.white, fontSize: 22)),
                  const SizedBox(height: 4),
                  const Text('Tsalala • Adoração em Unidade e Espírito.', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatRow(service),
                  
                  const SizedBox(height: 32),
                  const Text('GESTÃO DO LOUVOR', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 11, letterSpacing: 1.2)),
                  const SizedBox(height: 16),
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.4,
                    children: [
                      _ServiceCard(
                        label: 'Marcar Ensaio',
                        icon: Icons.mic_external_on,
                        color: Colors.orange,
                        onTap: () => _showScheduleRehearsal(context, service),
                      ),
                      _ServiceCard(
                        label: 'Novo Cântico',
                        icon: Icons.library_add,
                        color: Colors.blue,
                        onTap: () => _showAddMusic(context, service),
                      ),
                      _ServiceCard(
                        label: 'Chat do Coral',
                        icon: Icons.forum_rounded,
                        color: Colors.green,
                        onTap: () => context.push('/chat/coral/Coral IEADAO'),
                      ),
                      _ServiceCard(
                        label: 'Setlists',
                        icon: Icons.playlist_play,
                        color: Colors.purple,
                        onTap: () => context.push('/setlists/editor'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                  const Text('REPERTÓRIO OFICIAL', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 11, letterSpacing: 1.2)),
                  const SizedBox(height: 16),

                  StreamBuilder<List<Music>>(
                    stream: service.watchRepertoire(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const LinearProgressIndicator();
                      final musicas = snapshot.data!;
                      if (musicas.isEmpty) return const Text('Nenhuma música no repertório.', style: TextStyle(fontSize: 12, color: Colors.grey));

                      return Column(
                        children: musicas.map((m) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            leading: const CircleAvatar(backgroundColor: Colors.orangeAccent, child: Icon(Icons.music_note, color: Colors.white, size: 18)),
                            title: Text(m.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text(m.composer, style: const TextStyle(fontSize: 11)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                            onTap: () => context.push('/louvor/musica', extra: m), // Abre Letra e Cifra
                          ),
                        )).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(CoralService service) {
    return Row(
      children: [
        Expanded(
          child: StreamBuilder(
            stream: service.watchNextRehearsal(),
            builder: (context, snap) {
              String data = 'A definir';
              if (snap.hasData && snap.data!.docs.isNotEmpty) {
                final d = (snap.data!.docs.first.data() as Map<String, dynamic>)['data'] as Timestamp;
                data = DateFormat('dd/MM, HH:mm').format(d.toDate());
              }
              return _StatBox(label: 'Próximo Ensaio', value: data, icon: Icons.event, color: Colors.orange);
            }
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StreamBuilder<List<Music>>(
            stream: service.watchRepertoire(),
            builder: (context, snap) => _StatBox(
              label: 'Cânticos', 
              value: '${snap.data?.length ?? 0} Músicas', 
              icon: Icons.library_music, 
              color: Colors.blue
            ),
          ),
        ),
      ],
    );
  }

  void _showScheduleRehearsal(BuildContext context, CoralService service) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      await service.scheduleRehearsal(picked, 'Ensaio Geral do Coral');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ensaio agendado!')));
    }
  }

  void _showAddMusic(BuildContext context, CoralService service) {
    final titleCtrl = TextEditingController();
    final lyricsCtrl = TextEditingController();
    final chordsCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Alocar Cântico', style: AppTextStyles.heading),
              const SizedBox(height: 20),
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título da Música', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: lyricsCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Letra', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: chordsCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Cifras (Opcional)', border: OutlineInputBorder(), hintText: 'G  C  D...')),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    if (titleCtrl.text.isEmpty) return;
                    await service.addMusic(Music(
                      id: '', 
                      title: titleCtrl.text.trim(), 
                      composer: 'Coral IEADAO', 
                      lyrics: lyricsCtrl.text.trim(),
                      chords: chordsCtrl.text.trim(),
                      createdAt: DateTime.now()
                    ));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('SALVAR NO REPERTÓRIO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label; final String value; final IconData icon; final Color color;
  const _StatBox({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String label; final IconData icon; final Color color; final VoidCallback onTap;
  const _ServiceCard({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: color.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 20, backgroundColor: color.withValues(alpha: 0.1), child: Icon(icon, color: color, size: 20)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
