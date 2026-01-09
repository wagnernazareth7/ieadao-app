import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ieadao/core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ComunicacaoDashboard extends ConsumerWidget {
  const ComunicacaoDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Painel de Comunicação'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.amberAccent),
            onPressed: () => context.push('/ia-assistente'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await AuthService().logout(),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ministério de Media', 
                    style: AppTextStyles.heading.copyWith(color: Colors.white, fontSize: 22)),
                  const SizedBox(height: 4),
                  const Text('Gerencie o conteúdo e a vida da app.', 
                    style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ferramentas de Media', style: AppTextStyles.heading),
                  const SizedBox(height: 16),
                  
                  // GRID COMPACTO DE COMUNICAÇÃO (4 Colunas)
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                    children: [
                      _MediaCompactBtn(icon: Icons.add_a_photo, label: 'Mural', color: Colors.blue, onTap: () => context.push('/publicar-culto')),
                      _MediaCompactBtn(icon: Icons.campaign, label: 'Avisos', color: Colors.orange, onTap: () => context.push('/comunicados')),
                      _MediaCompactBtn(icon: Icons.library_books, label: 'Biblioteca', color: Colors.teal, onTap: () => context.push('/biblioteca-admin')),
                      _MediaCompactBtn(icon: Icons.forum, label: 'Chat Equipa', color: Colors.green, onTap: () => context.push('/chat/comunicacao/Equipa de Media')),
                      _MediaCompactBtn(icon: Icons.calendar_month, label: 'Agenda', color: Colors.indigo, onTap: () => context.push('/agenda')),
                      _MediaCompactBtn(icon: Icons.volunteer_activism, label: 'Ofertas', color: Colors.redAccent, onTap: () => context.push('/donations')),
                      _MediaCompactBtn(icon: Icons.auto_awesome, label: 'Luz IA', color: Colors.amber, onTap: () => context.push('/ia-assistente')),
                      _MediaCompactBtn(icon: Icons.settings, label: 'Ajustes', color: Colors.grey, onTap: () {}),
                    ],
                  ),

                  const SizedBox(height: 32),
                  const Text('Estado do Mural', style: AppTextStyles.heading),
                  const SizedBox(height: 12),
                  const Card(
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.info_outline, size: 18),
                      title: Text('Publicações em dia', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: Text('Última atualização feita hoje.', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaCompactBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MediaCompactBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, 
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
