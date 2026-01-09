import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../coral/services/coral_service.dart';
import '../../../core/models/music_model.dart';

class DirigenteDashboard extends ConsumerWidget {
  final List<String> roles;
  const DirigenteDashboard({super.key, required this.roles});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = CoralService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // CABEÇALHO LITÚRGICO PREMIUM
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text('Comando de Liturgia',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -20,
                      child: Icon(Icons.mic_external_on, size: 180, color: Colors.white.withOpacity(0.05)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CENTRAL DE COMANDO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1.5)),
                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.4,
                    children: [
                      _LiturgiaCard(
                        label: 'Roteiro Ao Vivo',
                        icon: Icons.playlist_add_check_circle,
                        color: Colors.redAccent,
                        onTap: () => context.push('/culto/roteiro'),
                      ),
                      _LiturgiaCard(
                        label: 'Montar Setlist',
                        icon: Icons.queue_music,
                        color: Colors.purple,
                        onTap: () => context.push('/setlists/editor'),
                      ),
                      _LiturgiaCard(
                        label: 'Novo Cântico',
                        icon: Icons.library_add,
                        color: Colors.blue,
                        onTap: () => _showAddMusic(context, service),
                      ),
                      _LiturgiaCard(
                        label: 'Chat Louvor',
                        icon: Icons.forum_rounded,
                        color: Colors.green,
                        onTap: () => context.push('/chat/louvor/Liderança de Louvor'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  const Text('CÂNTICOS DO REPERTÓRIO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1.5)),
                  const SizedBox(height: 12),

                  StreamBuilder<List<Music>>(
                    stream: service.watchRepertoire(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const LinearProgressIndicator();
                      final musicas = snapshot.data!;
                      if (musicas.isEmpty) return const Text('Nenhuma canção no repositório.', style: TextStyle(fontSize: 12, color: Colors.grey));

                      return Column(
                        children: musicas.map((m) => Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 1,
                          child: ListTile(
                            onTap: () => context.push('/louvor/musica', extra: m),
                            leading: const CircleAvatar(backgroundColor: Colors.orangeAccent, child: Icon(Icons.music_note, color: Colors.white, size: 18)),
                            title: Text(m.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text(m.composer, style: const TextStyle(fontSize: 11)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                          ),
                        )).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
                        composer: 'IEADAO Tsalala',
                        lyrics: lyricsCtrl.text.trim(),
                        chords: chordsCtrl.text.trim(),
                        createdAt: DateTime.now()
                    ));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('ADICIONAR À LISTA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

class _LiturgiaCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _LiturgiaCard({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 4,
      shadowColor: color.withOpacity(0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 12),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF1E293B))),
            ],
          ),
        ),
      ),
    );
  }
}