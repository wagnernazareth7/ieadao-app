import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ieadao/core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/providers/current_user_provider.dart';
import '../membros/widgets/aniversariantes_widget.dart';
import 'widgets/servir_hoje_widget.dart';
import '../notifications/widgets/notification_bell_widget.dart'; // NOVO IMPORT

class MembroDashboard extends ConsumerWidget {
  const MembroDashboard({super.key});

  ({String channel, String name, IconData icon, Color color}) _getHomogeneousGroup(dynamic user) {
    final defaultGroup = (channel: 'geral', name: 'Comunidade IEADAO', icon: Icons.groups, color: Colors.blue);
    
    if (user?.birthDate == null || user.birthDate.isEmpty) return defaultGroup;

    try {
      DateTime birthDate;
      if (user.birthDate.contains('/')) {
        final parts = user.birthDate.split('/');
        birthDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      } else {
        birthDate = DateTime.parse(user.birthDate);
      }

      final age = DateTime.now().year - birthDate.year;
      final gender = user.gender ?? 'Masculino';

      if (age >= 12 && age <= 17) return (channel: 'adolescentes', name: 'Grupo de Adolescentes', icon: Icons.scuba_diving, color: Colors.orange);
      if (age >= 18 && age < 30) return (channel: 'jovens', name: 'Ministério de Jovens', icon: Icons.rocket_launch, color: Colors.teal);
      if (age >= 30) {
        if (gender == 'Masculino' || gender == 'male') return (channel: 'homens', name: 'União de Homens', icon: Icons.shield, color: Colors.blueGrey);
        return (channel: 'senhoras', name: 'Círculo de Oração', icon: Icons.auto_awesome, color: Colors.pinkAccent);
      }
    } catch (e) {
      debugPrint('Erro no cálculo de grupo homogêneo: $e');
    }
    return defaultGroup;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('IEADAO Mobile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // ATIVAÇÃO DO SININHO INTELIGENTE
          const NotificationBellWidget(),
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.amberAccent),
            onPressed: () => context.push('/ia-assistente'),
          ),
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => _showSettings(context, ref)),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: userAsync.when(
                data: (user) {
                  final name = user?.email.split('@')[0].toUpperCase() ?? 'MEMBRO';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('A Paz do Senhor,', 
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      Text('$name!', 
                        style: AppTextStyles.heading.copyWith(color: Colors.white, fontSize: 28)),
                      const SizedBox(height: 4),
                      const Text('Deus abençoe o seu dia.', style: TextStyle(color: Colors.white70)),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Bem-vindo'),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AniversariantesWidget(),

                  userAsync.maybeWhen(
                    data: (user) => user != null ? ServirHojeWidget(userId: user.uid) : const SizedBox.shrink(),
                    orElse: () => const SizedBox.shrink(),
                  ),
                  
                  const SizedBox(height: 20),

                  const Text('Vida da Igreja', style: AppTextStyles.heading),
                  const SizedBox(height: 12),
                  _buildMuralCard(context),

                  const SizedBox(height: 24),
                  const Text('Meu Ministério', style: AppTextStyles.heading),
                  const SizedBox(height: 12),
                  
                  userAsync.when(
                    data: (user) {
                      final group = _getHomogeneousGroup(user);
                      return _buildGroupCard(context, group);
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 24),
                  const Text('Menu Principal', style: AppTextStyles.heading),
                  const SizedBox(height: 16),
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.75,
                    children: [
                      _CompactMenu(icon: Icons.calendar_month, label: 'Agenda', color: Colors.blue, onTap: () => context.push('/agenda')),
                      _CompactMenu(icon: Icons.school, label: 'EBD', color: Colors.green, onTap: () => context.push('/ebd')),
                      _CompactMenu(icon: Icons.favorite, label: 'Oração', color: Colors.redAccent, onTap: () => context.push('/oracao')),
                      _CompactMenu(icon: Icons.volunteer_activism, label: 'Ofertas', color: Colors.teal, onTap: () => context.push('/donations')),
                      _CompactMenu(icon: Icons.library_books, label: 'Biblioteca', color: Colors.orange, onTap: () => context.push('/biblioteca')),
                      _CompactMenu(icon: Icons.book, label: 'Diário', color: Colors.purple, onTap: () => context.push('/diario')),
                      _CompactMenu(icon: Icons.person, label: 'Perfil', color: Colors.blueGrey, onTap: () => context.push('/profile')),
                      _CompactMenu(icon: Icons.info_outline, label: 'Avisos', color: Colors.indigo, onTap: () => context.push('/comunicados')),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuralCard(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push('/mural'),
        child: Column(
          children: [
            Container(
              height: 70,
              width: double.infinity,
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.blue, AppColors.primary])),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
            ),
            const ListTile(
              dense: true,
              title: Text('Mural do Culto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text('Fotos e vídeos recentes', style: TextStyle(fontSize: 11)),
              trailing: Icon(Icons.chevron_right, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, dynamic group) {
    return Card(
      elevation: 0,
      color: group.color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: group.color.withValues(alpha: 0.2))),
      child: ListTile(
        dense: true,
        leading: Icon(group.icon, color: group.color, size: 22),
        title: Text(group.name, style: TextStyle(fontWeight: FontWeight.bold, color: group.color, fontSize: 13)),
        subtitle: const Text('Comunicação e serviço', style: TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.chevron_right, size: 16),
        onTap: () => context.push('/chat/${group.channel}/${group.name}'),
      ),
    );
  }

  void _showSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.person_outline), title: const Text('Meu Perfil'), onTap: () { Navigator.pop(context); context.push('/profile'); }),
            const Divider(),
            ListTile(leading: const Icon(Icons.logout, color: Colors.redAccent), title: const Text('Sair', style: TextStyle(color: Colors.redAccent)), onTap: () async { Navigator.pop(context); await AuthService().logout(); }),
          ],
        ),
      ),
    );
  }
}

class _CompactMenu extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _CompactMenu({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(label, 
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
