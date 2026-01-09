import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../coral/services/coral_service.dart';
import '../../../core/models/music_model.dart';

class DiretoriaDashboard extends ConsumerWidget {
  final List<String> roles;
  const DiretoriaDashboard({super.key, required this.roles});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final normalizedRoles = roles.map((r) => r.toLowerCase().trim()).toList();
    final coralService = CoralService();

    final bool canAdmin = normalizedRoles.contains('admin');
    final bool isDirector = normalizedRoles.contains('direcao') || normalizedRoles.contains('diretor') || normalizedRoles.contains('diretora');
    final bool canManage = canAdmin || isDirector || normalizedRoles.contains('secretaria');
    final bool canLiturgia = canAdmin || normalizedRoles.contains('dirigente') || normalizedRoles.contains('dirigentes');
    final bool canMedia = canAdmin || isDirector || normalizedRoles.contains('comunicacao') || normalizedRoles.contains('media');
    final bool canEbd = canAdmin || isDirector || normalizedRoles.contains('professor');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text('Ecossistema de Serviço', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
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
                  // --- ÁREA 1: LITURGIA (DIRIGENTES) ---
                  if (canLiturgia) ...[
                    _buildSectionHeader('LITURGIA E ADORAÇÃO', Icons.auto_fix_high, Colors.orange),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.4,
                      children: [
                        _FeatureCard(label: 'Roteiro do Culto', icon: Icons.playlist_add_check_circle, color: Colors.redAccent, onTap: () => context.push('/culto/roteiro')),
                        _FeatureCard(label: 'Montar Setlist', icon: Icons.playlist_add_check, color: Colors.purple, onTap: () => context.push('/setlists/editor')),
                        _FeatureCard(label: 'Cânticos de Culto', icon: Icons.library_music, color: Colors.blue, onTap: () => _showAddMusic(context, coralService)),
                        _FeatureCard(label: 'Chat Louvor', icon: Icons.forum_rounded, color: Colors.green, onTap: () => context.push('/chat/louvor/Ministério de Louvor')),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],

                  // --- ÁREA 2: GESTÃO ESTRATÉGICA ---
                  if (canManage) ...[
                    _buildSectionHeader('GESTÃO ESTRATÉGICA', Icons.admin_panel_settings, Colors.indigo),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)]),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 4,
                        mainAxisSpacing: 24,
                        crossAxisSpacing: 4,
                        childAspectRatio: 0.75,
                        children: [
                          _IconBtn(label: 'Membros', icon: Icons.people_alt, color: Colors.blue, onTap: () => context.push('/membros')),
                          _IconBtn(label: 'Finanças', icon: Icons.account_balance_wallet, color: Colors.teal, onTap: () => context.push('/donations-admin')),
                          _IconBtn(label: 'Agenda', icon: Icons.calendar_month, color: Colors.orange, onTap: () => context.push('/agenda')),
                          _IconBtn(label: 'Família Fé', icon: Icons.favorite, color: Colors.pink, onTap: () => context.push('/discipulado')),
                          if (canAdmin || isDirector) _IconBtn(label: 'Biblioteca', icon: Icons.book, color: Colors.brown, onTap: () => context.push('/biblioteca-admin')),
                          if (canAdmin || isDirector) _IconBtn(label: 'Património', icon: Icons.inventory_2, color: Colors.blueGrey, onTap: () => context.push('/inventario')),
                          if (canAdmin || isDirector) _IconBtn(label: 'Relatórios', icon: Icons.bar_chart, color: Colors.deepPurple, onTap: () => context.push('/reports')),
                          if (canAdmin) _IconBtn(label: 'Auditoria', icon: Icons.security, color: Colors.red, onTap: () => context.push('/audit')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // --- ÁREA 3: ENSINO E COMUNICAÇÃO ---
                  if (canMedia || canEbd) ...[
                    _buildSectionHeader('ENSINO E COMUNICAÇÃO', Icons.school, Colors.green),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        if (canEbd) _CompactTool(label: 'Gestão da EBD', icon: Icons.menu_book, color: Colors.green, onTap: () => context.push('/ebd-admin')),
                        const SizedBox(height: 12),
                        if (canMedia) _CompactTool(label: 'Comunicados Oficiais', icon: Icons.campaign, color: Colors.orange, onTap: () => context.push('/comunicados-admin')),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(children: [Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 14, color: color)), const SizedBox(width: 10), Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.blueGrey.shade700, letterSpacing: 1.5))]);
  }

  void _showAddMusic(BuildContext context, CoralService service) {
    final titleCtrl = TextEditingController();
    final lyricsCtrl = TextEditingController();
    final chordsCtrl = TextEditingController();
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))), builder: (context) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24), child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('Cântico de Louvor', style: AppTextStyles.heading), const SizedBox(height: 20), TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título da Música', border: OutlineInputBorder())), const SizedBox(height: 12), TextField(controller: lyricsCtrl, maxLines: 5, decoration: const InputDecoration(labelText: 'Letra da Canção', border: OutlineInputBorder())), const SizedBox(height: 12), TextField(controller: chordsCtrl, maxLines: 5, decoration: const InputDecoration(labelText: 'Cifras / Acordes (Opcional)', border: OutlineInputBorder(), hintText: 'G  C  D...')), const SizedBox(height: 24), SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () async { if (titleCtrl.text.isEmpty) return; await service.addMusic(Music(id: '', title: titleCtrl.text.trim(), composer: 'IEADAO Tsalala', lyrics: lyricsCtrl.text.trim(), chords: chordsCtrl.text.trim(), createdAt: DateTime.now())); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('ADICIONAR À LISTA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))), const SizedBox(height: 24)]))));
  }
}

class _FeatureCard extends StatelessWidget {
  final String label; final IconData icon; final Color color; final VoidCallback onTap;
  const _FeatureCard({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(color: Colors.white, borderRadius: BorderRadius.circular(24), elevation: 4, shadowColor: color.withOpacity(0.2), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(24), child: Container(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [CircleAvatar(radius: 20, backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color, size: 20)), const SizedBox(height: 12), Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF1E293B)))]))));
}

class _IconBtn extends StatelessWidget {
  final String label; final IconData icon; final Color color; final VoidCallback onTap;
  const _IconBtn({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: color, size: 22), const SizedBox(height: 8), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey))]));
}

class _CompactTool extends StatelessWidget {
  final String label; final IconData icon; final Color color; final VoidCallback onTap;
  const _CompactTool({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.1))), child: ListTile(onTap: onTap, leading: Icon(icon, color: color, size: 20), title: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), trailing: const Icon(Icons.chevron_right, size: 14)));
}
